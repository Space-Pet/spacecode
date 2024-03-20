//
//  CircleChartView.swift
//  Greer
//
//  Created by Mani Kandan on 3/7/24.
//

import SwiftUI

class TimerManager: ObservableObject {
    @Published var showValue = false
    @Published var displayedValue = 0.0
    var value = 0.75
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [self] Timer in
            if (showValue) {
                if (self.displayedValue < self.value) {
                    self.displayedValue += 0.01
                } else {
                    Timer.invalidate()
                }
            }
            else {
                if (self.displayedValue > 0) {
                    self.displayedValue -= 0.01
                } else {
                    Timer.invalidate()
                }
            }
        }
    }
}

struct CircleChartView: View {
    @ObservedObject var tm = TimerManager()
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 24)
                .frame(width: 200, height: 200)
                .foregroundStyle(.white)
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
            Circle()
                .trim(from: 0, to: tm.showValue ? tm.value : 0)
                .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            
            NumValue(displayedValue: tm.displayedValue, color: .black)
        }
        .onTapGesture {
            withAnimation(.spring.speed(0.2)) {
                tm.showValue.toggle()
                tm.startTimer()
            }
        }
    }
}

struct NumValue: View {
    var displayedValue: CGFloat
    var color: Color
    
    var body: some View {
        Text("\(Int(displayedValue * 100))%")
            .font(.largeTitle)
            .bold()
            .foregroundStyle(color)
    }
}

#Preview {
    CircleChartView()
        .environmentObject(TimerManager())
}
