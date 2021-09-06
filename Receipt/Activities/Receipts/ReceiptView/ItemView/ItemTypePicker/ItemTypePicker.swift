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

    @FetchRequest<GoodsType>(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \GoodsType.category, ascending: false),
            NSSortDescriptor(keyPath: \GoodsType.title, ascending: false)
        ]
    )
    private var types

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

                ForEach(types) { type in
                    Text(type.wrappedTitle).tag(type.objectURL)
                }
            }

//            ForEach(sectionedTypes) { section in
//                Section {
//                    Picker(selection: $viewModel.selectedTypeURL, label: Text("Select item type")) {
//                        ForEach(section) { type in
//                            Text(type.wrappedTitle).tag(type.objectURL)
//                        }
//                    }
//                }
//            }
        } label: {
            Text(viewModel.item.type?.typeIcon ?? "❓")
                .font(.title2)
                .frame(width: 30, height: 30)
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
