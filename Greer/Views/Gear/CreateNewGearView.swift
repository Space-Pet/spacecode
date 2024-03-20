//
//  CreateNewGearView.swift
//  Greer
//
//  Created by Mani Kandan on 3/13/24.
//

import SwiftUI

struct CreateNewGearView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @State var newGear = Gear()
    @AppStorage("defaultGearWeightUnit") var defaultGearWeightUnit: Gear.WeightUnit = .ounces
    
    @State var showToast = false
    @State var toastTitle = ""
    @State var toastIcon = ""
    @State var toastColor: Color = .red
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("Add new gear")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("Save") {
                        addNewGear()
                    }
                    .disabled(!requiredFields)
                    .buttonStyle(.bordered)
                    .foregroundColor(requiredFields ? .green.opacity(0.8) : .red.opacity(0.6))
                    .animation(.spring, value: requiredFields)
                }
                .padding()
            }
            GearFields(gear: newGear)
                .popup(isPresented: $showToast) {
                    popup
                } customize: {
                    $0
                        .type(.floater())
                        .position(.bottom)
                        .appearFrom(.bottom)
                        .animation(.interpolatingSpring)
                        .autohideIn(2)
                }
        }
        .onAppear {
            newGear.weightUnit = defaultGearWeightUnit
        }
    }
    
    var requiredFields: Bool {
        !newGear.brand.isEmpty && !newGear.model.isEmpty && !newGear.type.rawValue.isEmpty
    }
    
    var popup: some View {
        HStack {
            Image(systemName: toastIcon)
                .resizable()
                .foregroundStyle(toastColor.opacity(0.7))
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            Text(toastTitle)
                .font(.subheadline)
                .bold()
        }
        .foregroundStyle(.secondary)
        .frame(width: 200, height: 60)
        .background(toastColor.opacity(0.05))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    func addNewGear() {
        context.insert(newGear)
        newGear = Gear()
        
        do {
            try context.save()
            callToast(title: "Added gear", icon: "checkmark.circle.fill", color: .green)
            dismiss()
        } catch {
            print("error while context saving after adding new *custom* gear to gearlockerview")
        }
    }
    
    func callToast(title: String, icon: String, color: Color) {
        toastTitle = title
        toastIcon = icon
        toastColor = color
        showToast.toggle()
    }
}

#Preview {
    CreateNewGearView()
}
