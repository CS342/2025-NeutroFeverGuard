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
        case addData
        case labResult
        case schedule
        case contact
    }


    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.schedule
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()

    @State private var presentingAccount = false

    
    var body: some View {
        HKVisualization()
        TabView(selection: $selectedTab) {
            Tab("Add Data", systemImage: "plus.app.fill", value: .addData) {
                AddDataView(presentingAccount: $presentingAccount)
            }
            Tab("Lab", systemImage: "flask", value: .labResult) {
                LabView(presentingAccount: $presentingAccount)
            }
                .customizationID("home.addData")
            Tab("Schedule", systemImage: "list.clipboard", value: .schedule) {
                ScheduleView(presentingAccount: $presentingAccount)
            }
                .customizationID("home.schedule")
            Tab("Contacts", systemImage: "person.fill", value: .contact) {
                Contacts(presentingAccount: $presentingAccount)
            }
                .customizationID("home.contacts")
        }
            .tabViewStyle(.sidebarAdaptable)
            .tabViewCustomization($tabViewCustomization)
            .sheet(isPresented: $presentingAccount) {
                AccountSheet(dismissAfterSignIn: false) // presentation was user initiated, do not automatically dismiss
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
