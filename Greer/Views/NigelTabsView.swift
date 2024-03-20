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
    
    @State private var tab1Id = UUID()
    @State private var tab2Id = UUID()
    
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationView{
                    TabOneView(path: $packsPath)
                        .tag(NigelTab.packs)
                }.id(tab1Id)
                
                GearLockerView(path: $gearPath)
                    .tag(NigelTab.gear)
                    .id(tab2Id)
            }
            
            CustomTabView(selectedTab: $selectedTab) {
                // this is "action()"
                if selectedTab == .gear {
                    gearPath = NavigationPath()
                    tab2Id = UUID()
                    print("clicked gear")
                } else if selectedTab == .packs {
                    
                    tab1Id = UUID()
                    print("clicked packs")
                }
            }
        }
    }
}

struct TabOneView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            NavigationLink(destination:   PageTwoView( number: 2)) {
                Text("Go To Page 2")
            }
        }
        
        
    }
}

struct PageTwoView: View {
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

//#Preview {
//    NigelTabsView()
//}
