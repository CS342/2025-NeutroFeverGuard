//
// This source file is part of the NeutroFeverGuard based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage
import HealthKitOnFHIR
import OSLog
@preconcurrency import PDFKit.PDFDocument
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor NeutroFeverGuardStandard: Standard,
                                   EnvironmentAccessible,
                                   HealthKitConstraint,
                                   ConsentConstraint,
                                   AccountNotifyConstraint {
    @Application(\.logger) private var logger

    @Dependency(FirebaseConfiguration.self) private var configuration
    @Dependency(LabResultsManager.self) private var labResultsManager
    @Dependency(NotificationManager.self) private var notificationManager
    init() {}


    func add(sample: HKSample) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new HealthKit sample: \(sample)")
            // Check if the sample is a body temperature measurement before proceeding
            if let quantitySample = sample as? HKQuantitySample,
               quantitySample.quantityType == HKQuantityType.quantityType(forIdentifier: .bodyTemperature) {
                if let condition = await checkForFebrileNeutropenia() {
                    notificationManager.sendLocalNotification(
                        title: "Health Alert",
                        body: "Risk detected: \(condition), please contact your care provider."
                    )
                }
            }
            return
        }
        
        do {
            try await healthKitDocument(id: sample.id)
                .setData(from: sample.resource)
            // Check if the condition is met before sending a notification
            if let quantitySample = sample as? HKQuantitySample,
               quantitySample.quantityType == HKQuantityType.quantityType(forIdentifier: .bodyTemperature) {
                if let condition = await checkForFebrileNeutropenia() {
                    notificationManager.sendLocalNotification(
                        title: "Health Alert",
                        body: "Risk detected: \(condition), please contact your care provider."
                    )
                }
            }
        } catch {
            logger.error("Could not store HealthKit sample: \(error)")
        }
    }
    
    func remove(sample: HKDeletedObject) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new removed healthkit sample with id \(sample.uuid)")
            return
        }
        do {
            try await healthKitDocument(id: sample.uuid).delete()
        } catch {
            logger.error("Could not remove HealthKit sample: \(error)")
        }
    }

    // periphery:ignore:parameters isolation
//    func add(response: ModelsR4.QuestionnaireResponse, isolation: isolated (any Actor)? = #isolation) async {
//        let id = response.identifier?.value?.value?.string ?? UUID().uuidString
//        
//        if FeatureFlags.disableFirebase {
//            let jsonRepresentation = (try? String(data: JSONEncoder().encode(response), encoding: .utf8)) ?? ""
//            await logger.debug("Received questionnaire response: \(jsonRepresentation)")
//            return
//        }
//        
//        do {
//            try await configuration.userDocumentReference
//                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
//                .document(id) // Set the document identifier to the id of the response.
//                .setData(from: response)
//        } catch {
//            await logger.error("Could not store questionnaire response: \(error)")
//        }
//    }
    
    private func checkForFebrileNeutropenia() async -> String? {
        let fever = await FeverMonitor.shared.checkForFever()
        let ancStatus = labResultsManager.getANCStatus()

        if ancStatus.text == "No Data" {
            return nil  // No notification needed
        } else if fever && ancStatus.text != "Normal" {
            return "Febrile Neutropenia"
        } else {
            return nil  // No notification needed
        }
    }
    
    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await configuration.userDocumentReference
            .collection("HealthKit") // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
    }

    func respondToEvent(_ event: AccountNotifications.Event) async {
        if case let .deletingAccount(accountId) = event {
            do {
                try await configuration.userDocumentReference(for: accountId).delete()
            } catch {
                logger.error("Could not delete user document: \(error)")
            }
        }
    }
    
    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    @MainActor
    func store(consent: ConsentDocumentExport) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())

        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                await logger.error("Could not create path for writing consent form to user document directory.")
                return
            }
            
            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
            await consent.pdf.write(to: filePath)
            
            return
        }
        
        do {
            guard let consentData = await consent.pdf.dataRepresentation() else {
                await logger.error("Could not store consent form.")
                return
            }

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("consent/\(dateString).pdf")
                .putDataAsync(consentData, metadata: metadata) { @Sendable _ in }
        } catch {
            await logger.error("Could not store consent form: \(error)")
        }
    }
}
