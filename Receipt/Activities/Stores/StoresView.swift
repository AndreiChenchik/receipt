//
//  StoresView.swift
//  StoresView
//
//  Created by Andrei Chenchik on 27/8/21.
//

import SwiftUI

struct StoresView: View {
    static let tag: String? = "Stores"

    let dataController = DataController.shared

    @FetchRequest<StoreCategory>(sortDescriptors: [])
    private var categories

    @FetchRequest<Store>(sortDescriptors: [
        NSSortDescriptor(keyPath: \Store.title, ascending: false)
    ])
    private var types

    var sectionedTypes: [(key: StoreCategory?, value: [Store])] {
        Dictionary(grouping: types, by: { $0.category })
            .sorted { $0.key?.title ?? "" < $1.key?.title ?? "" }
    }

    @State private var showingNewStoreView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(sectionedTypes, id: \.key) { section in
                    Section(header: Text(section.key?.title ?? "Unknown category")) {
                        ForEach(section.value, content: row)
                            .onDelete { indexSet in
                                let objectIDs = indexSet.map { section.value[$0].objectID }
                                dataController.delete(objectIDs)
                            }
                    }
                }
            }
            .sheet(isPresented: $showingNewStoreView) { newStoreSheet }
            .toolbar { newStoreButton }
            .navigationTitle("Stores")
        }
    }

    func row(store: Store) -> some View {
        NavigationLink(destination: StoreView(store: store)) {
            HStack {
                if let storeIcon = store.storeIcon {
                    Text("\(storeIcon)")
                        .font(.title2)
                        .frame(width: 30)

                    Text(store.storeTitleWithoutIcon)
                } else {
                    Text(store.wrappedTitle)
                }

                Spacer()

                Text(store.storeReceiptsSumString)
                Text("€")
            }
        }
    }

    var newStoreButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {

            Button(action: {
                showingNewStoreView = true
            }) {
                Label("Add store", systemImage: "plus")
            }

        }
    }

    var newStoreSheet: some View {
        NavigationView {
            StoreView()
                .toolbar {
                    Button("Cancel") {
                        showingNewStoreView = false
                    }
                }
        }
    }
}


struct StoresView_Previews: PreviewProvider {

    static var previews: some View {
        StoresView()
    }
}
