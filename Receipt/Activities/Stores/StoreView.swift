//
//  StoreView.swift
//  StoreView
//
//  Created by Andrei Chenchik on 30/8/21.
//

import SwiftUI

struct StoreView: View {
    let dataController = DataController.shared

    @Environment(\.dismiss) var dismiss

    @State private var storeTitle = ""

    @FetchRequest<StoreCategory>(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreCategory.title, ascending: false)]
    )
    private var categories
    @State private var selectedCategoryURL = ""
    var selectedCategory: StoreCategory? { categories.first { $0.objectURL == selectedCategoryURL } }

    var store: Store?
    var receipt: Receipt?

    init() {}

    init(store: Store) {
        self.store = store
        _storeTitle = State(wrappedValue: store.wrappedTitle)
        _selectedCategoryURL = State(wrappedValue: store.category?.objectURL ?? "")
    }

    init(receipt: Receipt, storeTitle: String) {
        self.receipt = receipt
        _storeTitle = State(wrappedValue: storeTitle)
    }

    var body: some View {
        Form {
            Section(header: Text("Title"),
                    footer: Text("If you will add EMOJI in the beginning of the title - it will became an icon of that store. How cool is that?!")) {
                TextField("Store Title", text: $storeTitle,
                          prompt: Text("🚀 Super-store"))
            }

            Section {
                RelationPicker<StoreCategory>("Category", selection: $selectedCategoryURL)
            }

            Button(store == nil ? "Create store" : "Update store") {
                saveChanges()
                dismiss()
            }
            .disabled(storeTitle.isEmpty || selectedCategory == nil)
        }
        .navigationTitle(store == nil ? "New store" : "Edit store")
    }

    func saveChanges() {
        let storeTitle = storeTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        if let store = store {
            dataController.updateStore(store.objectID, title: storeTitle, categoryID: selectedCategory?.objectID)
        } else {
            dataController.createStore(with: storeTitle, linkedTo: receipt?.objectID, categoryID: selectedCategory?.objectID)
        }
    }
}


struct StoreEditView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView(store: Store.example)
    }
}
