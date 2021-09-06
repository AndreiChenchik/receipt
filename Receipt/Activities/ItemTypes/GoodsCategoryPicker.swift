//
//  GoodsCategoryPicker.swift
//  GoodsCategoryPicker
//
//  Created by Andrei Chenchik on 5/9/21.
//

import SwiftUI

struct GoodsCategoryPicker: View {
    @Binding var selectedGoodsCategoryURL: String

    @Environment(\.dismiss) var dismiss

    @FetchRequest<GoodsCategory>(
        sortDescriptors: [NSSortDescriptor(keyPath: \GoodsCategory.title, ascending: false)]
    )
    private var goodsCategories

    @State private var showingNewGoodsCategoryView = false

    var newGoodsCategoryButton: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                showingNewGoodsCategoryView = true
                let category = GoodsCategory(context: DataController.shared.container.viewContext)
                category.title = "test \(Int.random(in: 1...200))"
                DataController.shared.saveIfNeeded()
            }) {
                Label("Add item category", systemImage: "plus")
            }
        }
    }

    var categoriesList: some View {
        List {
            ForEach(goodsCategories) { goodsCategory in
                Button {
                    selectedGoodsCategoryURL = goodsCategory.objectURL
                    dismiss()
                } label: {
                    Text(goodsCategory.title ?? "Unknown")
                }
            }
        }
        .toolbar { newGoodsCategoryButton }
    }

    var body: some View {
        categoriesList
    }
}

//struct GoodsCategoryPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        GoodsCategoryPicker()
//    }
//}
