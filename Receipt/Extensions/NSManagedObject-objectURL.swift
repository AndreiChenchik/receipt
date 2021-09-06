//
//  NSManagedObject-objectURL.swift
//  NSManagedObject-objectURL
//
//  Created by Andrei Chenchik on 3/9/21.
//

import Foundation
import CoreData

extension NSManagedObject {
    var objectURL: String { objectID.uriRepresentation().absoluteString }
}
