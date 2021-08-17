//
//  DraftDateTime.swift
//  DraftDateTime
//
//  Created by Andrei Chenchik on 12/8/21.
//

import Foundation

struct DraftDateTime {
    static private var possibleDateFormats = ["dd/MM/yy", "dd.MM.yy", "yyyy-MM-dd", "dd-MMM-yy"]
    static private var possibleTimeFormats = ["HH:mm", "HH:mm:ss"]

    var value: Date

    init(_ date: Date) {
        self.value = date
    }

    init(from string: String) {
        self.value = Self.getDateTime(from: string) ?? Date()
    }

    init(from strings: [String]) {
        self.value = Self.getDateTime(from: strings)
    }


    static func getDateTime(from strings: [String]) -> Date {
        for string in strings {
            if let dateTime = getDateTime(from: string) {
                return dateTime
            }
        }

        return Date()
    }


    static func getDateTime(from string: String) -> Date? {
        var dateElement: Date?
        var timeElement: Date?

        for subString in string.split(separator: " ") {
            if let date = getDate(from: String(subString)), dateElement == nil {
                dateElement = date
                continue
            }

            if let time = getTime(from: String(subString)), timeElement == nil {
                timeElement = time
            }
        }

        if let dateElement = dateElement {
            if let timeElement = timeElement {
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: dateElement)
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeElement)

                var dateTime = DateComponents()
                dateTime.year = dateComponents.year
                dateTime.month = dateComponents.month
                dateTime.day = dateComponents.day
                dateTime.hour = timeComponents.hour
                dateTime.minute = timeComponents.minute
                dateTime.second = timeComponents.second

                return calendar.date(from: dateTime)
            }

            return dateElement
        }

        return nil
    }

    static func getTime(from string: String) -> Date? {
        let formatter = DateFormatter()

        for timeFormat in possibleTimeFormats {
            formatter.dateFormat = "yyyy-MM-dd " + timeFormat

            if let time = formatter.date(from: "2000-01-01 " + string) {
                return time
            }
        }

        return nil
    }

    static func getDate(from string: String) -> Date? {
        let formatter = DateFormatter()

        for subString in string.split(separator: ":") {
            let preparedSubString = subString.trimmingCharacters(in: .whitespacesAndNewlines)

            for dateFormat in possibleDateFormats {
                formatter.dateFormat = dateFormat

                if let date = formatter.date(from: preparedSubString) {
                    return date
                }
            }
        }

        return nil
    }
}
