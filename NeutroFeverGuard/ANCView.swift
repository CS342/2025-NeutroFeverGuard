//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ANCDisplayView: View {
    @State private var latestNeutrophilPercentage: Double = 55.0
    @State private var latestLeukocyteCount: Double = 4000.0
    @State private var latestRecordedTime: String = "Feb 8, 2025"

    private var ancValue: Double {
        let value: Double = (latestNeutrophilPercentage / 100.0) * latestLeukocyteCount
        return value
    }

    var body: some View {
        VStack{
            VStack {
                Text("Your ANC")
                    .font(.headline)
                Text("(absolute neutrophil counts)")
                    .font(.footnote)
                Text("\(ancValue, specifier: "%.1f")")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(ancValue < 1500 ? .red : .green)
                    .padding(.vertical, 8)
                Text("Last recorded: \(latestRecordedTime)")
                    .font(.caption)
                    .foregroundColor(.gray)
//                VStack(alignment: .leading) {
//                    Text("Neutrophil Percentage: \(latestNeutrophilPercentage, specifier: "%.1f")%")
//                        .font(.footnote)
//                    Text("Leukocyte Count: \(latestLeukocyteCount, specifier: "%.0f")")
//                        .font(.footnote)
//                    Text("Last recorded: \(latestRecordedTime)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
            Spacer()
        }
    }
}

#Preview{
    ANCDisplayView()
}

