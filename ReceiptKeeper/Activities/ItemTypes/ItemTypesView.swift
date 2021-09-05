//
//  ItemTypesView.swift
//  ItemTypesView
//
//  Created by Andrei Chenchik on 1/9/21.
//

import SwiftUI

struct ItemTypesView: View {
    static let tag: String? = "Types"

    let dataController = DataController.shared

    @SectionedFetchRequest<ItemCategory?, ItemType>(
        sectionIdentifier: \.category,
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemType.title, ascending: false)],
        animation: .default
    )
    private var sectionedTypes

    @State private var showingNewItemTypeScreen = false

    var body: some View {
        NavigationView {
            List {
                ForEach(sectionedTypes) { section in
                    Section(header: Text(section.id?.title ?? "Unknown category")) {
                        ForEach(section, content: itemTypeRow)
                            .onDelete { indexSet in
                                let objectIDs = indexSet.map { section[$0].objectID }
                                dataController.delete(objectIDs)
                            }
                    }
                }
            }
            .sheet(isPresented: $showingNewItemTypeScreen) { newItemTypeSheet }
            .toolbar { newItemTypeButton }
            .navigationTitle("Categories")
        }
    }

    func itemTypeRow(type: ItemType) -> some View {
        NavigationLink(destination: ItemTypeView(type: type)) {
            HStack {
                if let typeIcon = type.typeIcon {
                    Text("\(typeIcon)")
                        .font(.title2)
                        .frame(width: 30)

                    Text(type.typeTitleWithoutIcon)
                } else {
                    Text(type.wrappedTitle)
                }

                Spacer()

                Text(type.typeItemsSumString)
                Text("€")
            }
        }
    }

    var newItemTypeButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showingNewItemTypeScreen = true
            }) {
                Label("Add item type", systemImage: "plus")
            }
        }
    }

    var newItemTypeSheet: some View {
        NavigationView {
            ItemTypeView()
                .toolbar {
                    Button("Cancel") {
                        showingNewItemTypeScreen = false
                    }
                }
        }
    }
}

struct ItemTypesView_Previews: PreviewProvider {
    static var previews: some View {
        ItemTypesView()
    }
}
