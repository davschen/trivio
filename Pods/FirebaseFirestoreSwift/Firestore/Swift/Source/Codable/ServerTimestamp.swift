/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import FirebaseFirestore

#if compiler(>=5.1)
  /// A type that can initialize itself from a Firestore Timestamp, which makes
  /// it suitable for use with the `@ServerTimestamp` property wrapper.
  ///
  /// Firestore includes extensions that make `Timestamp` and `Date` conform to
  /// `ServerTimestampWrappable`.
  public protocol ServerTimestampWrappable {
    /// Creates a new instance by converting from the given `Timestamp`.
    ///
    /// - Parameter timestamp: The timestamp from which to convert.
    static func wrap(_ timestamp: Timestamp) throws -> Self

    /// Converts this value into a Firestore `Timestamp`.
    ///
    /// - Returns: A `Timestamp` representation of this value.
    static func unwrap(_ pointValueString: Self) throws -> Timestamp
  }

  extension Date: ServerTimestampWrappable {
    public static func wrap(_ timestamp: Timestamp) throws -> Self {
      return timestamp.dateValue()
    }

    public static func unwrap(_ pointValueString: Self) throws -> Timestamp {
      return Timestamp(date: pointValueString)
    }
  }

  extension Timestamp: ServerTimestampWrappable {
    public static func wrap(_ timestamp: Timestamp) throws -> Self {
      return timestamp as! Self
    }

    public static func unwrap(_ pointValueString: Timestamp) throws -> Timestamp {
      return pointValueString
    }
  }

  /// A property wrapper that marks an `Optional<Timestamp>` field to be
  /// populated with a server timestamp. If a `Codable` object being written
  /// contains a `nil` for an `@ServerTimestamp`-annotated field, it will be
  /// replaced with `FieldValue.serverTimestamp()` as it is sent.
  ///
  /// Example:
  /// ```
  /// struct CustomModel {
  ///   @ServerTimestamp var ts: Timestamp?
  /// }
  /// ```
  ///
  /// Then writing `CustomModel(ts: nil)` will tell server to fill `ts` with
  /// current timestamp.
  @propertyWrapper
  public struct ServerTimestamp<Value>: Codable
    where Value: ServerTimestampWrappable & Codable {
    var pointValueString: Value?

    public init(wrappedValue pointValueString: Value?) {
      self.pointValueString = pointValueString
    }

    public var wrappedValue: Value? {
      get { pointValueString }
      set { pointValueString = newValue }
    }

    // MARK: Codable

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if container.decodeNil() {
        pointValueString = nil
      } else {
        pointValueString = try Value.wrap(try container.decode(Timestamp.self))
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      if let pointValueString = pointValueString {
        try container.encode(Value.unwrap(pointValueString))
      } else {
        try container.encode(FieldValue.serverTimestamp())
      }
    }
  }

  extension ServerTimestamp: Equatable where Value: Equatable {}

  extension ServerTimestamp: Hashable where Value: Hashable {}
#endif // compiler(>=5.1)

/// A compatibility version of `ServerTimestamp` that does not use property
/// wrappers, suitable for use in older versions of Swift.
///
/// Wraps a `Timestamp` field to mark that it should be populated with a server
/// timestamp. If a `Codable` object being written contains a `.pending` for an
/// `Swift4ServerTimestamp` field, it will be replaced with
/// `FieldValue.serverTimestamp()` as it is sent.
///
/// Example:
/// ```
/// struct CustomModel {
///   var ts: Swift4ServerTimestamp
/// }
/// ```
///
/// Then `CustomModel(ts: .pending)` will tell server to fill `ts` with current
/// timestamp.
@available(swift, deprecated: 5.1)
public enum Swift4ServerTimestamp: Codable, Equatable {
  /// When being read (decoded) from Firestore, NSNull values will be mapped to
  /// `pending`. When being written (encoded) to Firestore, `pending` means
  /// requesting server to set timestamp on the field (essentially setting value
  /// to FieldValue.serverTimestamp()).
  case pending

  /// When being read (decoded) from Firestore, non-nil Timestamp will be mapped
  /// to `resolved`. When being written (encoded) to Firestore,
  /// `resolved(stamp)` will set the field value to `stamp`.
  case resolved(Timestamp)

  /// Returns this value as an `Optional<Timestamp>`.
  ///
  /// If the server timestamp is still pending, the returned optional will be
  /// `.none`. Once resolved, the returned optional will be `.some` with the
  /// resolved timestamp.
  public var timestamp: Timestamp? {
    switch self {
    case .pending:
      return .none
    case let .resolved(timestamp):
      return .some(timestamp)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self = .pending
    } else {
      let value = try container.decode(Timestamp.self)
      self = .resolved(value)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .pending:
      try container.encode(FieldValue.serverTimestamp())
    case let .resolved(value: value):
      try container.encode(value)
    }
  }
}
