//
//  medicalHistory.swift
//  NeedaApp
//
//  Created by Alanoud on 07/09/1445 AH.

import SwiftUI  // Import SwiftUI for building UI elements
import HealthKit  // Import HealthKit for health-related data integration
import CloudKit  // Import CloudKit for cloud database operations


// View displaying the medical history information.
struct NewmedicalHistory: View {
    
    @State private var showUpdateView = false
    @State private var showUpdateView2 = false
    @State private var showUpdateView3 = false
    @State private var showUpdateView4 = false
    @State private var showUpdateView5 = false
    @State private var showUpdateView6 = false
    
    @State private var showAddMedicationView = false
    @State private var showSurguryView = false
    @State private var showAddChronincView = false
    
    @State private var showDeleteMedicationView = false
    @State private var showDeleteSurguryView = false
    @State private var showDeleteChronicView = false
    
    
    @State private var showingHomePage = false // State for showing home page
    @State private var heartRate: String = "لا توجد بيانات" // Placeholder text for each data
    @State private var personname: String = "لا توجد بيانات"
    @State private var age: Int = 0
    @State private var idNUM: Int = 0
    @State private var gender: String = "لا توجد بيانات"
    
    // States for health-related metrics
    @State private var bloodOxygen: String = "لا توجد بيانات"
    @State private var bloodPressure: String = "لا توجد بيانات"
    @State private var bodyTemperature: String = "لا توجد بيانات"
    @State private var bloodType: String = "لا توجد بيانات"
    @State private var weight: String = "لا توجد بيانات"
    @State private var height: String = "لا توجد بيانات"
    @State private var alergies: String = "لا توجد بيانات"
    @State private var medications: [String] = []
    @State private var chronincs: [String] = []
    @State private var medicalNotes: String = "لا توجد بيانات"
    @State private var surgeries: [String] = []
    @State private var personal: [String] = [] // Personal information list
    // Lists to manage surgeries and medications
    @State var surgeryNames: [String] = []
    @State var surgeryYears: [String] = []
    @State var MedicationNames: [String] = []
    @State var Medicationdoses: [String] = []
    @State var Medicationunits: [String] = []
    @State var chronincNames: [String] = []
    
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea(.all)
            
