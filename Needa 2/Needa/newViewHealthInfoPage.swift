import SwiftUI
import HealthKit
import CloudKit
import CryptoKit


struct newViewHealthInfoPage: View {
    @State private var showinghomepage = false // State for showing home page
    // State variables to hold fetched health data

    @State private var heartRate: String = "لا توجد بيانات"
    @State private var bloodOxygen: String = "لا توجد بيانات"
    @State private var bloodType: String = "لا توجد بيانات"
    @State private var weight: String = "لا توجد بيانات"
    @State private var height: String = "لا توجد بيانات"
    @State private var medications: [String] = []
    
    var body: some View {
        
        ZStack { // Start of ZStack for background color
            Color("backgroundColor")
                .ignoresSafeArea(.all) // Background color covering the entire screen
            
            NavigationView { // Start of NavigationView
                ScrollView { // Start of ScrollView for scrolling content
                    
                    VStack { // Start of main VStack
                        
                        HStack { // Start of HStack for the top bar
                            Button(action: {
                                self.showinghomepage = true
                            }) {
                                HStack { // Start of HStack for Button content
                                    Image(systemName: "chevron.left") // The back arrow icon
                                        .offset(x:20)
                                        .foregroundColor(.red)
                                    
                                } // End of HStack for Button content
                            } // End of Button
                            
                            Spacer() // This pushes the button to the left and the title to the right
                            
                            Text("معلوماتي الصحية") // The title text
                                .font(.title)
                                .bold()
                                .foregroundColor(.red)
                                .offset(x:40, y:10) 
                            
                            Spacer() // Another spacer for symmetry
                            
                        } // End of HStack for the top bar
                        .padding(.vertical)
                        .fullScreenCover(isPresented: $showinghomepage) {
                            NeedaHomePage()
                        }
                        
                        
                        VStack { // Start of HStack for health cards
                            HealthCardtwo(title: "نبضات القلب", value:"\(heartRate) ", graphName: "heart.fill" , color: .red,isSystemImage: true)
                            // End of Heart Rate HealthCard
                            
                        } // End of HStack for health cards
                        .environment(\.layoutDirection, .rightToLeft)
                        VStack { // Start of HStack for health cards
                            HealthCardtwo(title: "اكسجين الدم", value: "\(bloodOxygen)", graphName: "o.circle.fill", color: .blue,isSystemImage: true) }
                        // End of Oxygen Level HealthCard
                        .environment(\.layoutDirection, .rightToLeft)
                        
                        // End of HStack for health cards
                        
                        
                        
                        VStack { // Start of HStack for health cards
                            
                            HealthCardtwo(title: "فصيلة الدم", value: "\(bloodType)", graphName: "drop.fill", color: .red,isSystemImage: true)
                        } // End of HStack for health cards
                        .environment(\.layoutDirection, .rightToLeft)
                        VStack{
                            HealthCardtwo(title: "الطول", value: "\(height)", graphName: "ruler", color: .red, isSystemImage: true)
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        HStack { // Start of HStack for health cards
                            
                            HealthCardtwo(title: "الوزن", value: "\(weight)", graphName: "scalemass", color: .yellow,isSystemImage: true)
                            
                        } // End of HStack for health cards
                        .environment(\.layoutDirection, .rightToLeft)
                        
                        HStack {
                            //HealthCardtwo(title: "الأدوية", value: "\(medications)" , graphName: "pills.fill" , color: .blue)
                            HealthCardMedication(title: "الأدوية", medications: self.medications, graphName: "pills.fill", color: .blue)
                        }     .environment(\.layoutDirection, .rightToLeft)
                        // End of HStack for health cards
                        
                    } // End of main VStack
                } // End of ScrollView
                .navigationBarHidden(true) // Hide the default navigation bar
            } // End of NavigationView
            
            
        } // End of ZStack
        .onAppear {
            self.fetchHealthData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Wait for 1 second before calling update
                updateHealthInformation(bloodOxygen: self.bloodOxygen, heartRate: self.heartRate)
            }
            
            retriveHealthData()
        }
        
        .fullScreenCover(isPresented: $showinghomepage) {
            NeedaHomePage() // Present the home page when showinghomepage is true
        }
        
        
    } // end of body
    
    
    // Fetches and updates health data from HealthKit
    private func fetchHealthData() {
        // Ensure to request permissions before fetching
        HealthDataManager.shared.requestHealthKitPermissions { success, _ in
            guard success else { return }
            
            HealthDataManager.shared.fetchHeartRate { sample, _ in
                if let sample = sample {
                    let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    self.heartRate = "\(Int(value)) bpm "
                }
            }
            
            HealthDataManager.shared.fetchBloodOxygen { sample, _ in
                if let sample = sample {
                    let value = sample.quantity.doubleValue(for: HKUnit.percent())
                    self.bloodOxygen = String(format: "%.1f%%", value * 100)
                }
            }
            
            
            
            
            HealthDataManager.shared.fetchBloodType { bloodTypeObject, _ in
                if let bloodTypeObject = bloodTypeObject {
                    let bloodTypeString = convertBloodTypeToString(bloodTypeObject)
                    self.bloodType = bloodTypeString
                }
            }
            
            
            HealthDataManager.shared.fetchWeight { samples, _ in
                if let sample = samples?.first {
                    let value = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    self.weight = "\(Int(value)) kg"
                }
            }
            
            HealthDataManager.shared.fetchHeight { samples, _ in
                if let sample = samples?.first {
                    let value = sample.quantity.doubleValue(for: HKUnit.meter())
                    self.height = String(format: "%.2f m", value)
                }
            }
        }
    }
    
