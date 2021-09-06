//
//  GoodsTypesView.swift
//  GoodsTypesView
//
//  Created by Andrei Chenchik on 1/9/21.
//

import SwiftUI

struct GoodsTypesView: View {
    static let tag: String? = "Goods"

    let dataController = DataController.shared

    @FetchRequest<GoodsCategory>(sortDescriptors: [])
    private var categories

    @FetchRequest<GoodsType>(sortDescriptors: [
        NSSortDescriptor(keyPath: \GoodsType.title, ascending: false)
    ])
    private var types

    var sectionedTypes: [(key: GoodsCategory?, value: [GoodsType])] {
        Dictionary(grouping: types, by: { $0.category })
            .sorted { $0.key?.title ?? "" < $1.key?.title ?? "" }
    }

    @State private var showingNewGoodsTypeScreen = false

    var body: some View {
        return NavigationView {
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
            .sheet(isPresented: $showingNewGoodsTypeScreen) { newGoodsTypeSheet }
            .toolbar { newGoodsTypeButton }
            .navigationTitle("Types of goods")
        }
    }

    func row(type: GoodsType) -> some View {
        NavigationLink(destination: GoodsTypeView(type: type)) {
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

    var newGoodsTypeButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showingNewGoodsTypeScreen = true
            }) {
                Label("Add item type", systemImage: "plus")
            }
        }
    }

    var newGoodsTypeSheet: some View {
        NavigationView {
            GoodsTypeView()
                .toolbar {
                    Button("Cancel") {
                        showingNewGoodsTypeScreen = false
                    }
                }
        }
    }
}

struct GoodsTypesView_Previews: PreviewProvider {
    static var previews: some View {
        GoodsTypesView()
    }
}