            NavigationView {
                ScrollView {
                    VStack {
                        
                        
                        HStack {
                            Button(action: {
                                self.showingHomePage = true
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .offset(x: 20 , y: -19)
                                        .foregroundColor(.red)
                                    
                                }
                            }
                            
                            Spacer()
                            
                            // Title of the medical history page
                            
                            Text("التاريخ الطبي")
                                .font(.title)
                                .bold()
                                .foregroundColor(.red)
                                .offset(x: -20, y: 10)
                                .padding(.bottom , 50)
                            
                        }
                        .fullScreenCover(isPresented: $showingHomePage) {
                            NeedaHomePage()
                        }
                        // Various cards to display health information with update functionality
                        
                        // MARK: Health Information Cards
                        ZStack {
                            HealthCardPersonaInfo(title: "المعلومات الشخصية:", personal: self.personal, graphName: "note.text", color: .green)
                            
                            HStack {
                                Button(action: {
                                    // This will set showUpdateView to true, presenting the modal
                                    
                                    
                                    self.showUpdateView = true
                                }) {
                                    Image(systemName: "pencil.circle.fill") // Using a pencil icon
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                        .padding()
                                }
                                .sheet(isPresented: $showUpdateView) {
                                    UpdateView(personal: $personal, onApply: {
                                        self.updatePersonalInformation()
                                    })
                                }}  .padding(EdgeInsets(top: 140, leading: 300, bottom: 0, trailing: 0))
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        
                        VStack {
                            // Start of HStack for health cards
                            HealthCardtwo(title: "نبضات القلب", value:"\(heartRate) ", graphName: "heart.fill" , color: .red,isSystemImage: true)
                            // End of Heart Rate HealthCard
                            
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        VStack{
                            HealthCardtwo(title: "اكسجين الدم", value: "\(bloodOxygen)", graphName: "o.circle.fill", color: .blue,isSystemImage: true)
                            // End of Oxygen Level HealthCard
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        
                        
                        VStack {
                            
                            HealthCardtwo(title: "فصيلة الدم", value: "\(bloodType)", graphName: "drop.fill", color: .red,isSystemImage: true)
                            // End of Blood Type HealthCard
                            
                            // End of Medication HealthCard
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        VStack{
                            HealthCardtwo(title: "الطول", value: "\(height)", graphName: "ruler", color: .red,isSystemImage: true)
                            // End of Blood Type HealthCard
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        VStack {
                            HealthCardtwo(title: "الوزن", value: "\(weight)", graphName: "scalemass", color: .yellow,isSystemImage: true)
                            // End of Medication HealthCard
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        ZStack {
                            HealthCardMedication(title: "الأدوية", medications: self.medications, graphName: "pills.fill", color: .blue)
                            
                            HStack{
                                Button(action: {
                                    // This will set showUpdateView to true, presenting the modal
                                    prepareMedicatinData(medications: medications)
                                    
                                    self.showUpdateView5 = true
                                    
                                }) {
                                    Image(systemName: "pencil.circle.fill") // Using a pencil icon
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                    
                                }
                                .sheet(isPresented: $showUpdateView5) {
                                    UpdateMedicationView(medications: $medications, MedicationNames: $MedicationNames
                                                         , Medicationdoses: $Medicationdoses, Medicationunits: $Medicationunits
                                                         ,onApply: {
                                        self.updateMedications(MedicationNames: MedicationNames, Medicationdoses: Medicationdoses, Medicationunits: Medicationunits)  { success in
                                            
                                            print("Update completion with success: \(success)")
                                        }
                                    })
                                }
                                
                                
                                
                                Button(action: {
                                    // This will show a UI to add new medication
                                    self.showAddMedicationView = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.green)
                                        .padding()
                                }
                                .sheet(isPresented: $showAddMedicationView) {
                                    AddMedicationView(onAdd: { name, dose, unit in
                                        self.addNewMedication(name: name, dose: dose, unit: unit)
                                    })
                                }
                                
                                
                                Button(action: {
                                    showDeleteMedicationView = true
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .resizable()
                                        .foregroundColor(.red)
                                        .frame(width: 30, height: 30)
                                }
                                .sheet(isPresented: $showDeleteMedicationView) {
                                    
                                    DeleteMedicationView(medications: $medications)
                                }
                                
                            }.padding(EdgeInsets(top: 95, leading: 190, bottom: 0, trailing: 0))
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        ZStack{
                            HealthCardtwo(title: "الحساسية", value: "\(alergies)", graphName: "food-allergy_2248584", color: .red,isSystemImage: false)
                            
                            HStack{   Button(action: {
                                // This will set showUpdateView to true, presenting the modal
                                
                                
                                self.showUpdateView2 = true
                            }) {
                                Image(systemName: "pencil.circle.fill") // Using a pencil icon
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            .sheet(isPresented: $showUpdateView2) {
                                UpdateViewAllergy(allergies: $alergies, onApply: {
                                    self.updateAllergies()
                                })
                            }}.padding(EdgeInsets(top: 95, leading: 300, bottom: 0, trailing: 0))
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        
                        
                        ZStack {
                            HealthCardSurgeries(title: "العمليات السابقة", surgeries: self.surgeries,  color: .brown)
                            
                            HStack{
                                Button(action: {
                                    // This will set showUpdateView to true, presenting the modal
                                    prepareSurgeryData(surgeries: surgeries)
                                    
                                    self.showUpdateView4 = true
                                    
                                }) {
                                    Image(systemName: "pencil.circle.fill") // Using a pencil icon
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                    
                                }
                                .sheet(isPresented: $showUpdateView4) {
                                    UpdateSurgeriesView(surgeryNames: $surgeryNames, surgeryYears: $surgeryYears, surgeries: $surgeries
                                                        ,onApply: {
                                        self.updateSurgeries(surgeryNames: surgeryNames, surgeryYears: surgeryYears) { success in
                                            
                                            print("Update completion with success: \(success)")
                                        }
                                    })
                                }
                                
                                
                                Button(action: {
                                    // This will show a UI to add new surgery
                                    self.showSurguryView = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.green)
                                        .padding()
                                }
                                .sheet(isPresented: $showSurguryView) {
                                    AddSurgyryView(onSurgeryAdd: { name, year in
                                        self.addNewSurgury(name: name, year: year)
                                    })
                                }
                                Button(action: {
                                    showDeleteSurguryView = true
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                }
                                .sheet(isPresented: $showDeleteSurguryView) {
                                    
                                    DeleteSurgeryView(surgeries: $surgeries)
                                }}.padding(EdgeInsets(top: 150, leading: 200, bottom: 0, trailing: 0))
                            
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        ZStack {
                            HealthCardChronic(title: "الامراض المزمنة",  chronincs: self.chronincs, color: .yellow)
                            
                            HStack{
                                Button(action: {
                                    // This will set showUpdateView to true, presenting the modal
                                    prepareChronicData(chronincs: chronincs )
                                    
                                    self.showUpdateView6 = true
                                }) {
                                    Image(systemName: "pencil.circle.fill") // Using a pencil icon
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                    
                                }
                                .sheet(isPresented: $showUpdateView6) {
                                    UpdateChronicView(chronics: $chronincs, chronicNames: $chronincNames, onApply: {
                                        self.updateChronic(chronincNames: chronincNames){ success in
                                            
                                            print("Update completion with success: \(success)")
                                        }
                                    })
                                }
                                
                                Button(action: {
                                    // This will show a UI to add new chroninc
                                    self.showAddChronincView = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.green)
                                        .padding()
                                }
                                .sheet(isPresented: $showAddChronincView) {
                                    AddChronincView(onChronicAdd: { name in
                                        self.addNewChroninc(name: name)
                                    })
                                }
                                
                                Button(action: {
                                    showDeleteChronicView = true
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                }
                                .sheet(isPresented: $showDeleteChronicView) {
                                    
                                    DeleteChronicView(chronics: $chronincs)
                                }
                            }
                            .padding(EdgeInsets(top: 150, leading: 200, bottom: 0, trailing: 0))
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        
                        VStack {
                            HealthCardtwo(title: "  الملاحظات الطبية", value: "\(medicalNotes)", graphName: "pencil.and.list.clipboard", color: .blue,isSystemImage: true)
                            
                            HStack{
                                Button(action: {
                                    // This will set showUpdateView to true, presenting the modal
                                    
                                    
                                    self.showUpdateView3 = true
                                }) {
                                    Image(systemName: "pencil.circle.fill") // Using a pencil icon
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                        .padding()
                                }
                                .sheet(isPresented: $showUpdateView3) {
                                    UpdateViewnotes(medicalNotes: $medicalNotes, onApply: {
                                        self.updateMedNotes()
                                    })
                                }}
                            .padding(EdgeInsets(top: -70, leading: 310, bottom: 0, trailing: 0))
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        
                        
                        
                    }
                }
                .navigationBarHidden(true)
            }
        }.onAppear {
            fetchHealthData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Wait for 1 second before calling update 1.0
                retriveHealthData()
            }
            
        }
        
        .fullScreenCover(isPresented: $showingHomePage) {
            NeedaHomePage()
        }
    }
    
    
    //------------ health kit functions
    
    private func fetchHealthData() {
        // Ensure to request permissions before fetching
        HealthDataManager.shared.requestHealthKitPermissions { success, _ in
            guard success else { return }
            
            HealthDataManager.shared.fetchHeartRate { sample, _ in
                if let sample = sample {
                    let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    self.heartRate = "\(Int(value)) bpm"
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
    
    //------------ clould kit functions
    
    private func retriveHealthData() {
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID"),
              let healthInfoRecordIDString = UserDefaults.standard.string(forKey: "healthInfoRecord") ,
              let chrioncRecordIDString = UserDefaults.standard.string(forKey: "chroincRecord")else {
            print("User record ID not found line 213")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let healthInfoRecordID = CKRecord.ID(recordName: healthInfoRecordIDString)
        let chrioncRecordID = CKRecord.ID(recordName: chrioncRecordIDString)
        
        // Fetch Individual Record for Height and Weight
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    self.personname = record["FullName"] as? String ?? "No data"
                    self.age = record["Age"] as? Int ?? 0
                    self.idNUM = record["NationalID"] as? Int ?? 0
                    
                    self.gender = record["Gender"] as? String ?? "No data"
                    self.personal.append(personname)
                    self.personal.append("\(age)")
                    self.personal.append(gender)
                    self.personal.append("\(idNUM)")
                    
                    
                } else {
                    print("Error fetching individual record Hight and Wight: \(error?.localizedDescription ?? "No error description")")
                }
            }
        }
        
        
        // Fetch Individual Record for name and age
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    self.height = record["Hight"] as? String ?? "No data"
                    self.weight = record["Wight"] as? String ?? "No data"
                } else {
                    print("Error fetching individual record Hight and Wight: \(error?.localizedDescription ?? "No error description")")
                }
            }
        }
        
        // Fetch Health Information Record for Blood Type
        privateDatabase.fetch(withRecordID: healthInfoRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    self.bloodType = record["BloodType"] as? String ?? "No data"
                    self.alergies = record["Allergies"] as? String ?? "No data"
                } else {
                    print("Error fetching health information record BloodType and Allergies: \(error?.localizedDescription ?? "No error description")")
                }
            }
        }
        
        // Fetch Health Information Record for Blood Type
        privateDatabase.fetch(withRecordID: healthInfoRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    self.medicalNotes = record["MedicalNotes"] as? String ?? "No data"
                } else {
                    print("Error fetching health information record DiseseName: \(error?.localizedDescription ?? "No error description")")
                }
            }
        }
        
        
        let predicate3 = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let query3 = CKQuery(recordType: "ChroincDiseses", predicate: predicate3)
        
        privateDatabase.perform(query3, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle the error appropriately
                    print("Error fetching chronic desies records: \(error.localizedDescription)")
                    return
                }
                //
                guard let records = records else {
                    print("No chronic desies records found for user.")
                    return
                }
                
                for record in records {
                    if let cname = record["DiseseName"] as? String
                    {
                        let chronincString = "اسم المرض: \(cname)"
                        self.chronincs.append(chronincString)
                    }
                }
                
                if self.chronincs.isEmpty {
                    print("User has no chronincs.")
                } else {
                    print("chronincs fetched for the user: \(self.chronincs)")
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
        // Debug print
        print("UserRecordIDMed: \(userRecordIDMed)")
        
        
        print("UserRecordID: \(userRecordID)")
        
        
        let predicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let query = CKQuery(recordType: "Medications", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle the error
                    print("Error fetching medications records: \(error.localizedDescription)")
                    return
                }
                //
                guard let records = records else {
                    print("No medication records found for user.")
                    return
                }
                //
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
        
        
        
        // Query for surgeries Records related to the User
        guard let userRecordIDStringSur = UserDefaults.standard.string(forKey: "surgeryRecord")
        else {
            print("User record ID not found line 213 surgeryRecord")
            return
        }
        
        let userRecordIDSur = CKRecord.ID(recordName: userRecordIDStringSur)
        // Debug print
        print("UserRecordIDSur: \(userRecordIDSur)")
        
        
        print("UserRecordID: \(userRecordID)")
        
        let predicate2 = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let query2 = CKQuery(recordType: "PerviousSurgies", predicate: predicate2)
        
        privateDatabase.perform(query2, inZoneWith: nil) { records2, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle the error
                    print("Error fetching Surgies records: \(error.localizedDescription)")
                    return
                }
                
                guard let records2 = records2 else {
                    print("No medication records found for user.")
                    return
                }
                
                for record in records2 {
                    if let sname = record["SurgeryName"] as? String,
                       let year = record["Year"] as? String {
                        let surgeriesString = "اسم العملية: \(sname)\nسنة الإجراء: \(year)"
                        self.surgeries.append(surgeriesString)
                    }
                }
                
                if self.surgeries.isEmpty {
                    print("User has no surgeries.")
                } else {
                    print("surgeries fetched for the user: \(self.surgeries)")
                }
            }
        }
        
        
        
    }// end of the function
    
    
    
    func updatePersonalInformation() {
        print("Updating personal information with:", personal)
        
        
        guard let ageInt = Int(personal[1]) else {
            print(" Age, is not in the correct format.")
            return
        }
        
        guard let IdInt = Int(personal[3]) else {
            print("Id is not in the correct format.")
            return
        }
        
        
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            if let record = record, error == nil {
                // Update record fields
                record["FullName"] = personal[0]
                record["Age"] = ageInt
                record["Gender"] = personal[2]
                record["NationalID"] = IdInt
                
                // Save the updated record
                privateDatabase.save(record) { _, error in
                    if let error = error {
                        // Handle error
                        print("Error updating record: \(error.localizedDescription)")
                    } else {
                        // Success
                        print("Record updated successfully")
                    }
                }
            } else {
                print("Error fetching record to update: \(error?.localizedDescription ?? "No error description")")
            }
        }
    }
    
    
    func updateAllergies() {
        print("Updating personal information with:", alergies)
        
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "healthInfoRecord") else {
            print("User record health ID not found")
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            if let record = record, error == nil {
                // Update record fields
                record["Allergies"] = alergies
                
                // Save the updated record
                privateDatabase.save(record) { _, error in
                    if let error = error {
                        // Handle error
                        print("Error updating allergy record: \(error.localizedDescription)")
                    } else {
                        // Success
                        print("allergy record updated successfully")
                    }
                }
            } else {
                print("Error fetching allergy record to update: \(error?.localizedDescription ?? "No error description")")
            }
        }
    } //End of update allargies
    
    
    
    func updateMedNotes() {
        print("Updating personal information with:", medicalNotes)
        
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "healthInfoRecord") else {
            print("User record health ID not found")
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            if let record = record, error == nil {
                // Update record fields
                record["MedicalNotes"] = medicalNotes
                
                // Save the updated record
                privateDatabase.save(record) { _, error in
                    if let error = error {
                        // Handle error
                        print("Error updating med notes record: \(error.localizedDescription)")
                    } else {
                        // Success
                        print("med notes record updated successfully")
                    }
                }
            } else {
                print("Error fetching med notes record to update: \(error?.localizedDescription ?? "No error description")")
            }
        }
    } //End of update mednotes
    
    
    
    
    
    func prepareSurgeryData(surgeries: [String]){
        surgeryNames = [String]()
        surgeryYears = [String]()
        
        for surgery in surgeries {
            let components = surgery.components(separatedBy: "\n")
            if components.count > 1 {
                let nameComponent = components[0]
                let yearComponent = components[1]
                
                if let nameIndex = nameComponent.range(of: ": ")?.upperBound,
                   let yearIndex = yearComponent.range(of: ": ")?.upperBound {
                    let name = String(nameComponent[nameIndex...])
                    let year = String(yearComponent[yearIndex...])
                    
                    surgeryNames.append(name)
                    surgeryYears.append(year)
                }
            }
        }
        
        
    }//End of prepareSurgeryData
    
    
    func updateSurgeries(surgeryNames: [String], surgeryYears: [String], completion: @escaping (Bool) -> Void) {
        guard let SurRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            completion(false)
            return
        }
        
        // Set up CloudKit container and database objects
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: SurRecordIDString)
        
        let predicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let query = CKQuery(recordType: "PerviousSurgies", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching surgeries: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Ensure records were fetched
            guard let records = records else {
                print("Error: No records fetched for deletion.")
                completion(false)
                return
            }
            
            // Use a Dispatch Group to synchronize the deletion operations
            let dispatchGroup = DispatchGroup()
            
            // Iterate over fetched records to delete them
            for record in records {
                dispatchGroup.enter() // Enter the group for each deletion operation
                privateDatabase.delete(withRecordID: record.recordID) { _, error in
                    if let error = error {
                        print("Error deleting surgery record: \(error.localizedDescription)")
                        // Handle partial failure if needed
                    }
                    dispatchGroup.leave() // Leave the group once operation completes
                }
            }
            
            // After all deletions have been initiated...
            dispatchGroup.notify(queue: .main) {
                // Track if any errors occurred during creation
                var creationErrors: Bool = false
                
                // Iterate over the new surgery data to create new records
                for (index, name) in surgeryNames.enumerated() {
                    let surgeryRecord = CKRecord(recordType: "PerviousSurgies")
                    surgeryRecord["SurgeryName"] = name
                    surgeryRecord["Year"] = surgeryYears[index]
                    surgeryRecord["UserID"] = CKRecord.Reference(recordID: userRecordID, action: .none)
                    
                    dispatchGroup.enter() // Enter the group for each creation operation
                    privateDatabase.save(surgeryRecord) { _, error in
                        if let error = error {
                            print("Error saving new surgery record: \(error.localizedDescription)")
                            creationErrors = true // Mark that an error occurred
                        }
                        dispatchGroup.leave() // Leave the group once operation completes
                    }
                }
                
                // After all creation operations have been initiated...
                dispatchGroup.notify(queue: .main) {
                    // Call the completion handler with the success status
                    // Success is true if no errors occurred during creation
                    completion(!creationErrors)
                }
            }
        }
    }//end of update surguries on cloud
    
    
    
    func prepareMedicatinData(medications: [String]) {
        MedicationNames = [String]()
        Medicationdoses = [String]()
        Medicationunits = [String]()
        
        for medication in medications {
            let components = medication.components(separatedBy: "\n")
            if components.count > 1 {
                let nameComponent = components[0]
                let doseComponent = components[1]
                let unitComponent = components[2]
                
                if let nameIndex = nameComponent.range(of: ": ")?.upperBound,
                   let doseIndex = doseComponent.range(of: ": ")?.upperBound,
                   let unitIndex = unitComponent.range(of: ": ")?.upperBound{
                    let name = String(nameComponent[nameIndex...])
                    let dose = String(doseComponent[doseIndex...])
                    let unit = String(unitComponent[unitIndex...])
                    
                    MedicationNames.append(name)
                    Medicationdoses.append(dose)
                    Medicationunits.append(unit)
                    
                }
            }
        }
        
        
    }//End of prepareSurgeryData
    
    
    
    
    func updateMedications(MedicationNames: [String], Medicationdoses: [String], Medicationunits: [String], completion: @escaping (Bool) -> Void) {
        // Ensure there's a user record ID available in UserDefaults
        guard let userRecordIDStringMed = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            completion(false)
            return
        }
        
        // Set up CloudKit container and database objects
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDStringMed)
        
