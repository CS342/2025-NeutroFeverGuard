//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import class SpeziScheduler.Scheduler
import SwiftUI

struct HomeView: View {
    enum Tabs: String {
//        case dashboard
        case addData
        case labResult
        case medication
//        case schedule
        case contact
    }


    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.addData
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()

    @State private var presentingAccount = false
        
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard tab (HKVisualization)
//            Tab("Dashboard", systemImage: "heart.text.square", value: .dashboard) {
//                HKVisualization()
//            }
//            .customizationID("home.dashboard")
            
            // Add Data tab
            Tab("Add Data", systemImage: "plus.app.fill", value: .addData) {
                AddDataView(presentingAccount: $presentingAccount)
            }
            .customizationID("home.addData")
            .accessibilityIdentifier("Add Data")
            
            // Lab tab
            Tab("Lab", systemImage: "flask", value: .labResult) {
                LabView(presentingAccount: $presentingAccount)
            }
            .customizationID("home.lab")
            .accessibilityIdentifier("Lab")
            
            // Medication tab
            Tab("Medication", systemImage: "pills", value: .medication) {
                MedicationView(presentingAccount: $presentingAccount)
            }
            .customizationID("home.medication")
            .accessibilityIdentifier("Medication")
            
            // Schedule tab
//            Tab("Schedule", systemImage: "list.clipboard", value: .schedule) {
//                ScheduleView(presentingAccount: $presentingAccount)
//            }
//            .customizationID("home.schedule")
//            .accessibilityIdentifier("Schedule")
            
            // Contacts tab
            Tab("Contacts", systemImage: "person.fill", value: .contact) {
                Contacts(presentingAccount: $presentingAccount)
            }
            .customizationID("home.contacts")
            .accessibilityIdentifier("Contacts")
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabViewCustomization)
        .sheet(isPresented: $presentingAccount) {
            AccountSheet(dismissAfterSignIn: false)
        }
        .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
            AccountSheet()
        }
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    
    return HomeView()
        .previewWith(standard: NeutroFeverGuardStandard()) {
            Scheduler()
            NeutroFeverGuardScheduler()
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
