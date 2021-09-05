//
//  ContentView.swift
//  ReceiptKeeper
//
//  Created by Andrei Chenchik on 4/8/21.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @SceneStorage("selectedView") var selectedView: String?

    @EnvironmentObject var dataController: DataController

    var body: some View {
        TabView(selection: $selectedView) {
            ReceiptsView()
                .tag(ReceiptsView.tag)
                .tabItem { Label("Receipts", systemImage: "doc.on.doc") }
            ItemTypesView()
                .tag(ItemTypesView.tag)
                .tabItem { Label("Item types", systemImage: "list.star") }
            StoresView()
                .tag(StoresView.tag)
                .tabItem { Label("Stores", systemImage: "crown") }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
