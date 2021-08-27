//
//  RecognitionData.swift
//  RecognitionData
//
//  Created by Andrei Chenchik on 19/8/21.
//

import CoreData
import CoreGraphics

final public class RecognitionData: NSObject, NSSecureCoding {
    let content: RecognizedContent

    init(content: RecognizedContent) {
        self.content = content
    }

    // MARK: - NSSecureCoding
    public static var supportsSecureCoding = true

    enum Key: String {
        case content = "content"
    }

    public func encode(with coder: NSCoder) {
        let contentData = try! JSONEncoder().encode(content)
        coder.encode(contentData, forKey: Key.content.rawValue)
    }

    public convenience required init?(coder: NSCoder) {
        guard let contentData = coder.decodeObject(forKey: Key.content.rawValue) as? Data else { return nil }
        let content = try! JSONDecoder().decode(RecognizedContent.self, from: contentData)
        self.init(content: content)
    }
}


extension RecognitionData {
    var receiptTotal: (id: UUID, value: NSDecimalNumber)? {
        if let line = content.lines.first(where: { $0.contentType == .total }),
           let value = line.value {
            let id = line.id
            let total = NSDecimalNumber(value: value)

            return (id: id, value: total)
        }

        return nil
    }

    var purchaseDate: (id: UUID, value: Date)? {
        if let line = content.lines.first(where: { $0.contentType == .date }),
           let date = RecognizedContent.getDateTime(from: line.text.replacingOccurrences(of: "\n", with: " ")) {
            let id = line.id

            return (id: id, value: date)
        }

        return nil
    }

    var venueAddress: (id: String, value: String)? {
        let lines = content.lines.filter { $0.contentType == .address }

        let uuidStrings = lines.map { $0.id.uuidString }
        let uuidString = uuidStrings.joined(separator: "-")

        let labels: [String] = lines.compactMap { line in
            if line.label != "" {
                return line.label
            } else {
                return nil
            }
        }
        let addressString = labels.joined(separator: ", ")

        if !addressString.isEmpty {
            return (id: uuidString, value: addressString)
        } else {
            return nil
        }
    }

    var venueTitile: String? {
        if let line = content.lines.first(where: { $0.contentType == .venue }) {
            let venueName = line.label

            return venueName
        }

        return nil
    }
}


extension RecognitionData {
    typealias Line = RecognizedContent.Line
    typealias ContentType = Line.ContentType

    func withChangedLineContentType(for line: Line, to contentType: ContentType) -> Self {
        var recognizedContent = content

        if Line.exclusiveContentTypes.contains(contentType) {
            recognizedContent = recognizedContent.withRemovedContentType(contentType)
        }

        if let newContent = recognizedContent.withChangedLineContentType(for: line, to: contentType) {
            return Self(content: newContent)
        } else {
            return self
        }
    }
}


