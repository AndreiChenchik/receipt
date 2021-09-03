//
//  TypesView.swift
//  TypesView
//
//  Created by Andrei Chenchik on 1/9/21.
//

import SwiftUI

struct TypesView: View {
    static let tag: String? = "Types"
    
    @StateObject var viewModel = ViewModel()

    @State private var isShowingNewItemTypeScreen = false

    var newItemTypeButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            NavigationLink(destination: TypeEditView(), isActive: $isShowingNewItemTypeScreen) {
                Button(action: {
                    isShowingNewItemTypeScreen = true
                }) {
                    Label("Add item type", systemImage: "plus")
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.types, id: \.self) { type in
                    NavigationLink(destination: TypeEditView(type: type)) {
                        HStack {
                            if let typeIcon = type.typeIcon {
                                Text("\(typeIcon)")
                                    .font(.title2)
                                    .frame(width: 30)

                                Text(type.typeTitleWithoutIcon)
                            } else {
                                Text(type.typeTitle)
                            }

                            Spacer()

                            Text(type.typeItemsSumString)
                            Text("€")
                        }
                    }
                }
                .onDelete(perform: viewModel.delete)
            }
            .toolbar {
                newItemTypeButton
            }
            .navigationTitle("Categories")
        }
    }
}

struct TypesView_Previews: PreviewProvider {
    static var previews: some View {
        TypesView()
    }
}
