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
