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

    @SectionedFetchRequest<GoodsCategory?, GoodsType>(
        sectionIdentifier: \.category,
        sortDescriptors: [NSSortDescriptor(keyPath: \GoodsType.title, ascending: false)],
        animation: .default
    )
    private var sectionedTypes

    @State private var showingNewGoodsTypeScreen = false

    var body: some View {
        NavigationView {
            List {
                ForEach(sectionedTypes) { section in
                    Section {
                        ForEach(section, content: goodsTypeRow)
                    }
                }

                ForEach(sectionedTypes) { section in
                    Section(header: Text(section.id?.title ?? "Unknown category")) {
                        ForEach(section, content: goodsTypeRow)
                            .onDelete { indexSet in
                                let objectIDs = indexSet.map { section[$0].objectID }
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

    func goodsTypeRow(type: GoodsType) -> some View {
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
