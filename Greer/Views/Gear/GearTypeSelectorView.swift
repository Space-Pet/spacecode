//
//  GearTypeSelectorView.swift
//  Greer
//
//  Created by Mani Kandan on 2/9/24.
//

import SwiftUI
import SwiftData

struct GearTypeSelectorView: View {
    @State var gear: Gear
    
    var body: some View {
        NavigationStack {
            // sorts gear types by ROYGBIV (rainbow), keeps gray/black/white at bottom
            List(Gear.GearType.allCases.sorted { type1, type2 in
                if type1.typeColor == .gray || type1.typeColor == .black || type1.typeColor == .white {
                    return false
                } else if type2.typeColor == .gray || type2.typeColor == .black || type2.typeColor == .white {
                    return true
                } else {
                    return type1.typeColor.hue < type2.typeColor.hue
                }
            }, id: \.self) { type in
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(type.typeColor)
                            .frame(width: 24, height: 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(type.typeColor)
                                    .saturation(1.5)
                            )
                        
                        Image(systemName: type.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                    }
                    
                    Text(type.rawValue)
                    
                    Spacer()
                    
                    if(gear.type == type) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeIn) {
                        gear.type = type
                    }
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Gear.self, configurations: config)
        
        let g1 = Gear(brand: "hyperlite", model: "southwest 4400", color: "#000000", weight: 10.0, url: "https://www.hyperlitemountaingear.com/products/southwest-40", type: .backpack)
        return GearTypeSelectorView(gear: g1)
            .modelContainer(container)
    } catch {
        fatalError("Failed to make Packdetailsview container")
    }
}
