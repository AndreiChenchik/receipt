//
//  RelationPicker.swift
//  RelationPicker
//
//  Created by Andrei Chenchik on 5/9/21.
//

import SwiftUI
import CoreData

struct RelationPicker<Relation: NSManagedObject & ObjectWithTitle & Identifiable>: View {
    let title: String
    let navigationTitle: String
    @Binding var selection: String

    init(_ title: String, selection: Binding<String>, navigationTitle: String = "Select category") {
        self.title = title
        self._selection = selection
        self.navigationTitle = navigationTitle
    }

    @FetchRequest<Relation>(
        sortDescriptors: []
    )
    private var relations

    var sortedRelations: [Relation] {
        relations.sorted { $0.title ?? "" < $1.title ?? "" }
    }

    var selectedRelation: Relation? { relations.first { $0.objectURL == selection } }
    var selectedRelationTitle: String { selectedRelation?.title ?? "Please select" }

    var body: some View {
        NavigationLink {
            RelationsList(navigationTitle: navigationTitle, categories: sortedRelations, selection: $selection)
        } label: {
            HStack {
                Text(title)

                Spacer()

                Text(selectedRelationTitle)
                    .foregroundColor(.secondary)
            }
        }
    }

    struct RelationsList: View {
        let dataController = DataController.shared

        let navigationTitle: String
        let categories: [Relation]
        @Binding var selection: String

        @Environment(\.dismiss) var dismiss

        @State private var newItemTitle = ""
        @State private var showingNewCategoryTextField = false

        var body: some View {
            List {
                ForEach(categories) { category in
                    Button {
                        selection = category.objectURL
                        dismiss()
                    } label: {
                        HStack {
                            Text(category.title ?? "Unknown")

                            Spacer()

                            if selection == category.objectURL {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                .onDelete { indexSet in
                    let objectIDs = indexSet.map { categories[$0].objectID }
                    dataController.delete(objectIDs)
                }

                newItemCell
            }
            .navigationTitle(navigationTitle)
        }

        var newItemCell: some View {
            Group {
                if showingNewCategoryTextField {
                    HStack {
                        TextField("New item", text: $newItemTitle)

                        Button("Create") {
                            var category = Relation(context: dataController.container.viewContext)
                            category.title = newItemTitle

                            newItemTitle = ""
                            showingNewCategoryTextField = false

                            dataController.saveIfNeeded()

                            selection = category.objectURL
                            dismiss()
                        }
                        .disabled(newItemTitle.isEmpty)
                    }
                } else {
                    Button {
                        showingNewCategoryTextField = true
                    } label: {
                        Label("Add new", systemImage: "plus")
                    }
                }
            }
        }
    }
}

struct RelationPicker_Previews: PreviewProvider {
    static var previews: some View {
        RelationPicker<GoodsCategory>("Category", selection: .constant(""))
    }
}
