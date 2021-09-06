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

    @SectionedFetchRequest<StoreCategory?, Store>(
        sectionIdentifier: \.category,
        sortDescriptors: [NSSortDescriptor(keyPath: \Store.title, ascending: false)],
        animation: .default
    )
    private var sectionedStores

    @State private var showingNewStoreView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(sectionedStores) { section in
                    Section(header: Text(section.id?.title ?? "Unknown category")) {
                        ForEach(section, content: storeRow)
                            .onDelete { indexSet in
                                let objectIDs = indexSet.map { section[$0].objectID }
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

    func storeRow(store: Store) -> some View {
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