    //---------------------clould kit codes
    
    private func retriveHealthData() {
        // Assuming userRecordID and healthInfoRecord are already saved in UserDefaults after registration and health info submission
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID"),
              let healthInfoRecordIDString = UserDefaults.standard.string(forKey: "healthInfoRecord") else {
            print("User record ID not found line 213")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let healthInfoRecordID = CKRecord.ID(recordName: healthInfoRecordIDString)
        
        // Fetch Individual Record for Height and Weight
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    self.height = record["Hight"] as? String ?? "No data"
                    self.weight = record["Wight"] as? String ?? "No data"
                } else {
                    print("Error fetching individual record: \(error?.localizedDescription ?? "No error description")")
                }
            }
        }
        
        // Fetch Health Information Record for Blood Type
        privateDatabase.fetch(withRecordID: healthInfoRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    self.bloodType = record["BloodType"] as? String ?? "No data"
                } else {
                    print("Error fetching health information record: \(error?.localizedDescription ?? "No error description")")
                }
            }
        }
        
        
        // Query for Medications Records related to the User
        guard let userRecordIDStringMed = UserDefaults.standard.string(forKey: "medicationRecord")
        else {
            print("User record ID not found line 213")
            return
        }
        
        let userRecordIDMed = CKRecord.ID(recordName: userRecordIDStringMed)
        print("UserRecordIDMed: \(userRecordIDMed)")
        
        
        print("UserRecordID: \(userRecordID)")
        
        // Make sure the 'UserID' field is indexed and queryable in your CloudKit Dashboard
        let predicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let query = CKQuery(recordType: "Medications", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle the error appropriately
                    print("Error fetching medications records: \(error.localizedDescription)")
                    return
                }
                
                guard let records = records else {
                    print("No medication records found for user.")
                    return
                }
                
                for record in records {
                    if let name = record["MedicineName"] as? String,
                       let dose = record["DoseOfMedication"] as? String,
                       let doseUnit = record["DoseUnit"] as? String {
                        let medicationString = "الدواء: \(name)\nالجرعة: \(dose)\nالوحدة: \(doseUnit)"
                        self.medications.append(medicationString)
                    }
                }
                
                if self.medications.isEmpty {
                    print("User has no medications.")
                } else {
                    print("Medications fetched for the user: \(self.medications)")
                }
            }
        }
        
        
        
    }// end of the function
    
    
    //---------------------
    
    //DONE
    func updateHealthInformation(bloodOxygen: String,  heartRate: String) {
        guard let healthInfoRecordIDString = UserDefaults.standard.string(forKey: "healthInfoRecord"),
              let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("Record ID not found")
            return
        }
        
        let healthInfoRecordID = CKRecord.ID(recordName: healthInfoRecordIDString)
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.fetch(withRecordID: healthInfoRecordID) { record, error in
            if let error = error {
                // Handle the error appropriately
                print("CloudKit fetch Error: \(error.localizedDescription)")
                return
            }
            
            if let record = record {
                // Update the record with new data
                record["BloodOxygen"] = bloodOxygen
                
                record["HeartRate"] = heartRate
                
                // Link the updated record to the user's Individual record if needed
                let reference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
                record["UserID"] = reference
                
                // Save the updated record to CloudKit
                privateDatabase.save(record) { _, saveError in
                    DispatchQueue.main.async {
                        if let saveError = saveError {
                            print("CloudKit Save Error: \(saveError.localizedDescription)")
                        } else {
                            print("Health information updated successfully for userRecordID: \(userRecordIDString)")
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
} // end of struct


struct HealthCardtwo: View {
    var title: String
    var value: String
    var graphName: String // The name of the image asset for the graph
    var color: Color
    var isSystemImage: Bool
    
    var body: some View { // Start of HealthCard body
        VStack(alignment: .trailing, spacing: 10) { // Align content to the leading edge
            Text(title) // The title of the card
                .font(.system(size: 30))
                .padding(.top, -45 )
                .padding(.leading, -280)
                .foregroundColor(.red)
            
            // .offset(x:-50 , y: -25)
            HStack {
                if isSystemImage {
                    Image(systemName: graphName) // System image
                        .font(.system(size: 25))
                        .foregroundColor(.red)
                        .padding(.top, -70)
                } else {
                    Image(graphName) // Image from assets
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .padding(.top, -70)
                }
                
                //   .offset(x:290 , y:-3)
                
                Spacer() // Use a spacer to push content to the edges
                Text(value) // The value (e.g., "120 bpm")
                    .padding(.leading, -300)
                    .font(.system(size: 18))
                
                //  .offset(x:-95 , y:1)
                // End of Value Text
            }
        } // End of VStack
        .padding()
        .frame(maxWidth: .infinity)
        .frame(width: 365, height: 150)
        .background(Color.white) // Set the background color to white
        .cornerRadius(20) // Rounded corners
        .shadow(radius: 10) // Add a shadow
    } // End of HealthCard body
    
} // End of HealthCard struct

struct HealthCardMedication: View {
    var title: String
    var medications: [String] // This should be an array of medication descriptions
    var graphName: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
            
                .font(.system(size: 30))
                .foregroundColor(.red)
                .padding(.top, 50 )
                .padding(.leading, 55)
            // .offset(x:150 , y: 30)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(medications, id: \.self) { medication in
                        VStack(alignment: .leading, spacing: 5) { // New VStack for alignment
                            let components = medication.components(separatedBy: "\n")
                            ForEach(components, id: \.self) { component in
                                Text(component)
                                    .font(.system(size: 18))
                                    .padding(.vertical, 1)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
            }
            .frame(minHeight: 100)
            
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: graphName)
                
                    .font(.system(size: 25))
                
                    .imageScale(.large)
                    .foregroundColor(.red)
                    .padding(.top , -165)
                    .padding(.leading, -170)
                
                
                Spacer() // Use a spacer to push content to the edges
                
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(width: 365, height: 150)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
        
        
    }
}




// Placeholder views for each time period's stats
struct DayView: View { // Start of DayView struct
    var body: some View {
        // Display day's health data
        Text("معلومات اليوم")
    } // End of DayView body
} // End of DayView struct

struct WeekView: View { // Start of WeekView struct
    var body: some View {
        // Display week's health data
        Text("معلومات الأسبوع")
    } // End of WeekView body
} // End of WeekView struct

struct MonthView: View { // Start of MonthView struct
    var body: some View {
        // Display month's health data
        Text("معلومات الشهر")
    } // End of MonthView body
} // End of MonthView struct

func convertBloodTypeToString(_ bloodTypeObject: HKBloodTypeObject) -> String {
    switch bloodTypeObject.bloodType {
    case .notSet:
        return "لا توجد بيانات"
    case .aPositive:
        return "A+"
    case .aNegative:
        return "A-"
    case .bPositive:
        return "B+"
    case .bNegative:
        return "B-"
    case .abPositive:
        return "AB+"
    case .abNegative:
        return "AB-"
    case .oPositive:
        return "O+"
    case .oNegative:
        return "O-"
    @unknown default:
        return "Unknown"
    }
}

struct HealthDashboardView_Previews: PreviewProvider { // Start of Previews
    static var previews: some View { // Start of previews body
        newViewHealthInfoPage() // Preview of HealthDashboardView
    } // End of previews body
} // End of Previews
