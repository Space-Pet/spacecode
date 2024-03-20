//
//  DashCircle.swift
//  Greer
//
//  Created by Mani Kandan on 3/7/24.
//

import SwiftUI

struct DashCircle: View {
    @ObservedObject var tm = TimerManager()
    
    var body: some View {
        ZStack {
            Color(.black.opacity(0.8))
            
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 20, dash: [3, 4.5]))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: tm.showValue ? tm.value : 0)
                    .stroke(style: StrokeStyle(lineWidth: 20, dash: [3, 4.5]))
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.green)
                
                Circle()
                    .trim(from: 0, to: tm.showValue ? tm.value : 0)
                    .stroke(style: StrokeStyle(lineWidth: 20, dash: [3, 4.5]))
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.green)
                    .blur(radius: 15)
            }
            .rotationEffect(.degrees(-90))
            
            NumValue(displayedValue: tm.displayedValue, color: .white)
        }
        .ignoresSafeArea()
        .onTapGesture {
            withAnimation(.spring.speed(0.2)) {
                tm.showValue.toggle()
                tm.startTimer()
            }
        }
    }
}

#Preview {
    DashCircle()
        .environmentObject(TimerManager())
}