        // Create a predicate to find surgery records related to the user
        let predicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let query = CKQuery(recordType: "Medications", predicate: predicate)
        
        // Perform the query to fetch existing surgery records
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching Medications: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Ensure records were fetched
            guard let records = records else {
                print("Error: No Medications records fetched for deletion.")
                completion(false)
                return
            }
            
            // Use a Dispatch Group to synchronize the deletion operations
            let dispatchGroup = DispatchGroup()
            
            // Iterate over fetched records to delete them
            for record in records {
                dispatchGroup.enter() // Enter the group for each deletion operation
                privateDatabase.delete(withRecordID: record.recordID) { _, error in
                    if let error = error {
                        print("Error deleting Medications record: \(error.localizedDescription)")
                        // Handle partial failure if needed
                    }
                    dispatchGroup.leave() // Leave the group once operation completes
                }
            }
            
            // After all deletions have been initiated...
            dispatchGroup.notify(queue: .main) {
                // Track if any errors occurred during creation
                var creationErrors: Bool = false
                
                // Iterate over the new surgery data to create new records
                for (index, name) in MedicationNames.enumerated() {
                    let medicationRecord = CKRecord(recordType: "Medications")
                    medicationRecord["MedicineName"] = name
                    medicationRecord["DoseOfMedication"] = Medicationdoses[index]
                    medicationRecord["DoseUnit"] = Medicationunits[index]
                    
                    medicationRecord["UserID"] = CKRecord.Reference(recordID: userRecordID, action: .none)
                    
                    dispatchGroup.enter() // Enter the group for each creation operation
                    privateDatabase.save(medicationRecord) { _, error in
                        if let error = error {
                            print("Error saving new surgery record: \(error.localizedDescription)")
                            creationErrors = true // Mark that an error occurred
                        }
                        dispatchGroup.leave() // Leave the group once operation completes
                    }
                }
                
                // After all creation operations have been initiated...
                dispatchGroup.notify(queue: .main) {
                    // Call the completion handler with the success status
                    // Success is true if no errors occurred during creation
                    completion(!creationErrors)
                }
            }
        }
    }//end of update medications on cloud
    
    
    
    
    func prepareChronicData(chronincs: [String]){
        chronincNames = [String]()
        
        
        for chroninc in chronincs {
            
            if let nameIndex = chroninc.range(of: ": ")?.upperBound{
                let name = String(chroninc[nameIndex...])
                chronincNames.append(name)
                
            }
        }
        
        
    }//end of prepareChronicData
    
    
    func updateChronic(chronincNames: [String], completion: @escaping (Bool) -> Void) {
        // Ensure there's a user record ID available in UserDefaults
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            completion(false)
            return
        }
        
        // Set up CloudKit container and database objects
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Create a predicate to find surgery records related to the user
        let predicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let query = CKQuery(recordType: "ChroincDiseses", predicate: predicate)
        
        // Perform the query to fetch existing surgery records
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching ChroincDiseses: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Ensure records were fetched
            guard let records = records else {
                print("Error: No ChroincDiseses records fetched for deletion.")
                completion(false)
                return
            }
            
            // Use a Dispatch Group to synchronize the deletion operations
            let dispatchGroup = DispatchGroup()
            
            // Iterate over fetched records to delete them
            for record in records {
                dispatchGroup.enter() // Enter the group for each deletion operation
                privateDatabase.delete(withRecordID: record.recordID) { _, error in
                    if let error = error {
                        print("Error deleting ChroincDiseses record: \(error.localizedDescription)")
                        // Handle partial failure if needed
                    }
                    dispatchGroup.leave() // Leave the group once operation completes
                }
            }
            
            // After all deletions have been initiated...
            dispatchGroup.notify(queue: .main) {
                // Track if any errors occurred during creation
                var creationErrors: Bool = false
                
                // Iterate over the new surgery data to create new records
                for (index, name) in chronincNames.enumerated() {
                    let chronicRecord = CKRecord(recordType: "ChroincDiseses")
                    chronicRecord["DiseseName"] = name
                    
                    
                    chronicRecord["UserID"] = CKRecord.Reference(recordID: userRecordID, action: .none)
                    
                    dispatchGroup.enter() // Enter the group for each creation operation
                    privateDatabase.save(chronicRecord) { _, error in
                        if let error = error {
                            print("Error saving new chronic record: \(error.localizedDescription)")
                            creationErrors = true // Mark that an error occurred
                        }
                        dispatchGroup.leave() // Leave the group once operation completes
                    }
                }
                
                // After all creation operations have been initiated...
                dispatchGroup.notify(queue: .main) {
                    // Call the completion handler with the success status
                    // Success is true if no errors occurred during creation
                    completion(!creationErrors)
                }
            }
        }
    }//end of update chronic on cloud
    
    
    
    
    
    func addNewMedication(name: String, dose: String, unit: String) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let medicationRecord = CKRecord(recordType: "Medications")
        medicationRecord["MedicineName"] = name
        medicationRecord["DoseOfMedication"] = dose
        medicationRecord["DoseUnit"] = unit
        medicationRecord["UserID"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: userRecordIDString), action: .none)
        
        privateDatabase.save(medicationRecord) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving new medication record: \(error.localizedDescription)")
                } else {
                    print("New medication added successfully")
                    let newMedicationString = "الدواء: \(name)\nالجرعة: \(dose)\nالوحدة: \(unit)"
                    self.medications.append(newMedicationString)
                }
            }
        }
    } //end of adding medication
    
    
    
    func addNewSurgury(name: String, year: String) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let surgeriesRecord = CKRecord(recordType: "PerviousSurgies")
        surgeriesRecord["SurgeryName"] = name
        surgeriesRecord["Year"] = year
        surgeriesRecord["UserID"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: userRecordIDString), action: .none)
        
        privateDatabase.save(surgeriesRecord) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving new surgery record: \(error.localizedDescription)")
                } else {
                    print("New medication added successfully")
                    let newSurgeryString = " اسم العملية: \(name)\nسنة الإجراء: \(year)"
                    self.surgeries.append(newSurgeryString)
                }
            }
        }
    } //end of adding Surgery
    
    
    
    func addNewChroninc(name: String) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let ChroincDisesesRecord = CKRecord(recordType: "ChroincDiseses")
        ChroincDisesesRecord["DiseseName"] = name
        ChroincDisesesRecord["UserID"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: userRecordIDString), action: .none)
        
        privateDatabase.save(ChroincDisesesRecord) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving new surgery record: \(error.localizedDescription)")
                } else {
                    print("New medication added successfully")
                    let newchronincString = " اسم المرض: \(name)"
                    self.chronincs.append(newchronincString)
                }
            }
        }
    } //end of adding Surgery
    
} // End of struct NewmedicalHistory

