import Spezi
import UserNotifications
import HealthKit


final class MyNotifications: Module {
    @Dependency(Notifications.self)
    private var notifications

    @Application(\.notificationSettings)
    private var settings

    @Dependency(\.healthStore)
    private var healthStore

    @Dependency(\.bodyTemperatureType)
    private var bodyTemperatureType

    func startFeverMonitoring() {
        let status = await settings().authorizationStatus
        guard status == .authorized || status == .provisional else {
            return // no authorization to schedule notification
        }
        let query = HKObserverQuery(sampleType: bodyTemperatureType, predicate: nil) { query, completionHandler, error in
            if error == nil {
                self.checkBodyTemperature { isFeverish in
                    if isFeverish {
                        // Create notification content
                        let content = UNMutableNotificationContent()
                        content.title = "Fever Alert"
                        content.body = "High body temperature detected!"
                        content.sound = .default
                        
                        // Create notification request - delivering immediately when fever detected
                        let request = UNNotificationRequest(
                            identifier: "fever-alert",
                            content: content,
                            trigger: nil  // nil trigger means deliver immediately
                        )
                        
                        // Schedule notification
                        UNUserNotificationCenter.current().add(request)
                    }
                }
            }
            completionHandler()
        }
        
        healthStore.execute(query)
        
        // Enable background delivery of updates
        healthStore.enableBackgroundDelivery(for: bodyTemperatureType, frequency: .immediate) { success, error in
            if let error = error {
                print("Failed to enable background delivery: \(error.localizedDescription)")
            }
        }
    }

    func checkBodyTemperature(completion: @escaping (Bool) -> Void) {
        // Create anchor date for the last 24 hours
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .hour, value: -24, to: endDate) else {
            completion(false)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictEndDate
        )
        
        // Use anchored object query for background updates
        var anchor: HKQueryAnchor?
        let query = HKAnchoredObjectQuery(
            type: bodyTemperatureType,
            predicate: predicate,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { query, samples, deletedObjects, newAnchor, error in
            anchor = newAnchor
            
            guard let latestSample = samples?.last as? HKQuantitySample else {
                completion(false)
                return
            }
            
            let temperatureInCelsius = latestSample.quantity.doubleValue(for: HKUnit.degreeCelsius())
            let isFeverish = temperatureInCelsius >= 38.0
            completion(isFeverish)
        }
        
        // Add update handler for continuous monitoring
        query.updateHandler = { query, samples, deletedObjects, newAnchor, error in
            anchor = newAnchor
            
            guard let latestSample = samples?.last as? HKQuantitySample else {
                completion(false)
                return
            }
            
            let temperatureInCelsius = latestSample.quantity.doubleValue(for: HKUnit.degreeCelsius())
            let isFeverish = temperatureInCelsius >= 38.0
            completion(isFeverish)
        }
        
        healthStore.execute(query)
    }
}
