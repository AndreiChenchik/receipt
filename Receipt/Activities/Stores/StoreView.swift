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

    var store: Store? = nil
    var receipt: Receipt? = nil

    init() {}

    init(store: Store) {
        self.store = store
        _storeTitle = State(wrappedValue: store.wrappedTitle)
    }

    init(receipt: Receipt, storeTitle: String) {
        self.receipt = receipt
        _storeTitle = State(wrappedValue: storeTitle)
    }

    func saveChanges() {
        let storeTitle = storeTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        if let store = store {
            dataController.updateStore(store.objectID, title: storeTitle)
        } else {
            dataController.createStore(with: storeTitle, linkedTo: receipt?.objectID)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Title"),
                    footer: Text("If you will add EMOJI in the beginning of the title - it will became an icon of that store. How cool is that?!")) {
                TextField("Store Title", text: $storeTitle,
                          prompt: Text("🚀 Super-store"))
            }

            Button(store == nil ? "Create store" : "Update store") {
                saveChanges()
                dismiss()
            }
            .disabled(storeTitle.isEmpty)
        }
        .navigationTitle(store == nil ? "New store" : "Edit store")
    }
}


struct StoreEditView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView(store: Store.example)
    }
}
