//
//  ItemTypeView.swift
//  ItemTypeView
//
//  Created by Andrei Chenchik on 1/9/21.
//

import SwiftUI

struct ItemTypeView: View {
    let dataController = DataController.shared

    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel = ViewModel()

    @FetchRequest<ItemCategory>(
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemCategory.title, ascending: false)]
    )
    private var itemCategories

    @State private var typeTitle = ""
    @State private var selectedCategoryURL = ""
    var type: ItemType?
    var item: Item?


    init() {}

    init(type: ItemType) {
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

            Section(header: Text("Section")) {
                NavigationLink("Hello", destination: ItemCategoryPicker(selectedItemCategoryURL: $selectedCategoryURL))
                Picker("Section", selection: $selectedCategoryURL) {
                    ForEach(itemCategories) { category in
                        Text(category.title ?? "Unknown category").tag(category.objectURL)
                    }
                }

            }

            Button(type == nil ? "Create type" : "Update type") {
                saveChanges()
                dismiss()
            }
            .disabled(typeTitle.isEmpty)
        }
        .navigationTitle(type == nil ? "New type" : "Edit type")
    }

    func saveChanges() {
        let typeTitle = typeTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let type = type {
            dataController.updateItemType(type.objectID, title: typeTitle)
        } else {
            dataController.createItemType(with: typeTitle, linkedTo: item?.objectID)
        }
    }
}


struct ItemTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ItemTypeView(type: ItemType.example)
    }
}
