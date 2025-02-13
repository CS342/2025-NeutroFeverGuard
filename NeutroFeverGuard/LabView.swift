import SpeziAccount
import SwiftUI

struct ANCView: View {
    let ancValue: Double
    let latestRecordedTime: String

    var body: some View {
        let status = getANCStatus(ancValue)

        VStack(alignment: .leading, spacing: 8) {
            Text("🧪 Latest ANC")
                .font(.headline)
            Text("\(ancValue, specifier: "%.1f") cells/µL")
                .font(.largeTitle)
                .bold()
                .foregroundColor(status.color)
                .padding(.vertical, 8)
            
            Text(status.text)
                .font(.subheadline)
                .foregroundColor(status.color)
                .bold()
            Text("Last recorded: \(latestRecordedTime)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    private func getANCStatus(_ ancValue: Double) -> (text: String, color: Color) {
        switch ancValue {
        case let anc where anc >= 500:
            return ("Normal", .green)
        case let anc where anc >= 100:
            return ("Severe Neutropenia", .orange)
        default:
            return ("Profound Neutropenia", .red)
        }
    }
}


struct LabResultDetailView: View {
    var record: LabEntry

    var body: some View {
        Form {
            Section(header: Text("Lab Values")) {
                labValueRow(type: .whiteBloodCell, unit: "cells/µL")
                labValueRow(type: .hemoglobin, unit: "g/dL")
                labValueRow(type: .plateletCount, unit: "cells/µL")
                labValueRow(type: .neutrophils, unit: "%")
                labValueRow(type: .lymphocytes, unit: "%")
                labValueRow(type: .monocytes, unit: "%")
                labValueRow(type: .eosinophils, unit: "%")
                labValueRow(type: .basophils, unit: "%")
                labValueRow(type: .blasts, unit: "%")
            }
        }
        .navigationTitle(formatDate(record.date))
    }

    @ViewBuilder
    private func labValueRow(type: LabTestType, unit: String) -> some View {
        HStack {
            Text(type.rawValue)
            Spacer()
            Text("\(record.values[type] ?? 0, specifier: "%.1f") \(unit)")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// for simple view
func createLabEntry(daysAgo: Int, values: [LabTestType: Double]) throws -> LabEntry {
    guard let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) else {
        throw NSError(domain: "Invalid date", code: 1, userInfo: nil)
    }
    return try LabEntry(date: date, values: values)
}


struct LabView: View {
    @State private var latestNeutrophilPercentage: Double = 99.0
    @State private var latestLeukocyteCount: Double = 200.0
    @State private var latestRecordedTime = Date()
    @State private var labRecords: [LabEntry] = {
        do {
            let record1 = try createLabEntry(daysAgo: 0, values: [
                .whiteBloodCell: 4500, .hemoglobin: 13.5,
                .plateletCount: 250000, .neutrophils: 55,
                .lymphocytes: 35, .monocytes: 6,
                .eosinophils: 2, .basophils: 1,
                .blasts: 0
            ])
            let record2 = try createLabEntry(daysAgo: 7, values: [
                .whiteBloodCell: 5000,
                .hemoglobin: 14.0,
                .plateletCount: 260000,
                .neutrophils: 52,
                .lymphocytes: 37,
                .monocytes: 5,
                .eosinophils: 3,
                .basophils: 1,
                .blasts: 0
            ])
            let record3 = try createLabEntry(daysAgo: 14, values: [
                .whiteBloodCell: 4800,
                .hemoglobin: 13.8,
                .plateletCount: 255000,
                .neutrophils: 53,
                .lymphocytes: 36,
                .monocytes: 6,
                .eosinophils: 2,
                .basophils: 1,
                .blasts: 0
            ])
            return [record1, record2, record3]
        } catch {
            fatalError("Error initializing lab records: \(error)")
        }
    }()
    @Environment(Account.self) private var account: Account?
    @Binding var presentingAccount: Bool

    private var ancValue: Double {
        (latestNeutrophilPercentage / 100.0) * latestLeukocyteCount
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Absolute Neutrophil Counts")) {
                    NavigationLink(destination: LabResultDetailView(record: labRecords[0])) {
                        ANCView(ancValue: ancValue, latestRecordedTime: formatDate(latestRecordedTime))
                    }
                }
                Section(header: Text("Lab Results History")) {
                    ForEach(labRecords, id: \.date) { record in
                        NavigationLink(destination: LabResultDetailView(record: record)) {
                            Text(formatDate(record.date))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Lab Results")
            .background(Color(.systemGray6))
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    LabView(presentingAccount: .constant(false))
}
