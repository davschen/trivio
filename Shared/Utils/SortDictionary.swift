//
//  SortDictionary.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 11/17/22.
//

import Foundation

extension Dictionary where Value: Comparable {
    var sortedByValue: [(Key, Value)] { return Array(self).sorted { $0.1 < $1.1} }
}
extension Dictionary where Key: Comparable {
    var sortedByKey: [(Key, Value)] { return Array(self).sorted { $0.0 < $1.0 } }
}
