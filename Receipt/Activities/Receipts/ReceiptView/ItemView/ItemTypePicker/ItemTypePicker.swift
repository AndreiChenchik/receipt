//
//  GoodsTypePicker.swift
//  GoodsTypePicker
//
//  Created by Andrei Chenchik on 2/9/21.
//

import SwiftUI

struct GoodsTypePicker: View {
    @EnvironmentObject var dataController: DataController

    @ObservedObject var item: Item

    //    @SectionedFetchRequest<GoodsCategory?, GoodsType>(
    //        sectionIdentifier: \.category,
    //        sortDescriptors: [NSSortDescriptor(keyPath: \GoodsType.title, ascending: false)],
    //        animation: .default
    //    )
    //    private var sectionedTypes

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

    @StateObject var viewModel: ViewModel

    @State var showingNewGoodsTypeView = false

    init(item: Item) {
        _item = ObservedObject(wrappedValue: item)
        _viewModel = StateObject(wrappedValue: ViewModel(item: item))
    }

    var body: some View {
        Menu {
            Section {
                Button {
                    showingNewGoodsTypeView = true
                } label: {
                    Label("Add new type", systemImage: "plus")
                }
            }

            Picker(selection: $viewModel.selectedTypeURL, label: Text("Select item type")) {
                Text("❓ Not selected").tag("")
            }

            ForEach(sectionedTypes, id: \.key) { section in
                Section {
                    Picker(selection: $viewModel.selectedTypeURL, label: Text("Select item type")) {
                        ForEach(section.value) { type in
                            Text("\(type.wrappedTitle), \(type.unit.abbreviation).").tag(type.objectURL)
                        }
                    }
                }
            }
        } label: {
            Text(viewModel.item.type?.wrappedTitle ?? "Set type")
                .foregroundColor(.primary)
        }
        .sheet(isPresented: $showingNewGoodsTypeView) {
            NavigationView{
                GoodsTypeView(item: item)
                    .toolbar {
                        Button("Dismiss") {
                            showingNewGoodsTypeView = false
                        }
                    }
            }
        }
    }
}
