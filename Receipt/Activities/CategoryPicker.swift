//
//  CategoryPicker.swift
//  CategoryPicker
//
//  Created by Andrei Chenchik on 5/9/21.
//

import SwiftUI
import CoreData

struct CategoryPicker<Category: NSManagedObject & ObjectWithTitle & Identifiable>: View {
    let title: String
    @Binding var selection: String

    init(_ title: String, selection: Binding<String>) {
        self.title = title
        self._selection = selection
    }

    @FetchRequest<Category>(
        sortDescriptors: []
    )
    private var categories

    var sortedCategories: [Category] {
        categories.sorted { $0.title ?? "" < $1.title ?? "" }
    }

    var selectedCategory: Category? { categories.first { $0.objectURL == selection } }
    var selectedCategoryTitle: String { selectedCategory?.title ?? "Please select" }

    var body: some View {
        NavigationLink {
            CategoriesList(categories: sortedCategories, selection: $selection)
        } label: {
            HStack {
                Text(title)

                Spacer()

                Text(selectedCategoryTitle)
                    .foregroundColor(.secondary)
            }
        }
    }

    struct CategoriesList: View {
        let dataController = DataController.shared

        let categories: [Category]
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
                            Text(category.title ?? "Unknown category")

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
            .navigationTitle("Select category")
        }

        var newItemCell: some View {
            Group {
                if showingNewCategoryTextField {
                    HStack {
                        TextField("New item", text: $newItemTitle)

                        Button("Create") {
                            var category = Category(context: dataController.container.viewContext)
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

struct CategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker<GoodsCategory>("Category", selection: .constant(""))
    }
}
