//
//  GoodsType-CoreDataHelpers.swift
//  GoodsType-CoreDataHelpers
//
//  Created by Andrei Chenchik on 1/9/21.
//

import Foundation

extension GoodsType {
    enum Unit: Int16, CaseIterable, Identifiable {
        case units = 0
        case grams = 2
        case liters = 3

        var id: Int16 { self.rawValue }

        var title: String {
            switch self {
            case .liters:
                return "liters"
            case .grams:
                return "kilograms"
            case .units:
                return "units"
            }
        }

        var abbreviation: String {
            switch self {
            case .liters:
                return "l"
            case .grams:
                return "kg"
            case .units:
                return "u"
            }
        }
    }

    var unit: Unit {
        get { Unit(rawValue: unitValue) ?? .units }
        set { unitValue = newValue.rawValue }
    }


    var wrappedTitle: String { title ?? "Unknown goods" }

    var typeIcon: String {
        String(title?.first ?? Character(""))
    }

    var typeTitleWithoutIcon: String {
        if typeIcon.first?.isEmoji ?? false {
            let shortTitle = wrappedTitle.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
            return String(shortTitle)
        } else {
            return wrappedTitle
        }
    }

    var typeItems: [Item] {
        items?.allObjects as? [Item] ?? []
    }

    var typeItemsSum: NSDecimalNumber {
        let sum = typeItems.reduce(0.0) { partialResult, receipt in
            partialResult + (receipt.price?.doubleValue ?? 0.0)
        }

        return NSDecimalNumber(value: sum)
    }

    var typeItemsSumString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: typeItemsSum) ?? ""
    }

    var typeCategoryTitle: String {
        category?.title ?? "Unknown category"
    }
}

extension GoodsType {
    static var example: GoodsType {
        let controller = DataController.preview
        let viewContext = controller.container.viewContext

        let type = GoodsType(context: viewContext)
        type.title = "🛃 Type of goods example"

        return type
    }
}
