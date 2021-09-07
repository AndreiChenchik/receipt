//
//  GoodsTypeView.swift
//  GoodsTypeView
//
//  Created by Andrei Chenchik on 1/9/21.
//

import SwiftUI

struct GoodsTypeView: View {
    let dataController = DataController.shared

    @Environment(\.dismiss) var dismiss

    @State private var typeTitle = ""

    @FetchRequest<GoodsCategory>(
        sortDescriptors: [NSSortDescriptor(keyPath: \GoodsCategory.title, ascending: false)]
    )
    private var categories
    @State private var selectedCategoryURL: String = ""
    @State private var selectedUnits: Int16 = 0
    var selectedCategory: GoodsCategory? { categories.first { $0.objectURL == selectedCategoryURL } }

    var type: GoodsType?
    var item: Item?

    init() {}

    init(type: GoodsType) {
        self.type = type
        _typeTitle = State(wrappedValue: type.wrappedTitle)
        _selectedCategoryURL = State(wrappedValue: type.category?.objectURL ?? "")
        _selectedUnits = State(wrappedValue: type.unitValue)
    }

    init(item: Item) {
        self.item = item
    }

    var body: some View {
        Form {
            Section(header: Text("Title"),
                    footer: Text("If you will add EMOJI in the beginning of the title - it will became an icon of that item type. How cool is that?!")) {
                TextField("Category Title", text: $typeTitle,
                          prompt: Text("🚀 Super-type"))
            }

            Section {
                Picker("Quantity measurement", selection: $selectedUnits) {
                    ForEach(GoodsType.Unit.allCases) { unit in
                        Text("\(unit.title), \(unit.abbreviation).").tag(unit.rawValue)
                    }
                }
            }

            Section {
                RelationPicker<GoodsCategory>("Category", selection: $selectedCategoryURL)
            }

            Button(type == nil ? "Create type" : "Update type") {
                saveChanges()
                dismiss()
            }
            .disabled(typeTitle.isEmpty || selectedCategory == nil)
        }
        .navigationTitle(type == nil ? "New type" : "Edit type")
    }

    func saveChanges() {
        let typeTitle = typeTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let type = type {
            dataController.updateGoodsType(type.objectID, title: typeTitle, categoryID: selectedCategory?.objectID, units: selectedUnits)
        } else {
            dataController.createGoodsType(with: typeTitle, linkedTo: item?.objectID, categoryID: selectedCategory?.objectID, units: selectedUnits)
        }
    }
}


struct GoodsTypeView_Previews: PreviewProvider {
    static var previews: some View {
        GoodsTypeView(type: GoodsType.example)
    }
}
