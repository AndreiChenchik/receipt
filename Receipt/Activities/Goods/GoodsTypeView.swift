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
    @State private var selectedCategoryURL = ""
    var selectedCategory: GoodsCategory? { categories.first { $0.objectURL == selectedCategoryURL } }

    var type: GoodsType?
    var item: Item?

    init() {}

    init(type: GoodsType) {
        self.type = type
        _typeTitle = State(wrappedValue: type.wrappedTitle)
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
                CategoryPicker<GoodsCategory>("Category", selection: $selectedCategoryURL)
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
            dataController.updateGoodsType(type.objectID, title: typeTitle, categoryID: selectedCategory?.objectID)
        } else {
            dataController.createGoodsType(with: typeTitle, linkedTo: item?.objectID, categoryID: selectedCategory?.objectID)
        }
    }
}


struct GoodsTypeView_Previews: PreviewProvider {
    static var previews: some View {
        GoodsTypeView(type: GoodsType.example)
    }
}
