//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI

struct DataTypeItem: Identifiable {
    let id = UUID()
    let name: String
}

struct AddDataView: View {
    @State private var selectedDataType: DataTypeItem?
    
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    
    let dataTypes: [(name: String, emoji: String)] = [
        (name: "Temperature", emoji: "🌡️"),
        (name: "Heart Rate", emoji: "🫀"),
        (name: "Oxygen Saturation", emoji: "🫁"),
        (name: "Blood Pressure", emoji: "🩸"),
        (name: "Lab Results", emoji: "🧪"),
        (name: "Medication", emoji: "💊")
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack {
                    Text("What data would you like to add?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(dataTypes, id: \.name) { item in
                            Button(action: {
                                self.selectedDataType = DataTypeItem(name: item.name)
                            }) {
                                VStack {
                                    Text(item.emoji).font(.system(size: 40))
                                    Text(item.name).font(.headline)
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 140, height: 100)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                .sheet(item: $selectedDataType) { item in
                    DataInputForm(dataType: item.name)
                }
                .toolbar {if account != nil {AccountButton(isPresented: $presentingAccount)}
                }
            }
        }
    }
}

#Preview {
    AddDataView(presentingAccount: .constant(false))
}
