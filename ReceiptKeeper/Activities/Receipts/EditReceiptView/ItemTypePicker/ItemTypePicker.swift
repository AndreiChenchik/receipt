//
//  ItemTypePicker.swift
//  ItemTypePicker
//
//  Created by Andrei Chenchik on 2/9/21.
//

import SwiftUI

struct ItemTypePicker: View {
    @EnvironmentObject var dataController: DataController

    var item: Item

    var body: some View {
        InnerView(item: item, dataController: dataController)
    }
}


extension ItemTypePicker {
    struct InnerView: View {
        @ObservedObject var item: Item
        @StateObject var viewModel: ViewModel

        init(item: Item, dataController: DataController) {
            let viewModel = ViewModel(item: item, dataController: dataController)
            _viewModel = StateObject(wrappedValue: viewModel)
            _item = ObservedObject(wrappedValue: item)
        }

        var body: some View {
            Menu {
//                Section {
//                    Button {
//                        print("new!")
//                    } label: {
//                        Label("Add new type", systemImage: "plus")
//                    }
//                }

                Picker(selection: $viewModel.selectedTypeIndex, label: Text("Select item type")) {
                    Text("Not selected").tag(-1)
                    ForEach(0..<viewModel.types.count) { index in
                        Text(viewModel.types[index].typeTitle).tag(index)
                    }
                }
            } label: {
                Text(viewModel.selectedTypeIcon)
                    .font(.title2)
                    .frame(width: 30, height: 30)
            }
        }
    }
}
