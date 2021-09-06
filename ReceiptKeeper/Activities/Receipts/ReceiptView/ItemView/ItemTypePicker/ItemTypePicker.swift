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
                ForEach(viewModel.types) { type in
                    Text(type.wrappedTitle).tag(type.objectURL)
                }
            }
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
