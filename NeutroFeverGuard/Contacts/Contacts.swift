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
            image: Image(systemName: "figure.wave.circle"), // swiftlint:disable:this accessibility_label_for_image
            title: "Dr. med.",
            organization: "Comprehensive Cancer Center München TUM",
            address: {
                let address = CNMutablePostalAddress()
                address.country = "Germany"
                address.postalCode = "81675"
                address.city = "München"
                address.street = "Ismaninger Str. 22"
                return address
            }(),
            contactOptions: [
                .call("+49 89 41406622"),
                .text("+49 89 41406622"),
                .email(addresses: ["johannes.jung@mri.tum.de"]),
                ContactOption(
                    image: Image(systemName: "safari.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "Website",
                    action: {
                        if let url = URL(string: "https://cccm.mri.tum.de/de") {
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
