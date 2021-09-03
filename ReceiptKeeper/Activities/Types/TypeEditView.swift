//
//  TypeEditView.swift
//  TypeEditView
//
//  Created by Andrei Chenchik on 1/9/21.
//

import SwiftUI

struct TypeEditView: View {
    let dataController = DataController.shared

    @Environment(\.dismiss) var dismiss

    @State private var typeTitle = ""

    var type: ItemType?
    var item: Item?


    init() {}

    init(type: ItemType) {
        self.type = type
        _typeTitle = State(wrappedValue: type.typeTitle)
    }

    init(item: Item) {
        self.item = item
    }

    var body: some View {
        Form {
            Section(header: Text("Title"),
                    footer: Text("If you will add EMOJI in the beginning of the title - it will became an icon of that category. How cool is that?!")) {
                TextField("Category Title", text: $typeTitle,
                          prompt: Text("🚀 Super-category"))
            }

            Button(type == nil ? "Create category" : "Update category") {
                saveChanges()
                dismiss()
            }
            .disabled(typeTitle.isEmpty)
        }
        .navigationTitle(type == nil ? "New category" : "Edit category")
    }

    func saveChanges() {
        let typeTitle = typeTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let type = type {
            dataController.updateItemType(type.objectID, title: typeTitle)
        } else {
            dataController.createItemType(with: typeTitle, linkedTo: item?.objectID)
        }
    }
}


struct TypeEditView_Previews: PreviewProvider {
    static var previews: some View {
        TypeEditView(type: ItemType.example)
    }
}
