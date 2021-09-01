//
//  TypeEditView.swift
//  TypeEditView
//
//  Created by Andrei Chenchik on 1/9/21.
//

import SwiftUI

struct TypeEditView: View {
    var type: ItemType? = nil

    @EnvironmentObject var dataController: DataController

    var body: some View {
        InnerView(type: type, dataController: dataController)
    }
}


extension TypeEditView {
    struct InnerView: View {
        var dataController: DataController
        @ObservedObject var type: ItemType

        @Environment(\.presentationMode) var presentationMode

        @State private var typeTitle = ""
        @State private var isNewType = false

        init(type: ItemType?, dataController: DataController) {
            self.dataController = dataController

            if let type = type {
                _type = ObservedObject(wrappedValue: type)
            } else {
                let newType = ItemType(context: dataController.viewContext)
                dataController.saveIfNeeded()

                _type = ObservedObject(wrappedValue: newType)
                _isNewType = State(wrappedValue: true)
            }

            _typeTitle = State(wrappedValue: self.type.title ?? "")
        }

        var saveButton: some ToolbarContent {
            ToolbarItem(placement: .primaryAction) {
                if !(type.title?.isEmpty ?? true) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                    }
                }
            }
        }

        var body: some View {
            Form {
                Section(header: Text("Title"),
                        footer: Text("If you will add EMOJI in the beginning of the title - it will became an icon of that category. How cool is that?!")) {
                    TextField("Category Title", text: $typeTitle.onChange(updateTitle),
                              prompt: Text("🚀 Super-category"))
                }
            }
            .onDisappear(perform: {
                if type.title?.isEmpty ?? true {
                    dataController.delete(type)
                    dataController.saveIfNeeded()
                }
            })
            .toolbar {
                saveButton
            }
            .navigationTitle(isNewType ? "Create vendor" : "Edit vendor")
        }

        func updateTitle() {
            for item in type.typeItems {
                item.objectWillChange.send()
            }
            type.title = typeTitle
            dataController.saveIfNeeded()
        }
    }
}

struct TypeEditView_Previews: PreviewProvider {
    static var previews: some View {
        TypeEditView(type: ItemType.example)
    }
}
