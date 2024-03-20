//
//  KavoTabsView.swift
//  Greer
//
//  Created by Mani Kandan on 3/15/24.
//

import SwiftUI

enum KavoTab: String {
    case packs = "Packs"
    case gear = "Gear"
    
    var icon: String {
        switch self {
        case .packs:
            return "backpack"
        case .gear:
            return "circle.hexagongrid.circle"
        }
    }
}

struct KavoTabsView: View {
    @State private var activeTab: KavoTab = .packs
    @State private var packsStack: NavigationPath = .init()
    @State private var gearStack: NavigationPath = .init()
    
    var body: some View {
//        TabView(selection: $activeTab) {
        TabView(selection: tabSelection) {
            NavigationStack(path: $packsStack) {
                SettingsView()
                    .navigationTitle("Packs")
            }
            .tag(KavoTab.packs)
            .tabItem {
                Image(systemName: KavoTab.packs.icon)
                Text(KavoTab.packs.rawValue)
            }
            
//            NavigationStack(path: $gearStack) {
//                GearLockerView()
//                    .navigationTitle("Gear")
//            }
//            .tag(KavoTab.gear)
//            .tabItem {
//                Image(systemName: KavoTab.gear.icon)
//                Text(KavoTab.gear.rawValue)
//            }
        }
    }
    
    var tabSelection: Binding<KavoTab> {
        return .init {
            return activeTab
        } set: { newValue in
            if newValue == activeTab {
                print("still on \(activeTab)")
                switch newValue {
                case .packs: packsStack = .init()
                case .gear: gearStack = .init()
                }
            }
            activeTab = newValue
        }
    }
}

#Preview {
    KavoTabsView()
}
