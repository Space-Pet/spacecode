//
//  PacksView.swift
//  Greer
//
//  Created by Mani Kandan on 1/31/24.
//

import SwiftUI
import SwiftData

struct PacksView: View {
    @Environment(\.modelContext) var context
    @Query var packs: [Pack]
    @Query var gears: [Gear]
    
    @State var showAddPackSheet = false
    @AppStorage("defaultPackWeightUnit") var defaultPackWeightUnit: Gear.WeightUnit = .pounds
    @State var newPack = Pack()
    @State private var gearBasket: [String: [Gear]] = ["Add": [], "Remove": []]
    
    @State var showToast = false
    @State var toastTitle = ""
    @State var toastIcon = ""
    @State var toastColor: Color = .red
    /// in seconds
    @State var toastDuration:Double = 2
    
    @Binding var path: NavigationPath
    
    var requiredFields: Bool {
        !newPack.name.isEmpty && !newPack.weightUnit.abbreviation.isEmpty
    }
    
    var body: some View {
//        NavigationStack {
            VStack {
                if(packs.isEmpty) {
                    ContentUnavailableView {
                        Label("Where's your pack at?", systemImage: "backpack")
                    } description: {
                        Text("Packs save your gear and trip info")
                    } actions: {
                        Button("Create new pack") {
                            showAddPackSheet.toggle()
                        }
                    }
                    
                } else {
                    PacksListView
                }
            }
            .navigationTitle("Packs")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Add samples") {
                            withAnimation(.spring) {
                                addSamplePacks()
                            }
                        }
                        EditButton()
                        Button("Create pack") {
                            showAddPackSheet.toggle()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddPackSheet, content: {
                addPackSheetView
            })
            .popup(isPresented: $showToast) {
                popup
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.interpolatingSpring)
                    .autohideIn(toastDuration)
            }
//        }
    }
    
    var addPackSheetView: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Text("New pack")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Save") {
                        addNewPack()
                    }
                    .disabled(!requiredFields)
                    .buttonStyle(.bordered)
                    .foregroundColor(requiredFields ? .green.opacity(0.8) : .red.opacity(0.6))
                    .animation(.spring, value: requiredFields)
                }
                .padding()
            }
            
            Form {
                Section("Required") {
                    TextField("Pack name", text: $newPack.name)
                    
                    Picker("Unit of weight", selection: $newPack.weightUnit) {
                        ForEach(Gear.WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.abbreviation)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Trip dates") {
                    DatePicker("Start", selection: $newPack.startDate)
                        .datePickerStyle(.automatic)
                    DatePicker("End", selection: $newPack.endDate, in: newPack.startDate...)
                }
            }
        }
        .onAppear(perform: {
//            newPack = Pack(weightUnit: defaultPackWeightUnit)
            newPack.weightUnit = defaultPackWeightUnit
        })
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
    
    func callToast(title: String, icon: String, color: Color, duration: Double = 2) {
        toastTitle = title
        toastIcon = icon
        toastColor = color
        toastDuration = duration
        showToast.toggle()
    }
    
    func addNewPack() {
        context.insert(newPack)
        showAddPackSheet = false
//        newPack = Pack(weightUnit: defaultPackWeightUnit) // completed in onAppear for the addPackSheetView
        
        do {
            try context.save()
            callToast(title: "Created pack", icon: "backpack.fill", color: .green, duration: 3)
        } catch {
            print("error while context saving after creating new pack")
        }
    }
    
    var PacksListView: some View {
        List {
            ForEach(packs) { pack in
                NavigationLink {
                    EditPackView(pack: pack, path: $path)
                } label: {
                    PackRow(pack: pack)
                }
            }
            .onDelete(perform: { indexSet in
                deletePack(indexSet: indexSet)
            })
        }
    }
    
