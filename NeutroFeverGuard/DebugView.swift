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

struct FeverView: View {
    @State private var feverStatus: String = ""
    @Environment(Account.self) private var account: Account?
    @Environment(LabResultsManager.self) private var labResultsManager
    @Binding var presentingAccount: Bool

    var body: some View {
        let (_, statusColor) = getFeverStatus()
        NavigationView {
            VStack {
                Button(action: {
                    Task {
                        await checkForFever()
                    }
                }) {
                    Text("Check Fever Status")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Text(feverStatus)
                    .padding()
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
                    .padding(.top, 10)
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .onAppear {
                labResultsManager.refresh()
            }
        }
    }

    private func checkForFever() async {
        let fever = await FeverMonitor.shared.checkForFever()
        let ancStatus = labResultsManager.getANCStatus()
        
        DispatchQueue.main.async {
            if ancStatus.text == "No Data" {
                feverStatus = "No ANC Data"
            } else if fever && ancStatus.text != "Normal" {
                feverStatus = "Febrile Neutropenia"
            } else if fever {
                feverStatus = "Fever"
            } else if ancStatus.text != "Normal" {
                feverStatus = "Your last result shows that you are neutropenic"
            } else {
                feverStatus = "No fever detected"
            }
        }
    }

    private func getFeverStatus() -> (String, Color) {
        switch feverStatus {
        case "Febrile Neutropenia":
            return (feverStatus, .red)
        case "Fever":
            return (feverStatus, .yellow)
        case "Your last result shows that you are neutropenic":
            return (feverStatus, .yellow)
        case "No Data":
            return (feverStatus, .gray)
        default:
            return (feverStatus, .green)
        }
    }
}
