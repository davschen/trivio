//
//  MasterHandler+Date.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/28/23.
//

import Foundation

extension MasterHandler {
    func relativeDateString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let dateComponents = calendar.dateComponents([.day], from: date, to: now)

            if let daysAgo = dateComponents.day, daysAgo <= 3 {
                return "\(daysAgo) days ago"
            } else {
                dateFormatter.dateFormat = "MM/dd/yy"
                return dateFormatter.string(from: date)
            }
        }
    }
}
