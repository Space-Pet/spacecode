//
//  Utils.swift
//  Greer
//
//  Created by Mani Kandan on 2/8/24.
//

import Foundation
import SwiftUI
import UIKit

struct Utils {
    let monoFont = Font
        .system(size: 12)
        .monospaced()
}

extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
    
    var hue: CGFloat {
        var hue: CGFloat = 0.0
        UIColor(self).getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }
    
    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}

struct SectionHeader: View {
    
    @State var title: String
    @Binding var isOn: Bool
    @State var onLabel: String
    @State var offLabel: String
    
    var body: some View {
        Button(action: {
            withAnimation {
                isOn.toggle()
            }
        }, label: {
            if isOn {
                Text(onLabel)
            } else {
                Text(offLabel)
            }
        })
        .font(Font.caption)
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .overlay(
            Text(title),
            alignment: .leading
        )
    }
}

public func rainbowOrderIndex(for color: Color) -> Int {
    let rainbowColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    guard let index = rainbowColors.firstIndex(of: color) else {
        return rainbowColors.count // Place non-rainbow colors at the end
    }
    return index
}

func getWeightColor(weight: Double, weightUnit: Gear.WeightUnit) -> (background: Color, border: Color, weightClass: String) {
    let classificationBoundsInPounds: [Double] = [
        5.0, // Super UL upper bound
        10.0, // Ultralight upper bound
        20.0 // Light upper bound
    ]
    
    var convertedWeightInPounds: Double
    
    switch weightUnit {
    case .ounces:
        convertedWeightInPounds = weight / 16.0 // Convert to pounds
    case .grams:
        convertedWeightInPounds = weight / 453.592 // Convert to pounds
    case .kilograms:
        convertedWeightInPounds = weight * 2.20462 // Convert to pounds
    case .pounds:
        convertedWeightInPounds = weight // No conversion needed
    }
    
    if convertedWeightInPounds == 0.0 {
        return (.secondary, .secondary, "")
    } else if convertedWeightInPounds < classificationBoundsInPounds[0] {
        return (.blue, .blue, "Super UL")
    } else if convertedWeightInPounds < classificationBoundsInPounds[1] {
        return (.green, .green, "Ultralight")
    } else if convertedWeightInPounds < classificationBoundsInPounds[2] {
        return (.orange, .orange, "Light")
    } else {
        return (.red, .red, "Heavy")
    }
}
