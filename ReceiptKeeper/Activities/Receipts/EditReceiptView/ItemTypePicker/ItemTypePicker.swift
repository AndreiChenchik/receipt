//
//  ItemTypePicker.swift
//  ItemTypePicker
//
//  Created by Andrei Chenchik on 2/9/21.
//

import SwiftUI

struct ItemTypePicker: View {
    @EnvironmentObject var dataController: DataController

    @ObservedObject var item: Item

    @StateObject var viewModel: ViewModel

    @State var showingNewItemTypeView = false

    init(item: Item) {
        _item = ObservedObject(wrappedValue: item)
        _viewModel = StateObject(wrappedValue: ViewModel(item: item))
    }

    var body: some View {
        Menu {
            Section {
                Button {
                    showingNewItemTypeView = true
                } label: {
                    Label("Add new type", systemImage: "plus")
                }
            }

            Picker(selection: $viewModel.selectedTypeURL, label: Text("Select item type")) {
                Text("Not selected").tag("")
                ForEach(viewModel.types) { type in
                    Text(type.typeTitle).tag(type.objectID.uriRepresentation().absoluteString)
                }
            }
        } label: {
            Text(viewModel.selectedTypeIcon)
                .font(.title2)
                .frame(width: 30, height: 30)
        }
        .sheet(isPresented: $showingNewItemTypeView) {
            NavigationView{
                TypeEditView(item: item)
                    .toolbar {
                        Button("Dismiss") {
                            showingNewItemTypeView = false
                        }
                    }
            }
        }
    }
}
