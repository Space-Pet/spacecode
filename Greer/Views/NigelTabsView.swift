//
//  NigelTabsView.swift
//  Greer
//
//  Created by Mani Kandan on 3/15/24.
//  https://www.hackingwithswift.com/forums/swiftui/swiftui-pop-to-root-tabview-functionality/24906/24910

import SwiftUI

enum NigelTab: String, CaseIterable {
    case packs, gear
    
    var text: String {
        switch self {
        case .packs:
            "Packs"
        case .gear:
            "Gear"
        }
    }
    
    var icon: String {
        switch self {
        case .packs:
            "backpack"
        case .gear:
            "circle.hexagongrid.circle"
        }
    }
}

// CustomTabView
struct CustomTabView: View {
    @Binding var selectedTab: NigelTab
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                ForEach(NigelTab.allCases, id: \.self) { tab in
                    Spacer()
                    
                    Button {
                        if selectedTab == tab {
                            print("selectedTab == tab here...")
                            action() // action() moved under this logic to only pop to root if you're tapping on the tab you're on
                        }
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: tab.icon)
                                .symbolVariant(.fill)
                                .imageScale(.large)
                            Text(tab.text)
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(selectedTab == tab ? .blue : .secondary)
                    
                    Spacer()
                }
            }
        }
    }
}

// ContentView
struct NigelTabsView: View {
    @State private var selectedTab = NigelTab.packs
    @State private var packsPath = NavigationPath()
    @State private var gearPath = NavigationPath()
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TabOneView(path: $packsPath)
                    .tag(NigelTab.packs)
                
                GearLockerView(path: $gearPath)
                    .tag(NigelTab.gear)
            }
            
            CustomTabView(selectedTab: $selectedTab) {
                // this is "action()"
                if selectedTab == .gear {
                    gearPath = NavigationPath()
                    print("clicked gear")
                }
            }
        }
    }
}

struct TabOneView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                NavigationLink("Page 1", value: 2)
            }
            .navigationDestination(for: Int.self) { number in
                PageTwoView(path: $path, number: number)
            }
        }
        
    }
}

struct PageTwoView: View {
    @Binding var path: NavigationPath
    let number: Int
    
    var body: some View {
        Text("Page \(number)")
    }
}

struct TabTwoView: View {
    var body: some View {
        Text("Tab Two")
    }
}

#Preview {
    NigelTabsView()
}