// Custom health card view with icon and value.







struct HealthCardPersonaInfo: View {
    var title: String
    var personal: [String] // This array should contain the name, age, and gender in order.
    var graphName: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 30))
                .padding(.bottom, 5)
                .padding(.leading, 60)
                .foregroundColor( .red)
            
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    // Display Name with title
                    if personal.indices.contains(0) {
                        Text("الاسم: \(personal[0])")
                            .font(.subheadline)
                            .padding(.vertical, 2)
                            .font(.system(size: 18))
                        
                        // Display Id with title
                        if personal.indices.contains(3) {
                            Text("الهوية الوطنية: \(personal[3])")
                                .font(.subheadline)
                                .padding(.vertical, 2)
                                .font(.system(size: 18))
                            
                        }
                    }
                    // Display Age with title
                    if personal.indices.contains(1) {
                        Text("العمر: \(personal[1])")
                            .font(.subheadline)
                            .padding(.vertical, 2)
                            .font(.system(size: 18))
                        
                    }
                    // Display Gender with title
                    if personal.indices.contains(2) {
                        Text("الجنس: \(personal[2])")
                            .font(.subheadline)
                            .padding(.vertical, 2)
                            .font(.system(size: 18))
                        
                    }
                    
                }
                .padding(.horizontal)
            }
            .frame(minHeight: 100)
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: graphName)
                    .imageScale(.large)
                    .foregroundColor(.red)
                    .padding(.top , -175)
                    .padding(.leading, -330)
                    .font(.system(size: 25))
                
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}



