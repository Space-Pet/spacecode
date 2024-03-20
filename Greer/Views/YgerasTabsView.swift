//
//  YgerasTabsView.swift
//  Greer
//
//  Created by Mani Kandan on 3/15/24.
//

import SwiftUI

struct YgerasTabsView: View {
    @State private var navPath: [String] = []
    
    var body: some View {
        NavigationStack(path: $navPath) {
            Screen1(path: $navPath)
        }
    }
}

struct Screen1: View {
    @Binding var path: [String]

    var body: some View {
        Text("Screen 1")
            .font(.title)
        NavigationLink(value: "View 2") {
            Text("Go to Screen 2")
        }
        .navigationDestination(for: String.self) { pathValue in
            // depending on the value you pass you will navigate accrodingly
            if pathValue == "View 2" {
                Screen2(path: $path)
            } else if pathValue == "View 3" {
                Screen3(path: $path)
            }
        }
    }
}

struct Screen2: View {
    @Binding var path: [String]
    var body: some View {
        Text("Screen 2")
            .font(.title)
        NavigationLink(value: "View 3") {
            Text("Go to Screen 3")
        }
    }
}

struct Screen3: View {
    @Binding var path: [String]
    var body: some View {
        Text("Screen 3")
            .font(.title)
        Button("Back to root") {
            // to navigate to root view you simply pop all the views from navPath
            path.removeAll()
        }
    }
}

#Preview {
    YgerasTabsView()
}
