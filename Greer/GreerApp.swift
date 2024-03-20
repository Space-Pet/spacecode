//
//  GreerApp.swift
//  Greer
//
//  Created by Mani Kandan on 1/31/24.
//

import SwiftUI
import SwiftData

@main
struct GreerApp: App {
    var body: some Scene {
        WindowGroup {
//            TabsView()
//            KavoTabsView()
            NigelTabsView()
//            YgerasTabsView()
        }
        .modelContainer(for: Pack.self)
    }
}