struct HealthCardSurgeries: View {
    var title: String
    var surgeries: [String] // This should be an array of medication descriptions
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 30))
                .foregroundColor( .red)
                .padding(.top, 10)
                .padding(.leading, 75)
            
            ScrollView {
                ForEach(surgeries, id: \.self) { surgery in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(surgery) // The string includes new lines and labels
                            .font(.subheadline)
                            .padding(.vertical, 2)
                            .font(.system(size: 18))
                        
                    }
                }
                .padding(.horizontal)
            }
            .frame(minHeight: 100)
            
            
            
            Spacer()
            
            HStack {
                Spacer()
                Image("hospital-bed")
                    .resizable()
                    .frame(width: 55, height: 55)
                    .imageScale(.large)
                    .foregroundColor(.red)
                    .padding(.top , -190)
                    .padding(.leading, -330)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
    
}

struct HealthCardChronic: View {
    var title: String
    var chronincs: [String]
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 30))
                .foregroundColor( .red)
                .padding(.top, 10)
                .padding(.leading, 55)
            
            ScrollView {
                ForEach(chronincs, id: \.self) { chroninc in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(chroninc) // The string includes new lines and labels
                            .font(.subheadline)
                            .padding(.vertical, 2)
                            .font(.system(size: 23))
                        
                    }
                }
                .padding(.horizontal)
            }
            .frame(minHeight: 100)
            
            
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: "bandage.fill")
                    .resizable()
                    .frame(width: 33, height: 33)
                    .imageScale(.large)
                    .foregroundColor(.red)
                    .padding(.top , -170)
                    .padding(.leading, -330)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
    
}



struct UpdateView: View {
    @Binding var personal: [String]  // Assumes: [0] Name, [1] Age, [2] Gender, [3] ID
    let onApply: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var originalPersonal: [String] = []
    @State private var nameErrorMessage: String = ""
    @State private var ageErrorMessage: String = ""
    @State private var genderErrorMessage: String = ""
    @State private var idErrorMessage: String = ""
    let genders = ["ذكر", "أنثى", "غير محدد"] // Gender options for dropdown
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("تعديل المعلومات الشخصية")
                        .font(.headline)
                        .padding([.top, .horizontal])
                        .multilineTextAlignment(.leading)
                    