//    func deletePack(indexSet: IndexSet) {
//        print("indexSet: \(indexSet)")
////        print("indexSet.first: \(String(describing: indexSet.first))")
//        print("indexSet.first: \(indexSet.first)")
//        print("before packs: \(packs)")
//        context.delete(packs[indexSet.first ?? 0])
//        do {
//            try context.save()
//            callToast(title: "Deleted pack", icon: "trash", color: .red)
//            print("after packs: \(packs)")
//        } catch {
//            print("error while context saving after delete pack from packsview")
//        }
//    }
    func deletePack(indexSet: IndexSet) {
        guard let index = indexSet.first, packs.indices.contains(index) else {
            print("Invalid index for deletion")
            return
        }
        
        let packToDelete = packs[index]
        
        // Assuming 'gearInPack' needs to be checked or cleaned up before deletion
        if !packToDelete.gearInPack.isEmpty {
            // If you want to delete gearInPack items individually
            // This might depend on your data model's delete rules
            packToDelete.gearInPack.forEach { gearInPackItem in
                // Perform any necessary checks or updates on gearInPackItem
                // For example, updating related entities or removing references
                if let index = packToDelete.gearInPack.firstIndex(where: { $0.id == gearInPackItem.id }) {
                    do {
                        print("removing gear at index \(index): \(packToDelete.gearInPack[index].gear.model) should be \(gearInPackItem.gear.model)")
                        packToDelete.gearInPack.remove(at: index)
                        try context.save()
                    } catch {
                        print("error deleting gear from pack before deleting pack")
                    }
                    
                    // If gearInPackItem should be deleted as well, uncomment the next line
                    // context.delete(gearInPackItem)
                }
            }
            
            // If RandomIcon or any other related entities require cleanup, add similar checks
            
            // Now proceed with deleting the pack
            context.delete(packToDelete)
            do {
                try context.save()
                callToast(title: "Deleted pack", icon: "trash", color: .red)
            } catch {
                print("Error while context saving after delete pack from packsview: \(error)")
            }
        }
    }

    func addSamplePacks() {
        let p1 = Pack(name: "asdfasdf")
        let p2 = Pack(name: "asdfasdf")
        context.insert(p1)
        context.insert(p2)
        
        do {
            try context.save()
        } catch {
            print("error while context saving after adding sample packs to packsview")
        }
    }
}

struct PackRow: View {
    @State var pack: Pack
    let backgroundColor: Color
    let borderColor: Color
    
    init(pack: Pack, backgroundColor: Color = .black, borderColor: Color = .black) {
        self.pack = pack
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
    }
    
    /// tuple
    /// FIX FOR UNITS
    var weightColor: (background: Color, border: Color) {
        if pack.weight == 0.00 {
            return (.secondary, .secondary)
        } else if pack.weight < 5.0 {
            return (.blue, .blue)
        } else if pack.weight < 10.0 {
            return (.green, .green)
        } else if pack.weight < 20.0 {
            return (.orange, .orange)
        } else {
            return (.red, .red)
        }
    }
    
    var body: some View {
        let temp = getWeightColor(weight: pack.weight, weightUnit: pack.weightUnit)
        
        HStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(
                    colors: [
                        Color(red: pack.randomIcon[0][0], green: pack.randomIcon[0][1], blue: pack.randomIcon[0][2]).opacity(1),
                        Color(red: pack.randomIcon[1][0], green: pack.randomIcon[1][1], blue: pack.randomIcon[1][2]).opacity(1),
                        Color(red: pack.randomIcon[2][0], green: pack.randomIcon[2][1], blue: pack.randomIcon[2][2]).opacity(1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing))
                .frame(width: 24, height: 24)
            VStack(alignment: .leading) {
                Text(pack.name)
                HStack() {
                    if (!pack.gearInPack.isEmpty) {
                        Text(String(format: "%.2f", Double(pack.weight)) + " \(pack.weightUnit.abbreviation)")
                            .font(Utils().monoFont)
                            .padding(6)
                            .background(temp.background.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(lineWidth: 1)
                                    .foregroundStyle(temp.border.opacity(0.7))
                                    .saturation(2.5)
                            )
                    }
                    Text(pack.gearInPack.isEmpty ? "empty" : pack.gearInPack.count.description + " items")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.vertical, pack.gearInPack.isEmpty ? 2 : 0)
                }
            }
        }
    }
}

//#Preview {
//    PacksView()
//        .modelContainer(for: Pack.self)
//        .modelContainer(for: Gear.self)
//}
