//
//  HealthDataManager.swift
//  NeedaApp
//
//  Created by Reham  on 06/09/1445 AH.
//


import Foundation  // Import Foundation for basic data handling and utilities
import HealthKit  // Import HealthKit to interact with health-related data on iOS devices

class HealthDataManager {
    
    static let shared = HealthDataManager()
    private var healthStore: HKHealthStore?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore() // Initialize HealthStore if Health data is available
        } else {
            print("HealthKit is not available on this device.")
        }
    }
    
    // Requests permission from the user to read health data
    func requestHealthKitPermissions(completion: @escaping (Bool, Error?) -> Void) {
        guard let healthStore = self.healthStore else {
            completion(false, HealthKitError.healthDataUnavailable)
            return
        }
        
        
        // Specify the types of health data Needa app needs access to read
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.characteristicType(forIdentifier: .bloodType)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    // Fetches the user's data
    func fetchBiologicalSex(completion: @escaping (HKBiologicalSexObject?, Error?) -> Void) {
        do {
            guard let healthStore = self.healthStore else {
                throw HealthKitError.healthDataUnavailable
            }
            let biologicalSex = try healthStore.biologicalSex()
            completion(biologicalSex, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func fetchDateOfBirth(completion: @escaping (DateComponents?, Error?) -> Void) {
        do {
            guard let healthStore = self.healthStore else {
                throw HealthKitError.healthDataUnavailable
            }
            let dateOfBirthComponents = try healthStore.dateOfBirthComponents()
            completion(dateOfBirthComponents, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func fetchHeight(completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height) else {
            completion(nil, HealthKitError.dataTypeNotAvailable)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let results = results as? [HKQuantitySample], !results.isEmpty else {
                completion(nil, error)
                return
            }
            completion(results, nil)
        }
        
        healthStore?.execute(query)
    }
    
    func fetchWeight(completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil, HealthKitError.dataTypeNotAvailable)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let results = results as? [HKQuantitySample], !results.isEmpty else {
                completion(nil, error)
                return
            }
            completion(results, nil)
        }
        
        healthStore?.execute(query)
    }
    
    // Fetch Blood Type
    func fetchBloodType(completion: @escaping (HKBloodTypeObject?, Error?) -> Void) {
        do {
            guard let healthStore = self.healthStore else {
                throw HealthKitError.healthDataUnavailable
            }
            let bloodType = try healthStore.bloodType()
            completion(bloodType, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    
    
    // Fetch Heart Rate
    func fetchHeartRate(completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, results, error in
            DispatchQueue.main.async {
                completion(results?.first as? HKQuantitySample, error)
            }
        }
        healthStore?.execute(query)
    }
    
    // Fetch Blood Oxygen
    func fetchBloodOxygen(completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        let bloodOxygenType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let query = HKSampleQuery(sampleType: bloodOxygenType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { query, results, error in
            DispatchQueue.main.async {
                completion(results?.first as? HKQuantitySample, error)
            }
        }
        healthStore?.execute(query)
    }
    
    
    
    
    
}

enum HealthKitError: Error {
    case healthDataUnavailable
    case dataTypeNotAvailable
    case unauthorized
    case unexpectedError
}