                    // Name field
                    Text("الاسم")
                    TextField("الاسم", text: $personal[0])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: personal[0], perform: { _ in validateName() })
                    
                    if !nameErrorMessage.isEmpty {
                        Text(nameErrorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Age field
                    Text("العمر")
                    TextField("العمر", text: $personal[1])
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: personal[1], perform: { _ in validateAge() })
                    
                    if !ageErrorMessage.isEmpty {
                        Text(ageErrorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Gender field
                    Text("الجنس")
                    Picker("الجنس", selection: $personal[2]) {
                        ForEach(genders, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                    .clipped()
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .onChange(of: personal[2], perform: { _ in validateGender() })
                    
                    if !genderErrorMessage.isEmpty {
                        Text(genderErrorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // ID field
                    Text("الهوية الوطنية")
                    TextField("الهوية الوطنية", text: $personal[3])
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: personal[3], perform: { _ in validateID() })
                    
                    if !idErrorMessage.isEmpty {
                        Text(idErrorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Buttons
                    HStack {
                        Button("تعديل") {
                            if validateInputs() {
                                onApply() // Proceed if validation passes
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .disabled(!hasChanges() || !validateInputs())
                        .foregroundColor(hasChanges() && validateInputs() ? .red : .gray)
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            resetForm()
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.bottom)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            originalPersonal = personal
        }
        .environment(\.layoutDirection, .rightToLeft)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func hasChanges() -> Bool {
        return originalPersonal != personal
    }
    
    private func validateInputs() -> Bool {
        return validateName() && validateAge() && validateGender() && validateID()
    }
    
    private func validateName() -> Bool {
        if personal[0].isEmpty || !personal[0].allSatisfy({ $0.isLetter || $0.isWhitespace }) {
            nameErrorMessage = "الاسم يجب أن يحتوي على حروف ولا يكون فارغًا."
            return false
        }
        nameErrorMessage = ""
        return true
    }
    
    func validateEnglishName(_ name: String) -> Bool {
        let englishNameRegex = "^[A-Za-z]+(\\s+[A-Za-z]+){3}$" // Exactly 4 English names
        
        let nameValidation = NSPredicate(format: "SELF MATCHES %@", englishNameRegex)
        return nameValidation.evaluate(with: name)
    }
    
    func validateArabicName(_ name: String) -> Bool {
        let arabicNameRegex = "^[\\u0600-\\u06FF]+(\\s+[\\u0600-\\u06FF]+){3}$" // Exactly 4 Arabic names
        
        let nameValidation = NSPredicate(format: "SELF MATCHES %@", arabicNameRegex)
        return nameValidation.evaluate(with: name)
    }
    private func validateAge() -> Bool {
        guard let age = Int(personal[1]), age >= 18, age <= 100 else {
            ageErrorMessage = "العمر يجب أن يكون بين 18 و 100."
            return false
        }
        ageErrorMessage = ""
        return true
    }
    
    private func validateGender() -> Bool {
        if !genders.contains(personal[2]) {
            genderErrorMessage = "يرجى اختيار جنس صحيح."
            return false
        }
        genderErrorMessage = ""
        return true
    }
    
    private func validateID() -> Bool {
        let idRegex = "^[0-9]{10}$"
        if !NSPredicate(format: "SELF MATCHES %@", idRegex).evaluate(with: personal[3]) {
            idErrorMessage = "الهوية الوطنية يجب أن تكون 10 أرقام."
            return false
        }
        idErrorMessage = ""
        return true
    }
    
    private func resetForm() {
        personal = originalPersonal
    }
}










struct UpdateViewAllergy: View {
    
    
    @Binding var allergies: String
    let onApply: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var originalAllergies: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) { // Consistent with the first view
                    Text("تعديل الحساسية")
                        .font(.headline)
                        .padding([.top, .horizontal])
                        .multilineTextAlignment(.leading)
                    
                    TextField("الحساسية", text: $allergies)
                        .multilineTextAlignment(.leading) // Right alignment for RTL
                        .onChange(of: allergies) { newValue in
                            validateAllergies(newValue)
                        }
                        .onAppear {
                            originalAllergies = allergies // Storing the original allergies
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.vertical, 5) // Consistent vertical padding for error messages
                    }
                    
                    HStack {
                        Button("تعديل") {
                            if validateInput() {
                                onApply() // Applies the changes if validation passes
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .disabled(allergies == originalAllergies || !errorMessage.isEmpty) // Disabling button logic
                        .foregroundColor(allergies == originalAllergies || !errorMessage.isEmpty ? .gray : .blue)
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.bottom) // Padding adjustment for buttons
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // Ensuring RTL layout
        .edgesIgnoringSafeArea(.all)
    }
    
    private func validateAllergies(_ allergies: String) {
        if allergies.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "لا يمكن أن يكون حقل الحساسية فارغاً."
        } else {
            errorMessage = ""
        }
    }
    
    private func validateInput() -> Bool {
        return errorMessage.isEmpty && allergies != originalAllergies
    }
}



struct UpdateViewnotes: View {
    @Binding var medicalNotes: String
    let onApply: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var originalNotes: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) { // Reduced spacing to decrease overall height
                    Text("تعديل الملاحظات الطبية")
                        .font(.headline)
                        .padding([.top, .horizontal])
                        .multilineTextAlignment(.leading)
                    
                    TextField("الملاحظات الطبية", text: $medicalNotes)
                        .multilineTextAlignment(.leading) // Aligns text inside TextField to the right
                        .onChange(of: medicalNotes) { newValue in
                            validateMedicalNotes(newValue)
                        }
                        .onAppear {
                            originalNotes = medicalNotes // Set the original notes on first appearance
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.vertical, 5) // Reduced padding to decrease height
                    }
                    
                    HStack {
                        Button("تعديل") {
                            if validateInput() {
                                onApply() // This calls the update function passed
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        .disabled(medicalNotes == originalNotes || !errorMessage.isEmpty) // Disable button if no changes or errors are present
                        .foregroundColor(medicalNotes == originalNotes || !errorMessage.isEmpty ? .gray : .blue) // Change text color based on enabled state
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.bottom) // Reduced padding to decrease height
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
        .edgesIgnoringSafeArea(.all)
    }
    
    private func validateMedicalNotes(_ notes: String) {
        if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "الملاحظات الطبية لا يجب أن تكون فارغة"
        } else {
            errorMessage = ""
        }
    }
    
    private func validateInput() -> Bool {
        return errorMessage.isEmpty
    }
}



//end of update notes struct



struct UpdateSurgeriesView: View {
    @Binding var surgeryNames: [String]
    @Binding var surgeryYears: [String]
    @Binding var surgeries: [String]
    let onApply: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var errorMessage: String = ""
    let years: [String] = Array(1980...2024).reversed().map(String.init)
    @State private var originalStates: [[String]] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()
                
                Text("تعديل العمليات الجراحية")
                    .font(.headline)
                    .padding()
                
                ForEach(Array(surgeryNames.indices), id: \.self) { index in
                    surgeryEntry(index: index)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer(minLength: 20)
                
                HStack {
                    Button("تعديل") {
                        if validateSurgeries() {
                            surgeries.removeAll()
                            for index in surgeryNames.indices {
                                let surgeryString = "اسم العملية: \(surgeryNames[index]), سنة الإجراء: \(surgeryYears[index])"
                                surgeries.append(surgeryString)
                            }
                            onApply()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(!validateSurgeries() || !hasChanges())
                    .foregroundColor(hasChanges() && validateSurgeries() ? .blue : .gray)
                    
                    Spacer()
                    
                    Button("إلغاء") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
                .padding(.bottom)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
        .onAppear {
            originalStates = surgeryNames.indices.map { [surgeryNames[$0], surgeryYears[$0]] }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func surgeryEntry(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("اسم العملية:")
                .bold()
            TextField("ادخل اسم العملية", text: $surgeryNames[index])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            
            Text("سنة الإجراء:")
            Picker("اختر سنة الإجراء", selection: $surgeryYears[index]) {
                ForEach(years, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .clipped()
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
            .padding(.bottom, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func validateSurgeries() -> Bool {
        for (name, year) in zip(surgeryNames, surgeryYears) {
            if name.isEmpty || year.isEmpty || !years.contains(year) {
                errorMessage = "اسم العملية والسنة يجب ألا يكونا فارغين ويجب أن تكون السنة ضمن النطاق المحدد."
                return false
            }
        }
        errorMessage = ""
        return true
    }
    
    private func hasChanges() -> Bool {
        for (index, original) in originalStates.enumerated() {
            if original != [surgeryNames[index], surgeryYears[index]] {
                return true
            }
        }
        return false
    }
}



struct UpdateMedicationView: View {
    @Binding var medications: [String]
    @Binding var MedicationNames: [String]
    @Binding var Medicationdoses: [String]
    @Binding var Medicationunits: [String]
    let onApply: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var errorMessage: String = ""
    let doses = ["غير محدد", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    let units = ["غير محدد", "غرام", "ملل", "ملغ"]
    @State private var originalStates: [[String]] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer()
                
                Text("تعديل الأدوية")
                    .font(.headline)
                    .padding()
                
                ForEach(MedicationNames.indices, id: \.self) { index in
                    medicationEntry(index: index)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer(minLength: 20)
                
                HStack {
                    Button("تعديل") {
                        applyUpdates()
                    }
                    .disabled(!validateInputs() || !hasChanges())
                    .foregroundColor(hasChanges() && validateInputs() ? Color.blue : Color.gray)
                    
                    Spacer()
                    
                    Button("إلغاء") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
                .padding(.bottom)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
        .onAppear {
            originalStates = MedicationNames.indices.map { [MedicationNames[$0], Medicationdoses[$0], Medicationunits[$0]] }
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
    }
    
    private func medicationEntry(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("اسم الدواء:")
                .bold()
            TextField("ادخل اسم الدواء", text: $MedicationNames[index])
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 5)
            
            dosePicker(index: index)
            unitPicker(index: index)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func dosePicker(index: Int) -> some View {
        VStack {
            Text("الجرعة:")
            Picker("اختر الجرعة", selection: $Medicationdoses[index]) {
                ForEach(doses, id: \.self) { dose in
                    Text(dose).tag(dose)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .clipped()
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
            .padding(.bottom, 5)
        }
    }
    
    private func unitPicker(index: Int) -> some View {
        VStack {
            Text("الوحدة:")
            Picker("اختر الوحدة", selection: $Medicationunits[index]) {
                ForEach(units, id: \.self) { unit in
                    Text(unit).tag(unit)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .clipped()
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
            .padding(.bottom, 10)
        }
    }
    
    private func applyUpdates() {
        if validateInputs() {
            medications.removeAll()
            for index in MedicationNames.indices {
                let medicationString = "الدواء: \(MedicationNames[index]), الجرعة: \(Medicationdoses[index]), الوحدة: \(Medicationunits[index])"
                medications.append(medicationString)
            }
            onApply()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func validateInputs() -> Bool {
        var isValid = true
        for index in MedicationNames.indices {
            if !validateMedicationName(MedicationNames[index]) ||
                !validateDose(Medicationdoses[index]) ||
                !validateUnit(Medicationunits[index]) {
                isValid = false
                errorMessage = "تحقق من البيانات المدخلة"
                break
            }
        }
        if isValid { errorMessage = "" }
        return isValid
    }
    
    private func validateMedicationName(_ name: String) -> Bool {
        !name.isEmpty
    }
    
    private func validateDose(_ dose: String) -> Bool {
        doses.contains(dose)
    }
    
    private func validateUnit(_ unit: String) -> Bool {
        units.contains(unit)
    }
    
    private func hasChanges() -> Bool {
        for (index, original) in originalStates.enumerated() {
            if original != [MedicationNames[index], Medicationdoses[index], Medicationunits[index]] {
                return true
            }
        }
        return false
    }
}


struct DropdownPicker: View {
    var title: String
    @Binding var selection: String
    var options: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .bold()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? "اختر" : selection)
                        .foregroundColor(selection.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding(.bottom, 5)
    }
}






struct UpdateChronicView: View {
    @Binding var chronics: [String]
    @Binding var chronicNames: [String]
    
    let onApply: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var originalChronicNames: [String] = []
    @State private var errorMessage: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("تعديل الأمراض المزمنة")
                        .font(.headline)
                        .padding([.top, .horizontal])
                        .multilineTextAlignment(.leading)
                    
                    ForEach(Array(chronicNames.indices), id: \.self) { index in
                        TextField("اسم المرض", text: $chronicNames[index])
                            .onChange(of: chronicNames[index]) { newValue in
                                validateChronicName(newValue, at: index)
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .multilineTextAlignment(.leading)
                    }
                    .onDelete(perform: deleteChronic)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.vertical, 5)
                    }
                    
                    HStack {
                        Button(action: {
                            if validateChronics() {
                                chronics.removeAll()
                                for name in chronicNames {
                                    let chronicString = "اسم المرض: \(name)"
                                    chronics.append(chronicString)
                                }
                                onApply()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("تعديل")
                        }
                        .disabled(!isChanged()) // Check if changes were made
                        .foregroundColor(isChanged() ? .blue : .gray) // Color reflects enabled/disabled state
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.bottom)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            originalChronicNames = chronicNames 
        }
        .environment(\.layoutDirection, .rightToLeft)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func deleteChronic(at offsets: IndexSet) {
        chronicNames.remove(atOffsets: offsets)
    }
    
    private func validateChronics() -> Bool {
        for name in chronicNames {
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorMessage = "يجب ألا تكون أسماء الأمراض المزمنة فارغة."
                return false
            }
        }
        errorMessage = ""
        return true
    }
    
    private func validateChronicName(_ name: String, at index: Int) {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "اسم المرض المزمن في الخانة \(index + 1) فارغ."
        } else {
            errorMessage = ""
        }
    }
    
    private func isChanged() -> Bool {
        return chronicNames != originalChronicNames
    }
}






struct AddMedicationView: View {
    @Environment(\.presentationMode) var presentationMode
    var onAdd: (String, String, String) -> Void
    
    @State private var medicationName: String = ""
    @State private var medicationDose: String = "غير محدد"
    @State private var medicationUnit: String = "غير محدد"
    
    let doses = ["غير محدد", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    let units = ["غير محدد", "غرام", "ملل", "ملغ"]
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("أضف دواءً جديدًا")
                    .font(.headline)
                    .padding([.top, .horizontal])
                    .multilineTextAlignment(.leading)
                
                Text("اسم الدواء")
                TextField("ادخل اسم الدواء هنا", text: $medicationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                
                Text("الجرعة")
                Picker("اختر الجرعة", selection: $medicationDose) {
                    ForEach(doses, id: \.self) { dose in
                        Text(dose).tag(dose)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                .clipped()
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                .padding(.bottom, 5)
                
                Text("الوحدة")
                Picker("اختر الوحدة", selection: $medicationUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                .clipped()
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                .padding(.bottom, 10)
                
                HStack {
                    Button("أضف الدواء") {
                        onAdd(medicationName, medicationDose, medicationUnit)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(medicationName.isEmpty || medicationDose == "غير محدد" || medicationUnit == "غير محدد")
                    .foregroundColor(medicationName.isEmpty || medicationDose == "غير محدد" || medicationUnit == "غير محدد" ? .gray : .blue)
                    
                    Spacer()
                    
                    Button("إلغاء") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
                .padding(.bottom)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            Spacer()
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
        .edgesIgnoringSafeArea(.all)
    }
}











struct AddSurgyryView: View  {
    
    @Environment(\.presentationMode) var presentationMode
    var onSurgeryAdd: (String, String) -> Void
    
    @State private var surgeryName: String = ""
    @State private var surgeryYear: String = "2024"
    let years: [String] = Array(1980...2024).reversed().map(String.init)
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("إضافة عملية جديدة")
                    .font(.headline)
                    .padding([.top, .horizontal])
                
                Group {
                    Text("اسم العملية:")
                        .bold()
                    TextField("ادخل اسم العملية", text: $surgeryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                    
                    Text("سنة الإجراء:")
                        .bold()
                    Picker("اختر سنة الإجراء", selection: $surgeryYear) {
                        ForEach(years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                    .clipped()
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                }
                .padding(.bottom, 5)
                
                HStack {
                    Button("أضف عملية") {
                        onSurgeryAdd(surgeryName, surgeryYear)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(surgeryName.isEmpty || surgeryYear.isEmpty || surgeryYear == "2024")
                    .foregroundColor(surgeryName.isEmpty || surgeryYear.isEmpty || surgeryYear == "2024" ? .gray : .blue)
                    
                    Spacer()
                    
                    Button("إلغاء") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
                .padding(.bottom)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            Spacer()
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
        .edgesIgnoringSafeArea(.all)
    }
}



struct AddChronincView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var onChronicAdd: (String) -> Void
    
    @State private var chronicName: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // This spacer pushes the form down to occupy the lower half of the screen
                
                VStack(alignment: .leading, spacing: 10) { // Changed alignment to .trailing for RTL
                    Text("إضافة مرض مزمن جديد")
                        .font(.headline)
                        .padding([.top, .horizontal])
                        .multilineTextAlignment(.leading)
                    TextField("اسم المرض المزمن", text: $chronicName)
                        .multilineTextAlignment(.leading) // Aligns text inside TextField to the right
                    
                    HStack {
                        Button("أضف المرض المزمن") {
                            onChronicAdd(chronicName)
                            presentationMode.wrappedValue.dismiss()
                        }
                        .disabled(chronicName.isEmpty)
                        .foregroundColor(chronicName.isEmpty ? .gray : .blue)
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.bottom)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
        .edgesIgnoringSafeArea(.all)
    }
}




struct DeleteMedicationView: View {
    @Binding var medications: [String]
    @State private var selectedMedications: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer(minLength: 50) // Adjusted Spacer to push the list down less
                
                VStack(alignment: .leading, spacing: 10) { // Spacing and alignment to match previous designs
                    Text("حذف الأدوية")
                        .font(.headline)
                        .padding([.top, .horizontal])
                    
                    List(medications, id: \.self, selection: $selectedMedications) { medication in
                        Text(medication)
                    }
                    .frame(height: geometry.size.height * 0.4) // Set a dynamic height based on screen size
                    
                    HStack {
                        Button("حذف") {
                            deleteSelectedMedications()
                        }
                        .disabled(selectedMedications.isEmpty)
                        .foregroundColor(selectedMedications.isEmpty ? .gray : .blue)
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                    .padding(.bottom)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer(minLength: 50) // Adjusted Spacer to give more space at the bottom
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
        .edgesIgnoringSafeArea(.all)
    }
    
    func extractMedicationName(from fullMedicationString: String) -> String {
        let components = fullMedicationString.components(separatedBy: "\n")
        if let nameComponent = components.first(where: { $0.starts(with: "الدواء:") }) {
            let nameParts = nameComponent.components(separatedBy: ": ")
            if nameParts.count > 1 {
                return nameParts[1] // Return the part after "الدواء:"
            }
        }
        return "" // Return an empty string if the name isn't found
    }
    
    
    func deleteSelectedMedications() {
        for fullMedicationString in selectedMedications {
            if let index = medications.firstIndex(of: fullMedicationString) {
                medications.remove(at: index)
                // Extract the medication name from the full string
                let medicationName = extractMedicationName(from: fullMedicationString)
                // Call the method to delete from CloudKit
                deleteMedicationFromCloud(medication: medicationName) { success in
                    print("Deletion completion with success: \(success)")
                }
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    // Method to delete a medication from CloudKit
    func deleteMedicationFromCloud(medication: String , completion: @escaping (Bool) -> Void) {
        guard let userRecordIDStringMed = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            completion(false)
            return
        }
        
        // Set up CloudKit container and database objects
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDStringMed)
        
        // Create a predicate to find surgery records related to the user
        let userPredicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let medicationPredicate = NSPredicate(format: "MedicineName == %@", medication)
        
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, medicationPredicate])
        
        let query = CKQuery(recordType: "Medications", predicate: combinedPredicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil
            else {
                print("Error fetching medication records: \(error!.localizedDescription)")
                return
            }
            
            
            for record in records {
                privateDatabase.delete(withRecordID: record.recordID) { recordID, error in
                    if let error = error {
                        print("Error deleting record: \(error.localizedDescription)")
                    } else {
                        print("Medication record deleted successfully")
                    }
                }
            }
        }
    }
}

//end of medication delete






struct DeleteSurgeryView: View {
    @Binding var surgeries: [String]
    @State private var selectedSurgeries: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer(minLength: 50) // Adjusted Spacer to push the list down less
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("حذف العمليات الجراحية")
                        .font(.headline)
                        .padding([.top, .horizontal])
                    
                    List(surgeries, id: \.self, selection: $selectedSurgeries) { surgery in
                        Text(surgery)
                    }
                    .frame(height: geometry.size.height * 0.4) // Set a dynamic height based on screen size
                    
                    HStack {
                        Button("حذف") {
                            deleteSelectedSurgeries()
                        }
                        .disabled(selectedSurgeries.isEmpty)
                        .foregroundColor(selectedSurgeries.isEmpty ? .gray : .blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.bottom)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
        .edgesIgnoringSafeArea(.all)
    }
    
    func deleteSelectedSurgeries() {
        for fullsurgeryString in selectedSurgeries {
            if let index = surgeries.firstIndex(of: fullsurgeryString) {
                surgeries.remove(at: index)
                
                let surgeryName = extractSurgeryName(from: fullsurgeryString)
                
                deleteSurgeriesFromCloud(surgery: surgeryName) { success in
                    print("Deletion completion with success: \(success)")
                }
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func extractSurgeryName(from fullSurgeryString: String) -> String {
        let components = fullSurgeryString.components(separatedBy: "\n")
        if let nameComponent = components.first(where: { $0.starts(with: "اسم العملية:") }) {
            let nameParts = nameComponent.components(separatedBy: ": ")
            if nameParts.count > 1 {
                return nameParts[1]
            }
        }
        return ""
    }
    
    // Method to delete a medication from CloudKit
    func deleteSurgeriesFromCloud(surgery: String , completion: @escaping (Bool) -> Void) {
        guard let userRecordIDStringMed = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            completion(false)
            return
        }
        
        // Set up CloudKit container and database objects
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDStringMed)
        
        // Create a predicate to find surgery records related to the user
        let userPredicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let surgeryPredicate = NSPredicate(format: "SurgeryName == %@", surgery)
        
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, surgeryPredicate])
        
        let query = CKQuery(recordType: "PerviousSurgies", predicate: combinedPredicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil
            else {
                print("Error fetching surgery records: \(error!.localizedDescription)")
                return
            }
            
            for record in records {
                privateDatabase.delete(withRecordID: record.recordID) { recordID, error in
                    if let error = error {
                        print("Error deleting record: \(error.localizedDescription)")
                    } else {
                        print("surgery record deleted successfully")
                    }
                }
            }
        }
    }
}


struct DeleteChronicView: View {
    @Binding var chronics: [String]
    @State private var selectedChronics: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer(minLength: 50) // Adjusted Spacer to push the list down less
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("حذف مرض مزمن")
                        .font(.headline)
                        .padding([.top, .horizontal])
                    
                    List(chronics, id: \.self, selection: $selectedChronics) { chronic in
                        Text(chronic)
                    }
                    .frame(height: geometry.size.height * 0.4)
                    
                    HStack {
                        Button("حذف") {
                            deleteSelectedChronicDiseases()
                        }
                        .disabled(selectedChronics.isEmpty)
                        .foregroundColor(selectedChronics.isEmpty ? .gray : .blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        Button("إلغاء") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.bottom)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
        }
        .environment(\.layoutDirection, .rightToLeft) // Sets the layout direction to RTL
        .edgesIgnoringSafeArea(.all)
    }
    
    func deleteSelectedChronicDiseases() {
        for fullChronicString in selectedChronics {
            if let index = chronics.firstIndex(of: fullChronicString) {
                chronics.remove(at: index)
                let chronicName = extractChronicName(from: fullChronicString)
                deleteChronicFromCloud(chronic: chronicName) { success in
                    print("Deletion completion with success: \(success)")
                }
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    func extractChronicName(from fullChronicString: String) -> String {
        let components = fullChronicString.components(separatedBy: "\n")
        if let nameComponent = components.first(where: { $0.starts(with: "اسم المرض:") }) {
            let nameParts = nameComponent.components(separatedBy: ": ")
            if nameParts.count > 1 {
                return nameParts[1]
            }
        }
        return ""
    }
    
    // Method to delete a chronic from CloudKit
    func deleteChronicFromCloud(chronic: String , completion: @escaping (Bool) -> Void) {
        guard let userRecordIDStringMed = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            completion(false)
            return
        }
        
        // Set up CloudKit container and database objects
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDStringMed)
        
        // Create a predicate to find surgery records related to the user
        let userPredicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
        let medicationPredicate = NSPredicate(format: "DiseseName == %@", chronic)
        
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [userPredicate, medicationPredicate])
        
        let query = CKQuery(recordType: "ChroincDiseses", predicate: combinedPredicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil
            else {
                print("Error fetching Chroinc Diseses records: \(error!.localizedDescription)")
                return
            }
            
            for record in records {
                privateDatabase.delete(withRecordID: record.recordID) { recordID, error in
                    if let error = error {
                        print("Error deleting record: \(error.localizedDescription)")
                    } else {
                        print("Chroinc Diseses record deleted successfully")
                    }
                }
            }
        }
    }
    
}


struct NewViewHealthInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        NewmedicalHistory()
    }
} // End of NewViewHealthInfoPage_Previews
