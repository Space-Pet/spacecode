//
//  CircleTest.swift
//  Greer
//
//  Created by Mani Kandan on 3/7/24.
//

import SwiftUI
import Shimmer

struct CircleTest: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var consumableWeight: Double
    @Binding var wearableWeight: Double
    @Binding var remainingWeight: Double
    
    @State var weightUnit: Gear.WeightUnit
    @State var packWeight: Double
    
    @State private var consumableProgress: CGFloat = 0.0
    @State private var wearableProgress: CGFloat = 0.0
    @State private var remainingProgress: CGFloat = 0.0
    
    @State var temp = 0.0
    
    var body: some View {
        let totalWeight = consumableWeight + wearableWeight + remainingWeight
        
        VStack {
            ZStack {
                Circle()
                    .frame(width: 260, height: 260)
                    .foregroundStyle(.neumorph1)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
                
                Circle()
                    .stroke(lineWidth: 24)
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.neumorph2.opacity(colorScheme == .dark ? 0.1:1.0))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
                
                Circle()
                    .stroke(lineWidth: 0.34)
                    .frame(width: 1, height: 200)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.3), .clear]), startPoint: .bottomTrailing, endPoint: .topLeading))
                    .overlay {
                        Circle()
                            .stroke(.black.opacity(0.1), lineWidth: 2)
                            .blur(radius: 5)
                            .mask {
                                Circle()
                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            }
                    }
                
                // CONSUMABLE
                Circle()
                    .trim(from: 0, to: consumableProgress)
                    .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(.orange)
                
                // WEARABLE
                Circle()
                    .trim(from: consumableProgress, to: wearableProgress)
                    .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(.blue)
                
                // REMAINING
                Circle()
                    .trim(from: wearableProgress, to: remainingProgress)
                    .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(Color.green)
                
                Circle()
                    .frame(width: 154, height: 154)
                    .foregroundStyle(.neumorph3)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
                
                WeightValue(displayedValue: totalWeight, weightUnit: weightUnit)
            }
            
//            Text("consumable: \(consumableWeight)")
//            Text("wearable: \(wearableWeight)")
//            Text("remaining: \(remainingWeight)")
            Text("circle total: \(totalWeight) \(weightUnit)")
            Text("packWeight: \(packWeight) \(weightUnit)")
        }
        .onAppear {
            updateProgress()
        }
        .onChange(of: consumableWeight, { oldValue, newValue in
            updateProgress()
        }).onChange(of: wearableWeight, { oldValue, newValue in
            updateProgress()
        }).onChange(of: remainingWeight, { oldValue, newValue in
            updateProgress()
        })
    }
    
    private func updateProgress() {
        let totalWeight = consumableWeight + wearableWeight + remainingWeight
        let animationDuration: Double = 0.2
        let delayBetweenAnimations: Double = 0.2 // Small delay to ensure the animations appear continuous
        
        withAnimation(Animation.easeInOut(duration: animationDuration)) {
            self.consumableProgress = CGFloat(consumableWeight / totalWeight)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + delayBetweenAnimations) {
            withAnimation(Animation.easeInOut(duration: animationDuration)) {
                self.wearableProgress = CGFloat((consumableWeight + wearableWeight) / totalWeight)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (animationDuration * 2) + (delayBetweenAnimations * 2)) {
            withAnimation(Animation.easeInOut(duration: animationDuration)) {
                self.remainingProgress = 1.0
            }
        }
    }
}

struct WeightValue: View {
    var displayedValue: CGFloat
    var weightUnit: Gear.WeightUnit
    
    
    var body: some View {
        let temp = getWeightColor(weight: displayedValue, weightUnit: weightUnit)
        
        VStack {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(String(format: "%.2f", displayedValue))
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(temp.background)
                    .contentTransition(.numericText())
                Text(weightUnit.abbreviation)
                    .foregroundStyle(.gray)
            }
            .padding(.bottom, 6)
            
            Text(temp.weightClass)
                .shimmering(
                    active: temp.weightClass == "Super UL" || temp.weightClass == "Ultralight",
                    animation: .easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.2),
                    bandSize: 1.0
                )
                .padding(.horizontal, 6)
                .foregroundStyle(temp.background)
                .background(temp.background.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(lineWidth: 1)
                        .foregroundStyle(temp.border)
                        .saturation(1.5)
                )
        }
    }
}

#Preview {
    CircleTest(consumableWeight: .constant(2.9), wearableWeight: .constant(2.9), remainingWeight: .constant(2.9), weightUnit: .kilograms, packWeight: 234.23)
}
