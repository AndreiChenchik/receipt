//
//  ReceiptKeeperApp.swift
//  ReceiptKeeper
//
//  Created by Andrei Chenchik on 4/8/21.
//

import SwiftUI

@main
struct ReceiptKeeperApp: App {
    @StateObject private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataController)
        }
    }
}
