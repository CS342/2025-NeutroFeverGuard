//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziLocalStorage
import SwiftUI

enum HealthSection {
    case labResults
    case medications
}

struct RecordsView: View {
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool
    
    @State private var selectedSection: HealthSection = .labResults
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Section", selection: $selectedSection) {
                    Text("Lab Results").tag(HealthSection.labResults)
                    Text("Medications").tag(HealthSection.medications)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                TabView(selection: $selectedSection) {
                    LabView()
                        .tag(HealthSection.labResults)
                    MedicationView()
                        .tag(HealthSection.medications)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Health Data")
            .toolbar { toolbarContent() }
            .background(Color(.systemGray6))
        }
    }
    
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem {
            if account != nil {
                AccountButton(isPresented: $presentingAccount)
            }
        }
    }
}
