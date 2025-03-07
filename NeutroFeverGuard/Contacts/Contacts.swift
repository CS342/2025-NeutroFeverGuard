//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import SpeziContact
import SwiftUI


/// Displays the contacts for the NeutroFeverGuard.
struct Contacts: View {
    let contacts = [
        Contact(
            name: PersonNameComponents(
                givenName: "Johannes",
                familyName: "Jung"
            ),
            image: Image(systemName: "stethoscope"), // swiftlint:disable:this accessibility_label_for_image
            title: "Dr. med.",
            organization: "Outpatient Clinic - ZIC, Klinikum recht der Isar TUM",
            address: {
                let address = CNMutablePostalAddress()
                address.country = "Germany"
                address.postalCode = "81675"
                address.city = "München"
                address.street = "Ismaninger Str. 22"
                return address
            }(),
            contactOptions: [
                .call("+49 89 4140 1022"),
                .text("+49 89 4140 1022"),
                .email(addresses: ["johannes.jung@mri.tum.de"]),
                ContactOption(
                    image: Image(systemName: "safari.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "Website",
                    action: {
                        if let url = URL(string: "https://hno.mri.tum.de/en/your-stay-us/outpatient-treatment") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            ]
        ),
        Contact(
            name: PersonNameComponents(
                givenName: "Emergency",
                familyName: "Department"
            ),
            image: Image(systemName: "cross.case"), // swiftlint:disable:this accessibility_label_for_image,
            organization: "Zentrale Interdisziplinäre Notaufnahme TUM",
            address: {
                let address = CNMutablePostalAddress()
                address.country = "Germany"
                address.postalCode = "81675"
                address.city = "München"
                address.street = "Ismaninger Str. 22"
                return address
            }(),
            contactOptions: [
                .call("+49 89 4140 2222"),
                ContactOption(
                    image: Image(systemName: "safari.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "Directions",
                    action: {
                        if let url = URL(string: "https://www.google.com/maps/dir/37.4200987,-122.1639501/Zentrale+Interdisziplinäre+Notaufnahme+tum/@2.9388026,-142.1016129,3z/data=!3m1!4b1!4m9!4m8!1m1!4e1!1m5!1m1!1s0x479e7582085e4a3f:0xd95085fa62e0faa4!2m2!1d11.5997627!2d48.135973?entry=ttu&g_ep=EgoyMDI1MDMwNC4wIKXMDSoASAFQAw%3D%3D") {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            ]
        )
    ]

    @Environment(Account.self) private var account: Account?

    @Binding var presentingAccount: Bool
    
    
    var body: some View {
        NavigationStack {
            ContactsList(contacts: contacts)
                .navigationTitle("Contacts")
                .toolbar {
                    if account != nil {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }
    
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}


#if DEBUG
#Preview {
    Contacts(presentingAccount: .constant(false))
}
#endif
