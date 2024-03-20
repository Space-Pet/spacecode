//
//  Pack.swift
//  Greer
//
//  Created by Mani Kandan on 1/31/24.
//

import Foundation
import SwiftData

@Model
class Pack {
    let id: String = UUID().uuidString
    var name: String = ""
    var createdDate: Date = Date.now
    @Relationship(deleteRule: .cascade) var gearInPack: [GearInPack] = [GearInPack]()
    
    var randomIcon: [[Double]] = [
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0]
    ]
    
    var weight: Double {
        let totalWeightInOunces = gearInPack.reduce(into: 0.0) { total, gearInPackItem in
            let gearWeightInOunces = gearInPackItem.gear.convertWeight(currentUnit: gearInPackItem.gear.weightUnit, desiredUnit: .ounces, currentWeight: gearInPackItem.gear.weight)
            total += gearWeightInOunces * Double(gearInPackItem.quantity)
        }
        
        // If weightUnit is pounds, convert total weight to pounds
        switch weightUnit {
        case .ounces:
            return totalWeightInOunces
        case .pounds:
            return totalWeightInOunces / 16.0
        case .grams:
            return totalWeightInOunces * 28.3495
        case .kilograms:
            return totalWeightInOunces * 0.0283495
        }
    }
    var consumableWeight: Double = 0.0
    var wearableWeight: Double = 0.0
    var remainingWeight: Double = 0.0
    @Relationship(deleteRule: .cascade) var weightUnit: Gear.WeightUnit = SettingsManager.shared.defaultPackWeightUnit
    var startDate: Date = Date.now
    var endDate: Date = Date.now.addingTimeInterval(432000)
    
    init(name: String = "", createdDate: Date = .now) {
        self.name = name
        self.createdDate = createdDate
        randomIcon = [
            [Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1)],
            [Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1)],
            [Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1)]
        ]
    }
    
    init(weightUnit: Gear.WeightUnit, name: String = "", createdDate: Date = .now) {
        self.weightUnit = weightUnit
        self.name = name
        self.createdDate = createdDate
        randomIcon = [
            [Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1)],
            [Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1)],
            [Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1)]
        ]
    }
    
    func updateWeights() {
        let categorizedWeights = getCategorizedWeights()
        consumableWeight = categorizedWeights.consumable
        wearableWeight = categorizedWeights.wearable
        remainingWeight = categorizedWeights.remaining
    }
    
    func getCategorizedWeights() -> (consumable: Double, wearable: Double, remaining: Double) {
        var consumableWeight: Double = 0
        var wearableWeight: Double = 0
        var remainingWeight: Double = 0
        
        for gearInPack in gearInPack {
            let gear = gearInPack.gear
            var gearWeightInStandardUnit = gear.weight
            if gear.weightUnit != weightUnit {
                gearWeightInStandardUnit = gear.convertWeight(currentUnit: gear.weightUnit, desiredUnit: weightUnit, currentWeight: gear.weight)
            }
            if gear.consumable {
                consumableWeight += gearWeightInStandardUnit
            } else if gear.worn {
                wearableWeight += gearWeightInStandardUnit
            } else {
                remainingWeight += gearWeightInStandardUnit
            }
        }
        
        return (consumableWeight, wearableWeight, remainingWeight)
    }
}
