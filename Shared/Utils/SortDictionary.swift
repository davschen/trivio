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

// Not sure where to put this oops
extension Array {
    func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}
