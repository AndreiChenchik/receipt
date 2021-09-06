//
//  RecognitionDataTransformer.swift
//  RecognitionDataTransformer
//
//  Created by Andrei Chenchik on 22/8/21.
//

import Foundation

class RecognitionDataTransformer: NSSecureUnarchiveFromDataTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return RecognitionData.self
    }

    override class var allowedTopLevelClasses: [AnyClass] {
        return [RecognitionData.self]
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
        }
        return super.transformedValue(data)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let color = value as? RecognitionData else {
            fatalError("Wrong data type: value must be a RecognitionData object; received \(type(of: value))")
        }
        return super.reverseTransformedValue(color)
    }
}

extension NSValueTransformerName {
    static let recognitionDataTransformer = NSValueTransformerName(rawValue: String(describing: RecognitionDataTransformer.self))
}
