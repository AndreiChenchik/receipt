//
//  CategoryPicker.swift
//  CategoryPicker
//
//  Created by Andrei Chenchik on 5/9/21.
//

import SwiftUI
import CoreData

struct CategoryPicker<Category: NSManagedObject & ObjectWithTitle & Identifiable>: View {
    let dataController = DataController.shared

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

    @State private var showingPickerView = false
    @State private var showingNewGoodsCategoryView = false
    @State private var newItemTitle = ""
    @FocusState private var selectedNewItemTextField: Bool

    var selectedCategory: Category? { categories.first { $0.objectURL == selection } }
    var selectedCategoryTitle: String { selectedCategory?.title ?? "Please select" }

    var newItemCell: some View {
        Group {
            if showingNewGoodsCategoryView {
                HStack {
                    TextField("New item", text: $newItemTitle)
                        .focused($selectedNewItemTextField)
                    Button("Create") {
                        var category = Category(context: dataController.container.viewContext)
                        category.title = newItemTitle
                        dataController.saveIfNeeded()

                        selection = category.objectURL
                        showingPickerView = false
                        showingNewGoodsCategoryView = false
                        newItemTitle = ""
                    }
                    .disabled(newItemTitle.isEmpty)
                }
            } else {
                Button {
                    showingNewGoodsCategoryView = true
                    selectedNewItemTextField = true
                } label: {
                    Label("Add new", systemImage: "plus")
                }
            }
        }
    }

    var categoriesList: some View {
        List {
            ForEach(categories) { category in
                Button {
                    selection = category.objectURL
                    showingPickerView = false
                } label: {
                    Text(category.title ?? "Unknown category")
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

    var body: some View {
        NavigationLink(isActive: $showingPickerView) {
            categoriesList
        } label: {
            HStack {
                Text(title)

                Spacer()

                Text(selectedCategoryTitle)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CategoryPicker_Previews: PreviewProvider {
    static var previews: some View {
        CategoryPicker<GoodsCategory>("Category", selection: .constant(""))
    }
}
