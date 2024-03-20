//
//  Gear.swift
//  Greer
//
//  Created by Mani Kandan on 1/31/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Gear: Identifiable {
    let id = UUID().uuidString
    var brand: String = ""
    var model: String = ""
    //    var color: String = ""
    var color: String = "#000000"
    var weight: Double = 0.0
    @Relationship(deleteRule: .cascade) var weightUnit: WeightUnit = SettingsManager.shared.defaultGearWeightUnit
    var desc: String = ""
    var url: String = ""
    var worn: Bool = false
    var consumable: Bool = false
    @Relationship(deleteRule: .cascade) var type: GearType = GearType.backpack
    
    init(brand: String = "", model: String = "", color: String = "#000000", weight: CGFloat = 0.0, weightUnit: WeightUnit = WeightUnit.ounces, desc: String = "", url: String = "", worn: Bool = false, consumable: Bool = false, type: GearType = GearType.backpack) {
        self.brand = brand
        self.model = model
        self.color = color
        self.weight = weight
        self.weightUnit = weightUnit
        self.url = url
        self.desc = desc
        self.worn = worn
        self.consumable = consumable
        self.type = type
    }
    
    enum WeightUnit: String, CaseIterable, Codable {
        case ounces
        case pounds
        case grams
        case kilograms
        
        var abbreviation: String {
            switch self {
            case .ounces:
                return "oz"
            case .pounds:
                return "lb"
            case .grams:
                return "g"
            case .kilograms:
                return "kg"
            }
        }
    }
    
    enum GearType: String, CaseIterable, Codable {
        case backpack
        case clothing
        case tent
        case sleep
        case electronic
        case cooking
        case safety
        case water
        case food
        case lighting
        case climbing
        case footwear
        case tools
        case hygiene
        case fun
        
        var icon: String {
            switch self {
            case .backpack:
                return "backpack.fill"
            case .clothing:
                return "tshirt.fill"
            case .tent:
                return "tent.fill"
            case .sleep:
                return "bed.double.fill"
            case .electronic:
                return "battery.100.bolt"
            case .cooking:
                return "frying.pan.fill"
            case .safety:
                return "cross.vial.fill"
            case .water:
                return "waterbottle.fill"
            case .lighting:
                return "flashlight.on.fill"
            case .climbing:
                return "figure.climbing"
            case .footwear:
                return "shoe.fill"
            case .tools:
                return "wrench.and.screwdriver.fill"
            case .hygiene:
                return "hands.and.sparkles.fill"
            case .fun:
                return "popcorn.fill"
            case .food:
                return "carrot.fill"
            }
        }
        
        var typeColor: Color {
            switch self {
            case .backpack:
                return Color.red
            case .clothing:
                return Color.blue
            case .tent:
                return Color.indigo
            case .sleep:
                return Color.indigo
            case .electronic:
                return Color.green
            case .food:
                return Color.orange
            case .cooking:
                return Color.cyan
            case .safety:
                return Color.red
            case .water:
                return Color.teal
            case .lighting:
                return Color.yellow
            case .climbing:
                return Color.brown
            case .footwear:
                return Color.purple
            case .tools:
                return Color.gray
            case .hygiene:
                return Color.pink
            case .fun:
                return Color.mint
            }
        }
    }
    
    enum DefaultColors: String, CaseIterable {
        case black = "#000000"
        case white = "#FFFFFF"
        case gray = "#808080"
        case red = "#FF0000"
        case green = "#00FF00"
        case blue = "#0000FF"
        case orange = "#FFA500"
        case yellow = "#FFFF00"
        case purple = "#800080"
        case pink = "#FFC0CB"
    }
    
    public func convertWeight(currentUnit: WeightUnit, desiredUnit: WeightUnit, currentWeight: Double) -> Double {
        //        print("converting \(currentWeight) \(currentUnit) to \(desiredUnit)")
        
        // Define conversion factors in a dictionary
        let conversionFactors: [WeightUnit: [WeightUnit: Double]] = [
            .ounces: [.pounds: 1.0 / 16.0, .grams: 28.3495, .kilograms: 0.0283495],
            .pounds: [.ounces: 16.0, .grams: 453.592, .kilograms: 0.453592],
            .grams: [.ounces: 1.0 / 28.3495, .pounds: 1.0 / 453.592, .kilograms: 0.001],
            .kilograms: [.ounces: 1.0 / 0.0283495, .pounds: 2.20462, .grams: 1000.0]
        ]
        
        // Retrieve conversion factor from the dictionary
        guard let conversionFactor = conversionFactors[currentUnit]?[desiredUnit] else {
            return currentWeight // No conversion needed
        }
        
        // Apply conversion factor
        return currentWeight * conversionFactor
    }
}
