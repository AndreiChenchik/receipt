//
//  ItemCategoryPicker.swift
//  ItemCategoryPicker
//
//  Created by Andrei Chenchik on 5/9/21.
//

import SwiftUI

struct ItemCategoryPicker: View {
    @Binding var selectedItemCategoryURL: String

    @Environment(\.dismiss) var dismiss

    @FetchRequest<ItemCategory>(
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemCategory.title, ascending: false)]
    )
    private var itemCategories

    @State private var showingNewItemCategoryView = false

    var newItemCategoryButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showingNewItemCategoryView = true
                let category = ItemCategory(context: DataController.shared.container.viewContext)
                category.title = "test \(Int.random(in: 1...200))"
                DataController.shared.saveIfNeeded()
            }) {
                Label("Add item category", systemImage: "plus")
            }
        }
    }

    var body: some View {
        List {
            ForEach(itemCategories) { itemCategory in
                Button {
                    selectedItemCategoryURL = itemCategory.objectURL
                    dismiss()
                } label: {
                    Text(itemCategory.title ?? "Unknown")
                }
            }
        }
        .toolbar { newItemCategoryButton }
        
    }
}

//struct ItemCategoryPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemCategoryPicker()
//    }
//}
