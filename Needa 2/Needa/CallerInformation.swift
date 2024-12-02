

import SwiftUI
import CloudKit
import UniformTypeIdentifiers


struct CallerInformation: View {
    
    @State private var showingHomePage = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showHCPUploadView = false  // State to control the presentation of HCPUploadView
    
    @State private var bloodType: String = "لا توجد بيانات"
    @State private var height: String = "لا توجد بيانات"
    @State private var weight: String = "لا توجد بيانات"
    @State private var allergies: String = "لا توجد بيانات"
    @State private var medicalNotes: String = "لا توجد بيانات"
    @State private var chronincs: [String] = ["لا توجد بيانات"]
    @State private var medications: [String] = ["لا توجد بيانات"]
    @State private var surgeries: [String] = ["لا توجد بيانات"]
    @State private var personal: [String] = ["لا توجد بيانات"]
    @EnvironmentObject var viewModel: SharedViewModel
    
    @State private var reportText: String = ""
    @State private var selectedFileURL: URL? // URL of the selected file
    @State private var showFilePicker: Bool = false
    @State private var uploadStatus: String?
    @State private var error: String? // Declare the error state variable
    
    
    
    var body: some View {
        ScrollView {
            HStack {
                
                
                Spacer()
                
                Text("معلومات المريض")
                    .font(.title)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.horizontal, 30)
            }
            .fullScreenCover(isPresented: $showingHomePage) {
                               NeedaHomePage()
                           }
          //  .environment(\.layoutDirection, .rightToLeft)
            
            VStack(spacing: 20) {
                Text("التاريخ الطبي")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
            //        .frame(maxWidth: .infinity, alignment: .trailing)
                
                HealthCardInfo(
                    title: "المعلومات الشخصية والطبية:",
                    personal: self.personal,
                    bloodType: self.bloodType,
                    height: self.height,
                    weight: self.weight,
                    allergies: self.allergies,
                    medicalNotes: self.medicalNotes,
                    chronincs: self.chronincs,
                    medications: self.medications,
                    surgeries: self.surgeries,
                    graphName: "person.fill",
                    color: .green
                )
                .padding(.horizontal)
                .environment(\.layoutDirection, .rightToLeft)
 
                
                Spacer()
            }
            .padding(.bottom, 30)
            .onAppear {
                retriveHealthData()
            }
        }
    }
    
    func retriveHealthData() {
        fetchCallerRecord { userRecordID in
            guard let userRecordID = userRecordID
            else {
                print("User record ID not found 1")
                return
            }
            
            let container = CKContainer(identifier: "iCloud.NeedaDB")
            let privateDatabase = container.privateCloudDatabase
            
            // Fetch personal information
            privateDatabase.fetch(withRecordID: userRecordID) { record, error in
                DispatchQueue.main.async {
                    if let record = record, error == nil {
                        self.height = record["Hight"] as? String ?? "لا توجد بيانات"
                        self.weight = record["Wight"] as? String ?? "لا توجد بيانات"
                        self.personal = [
                            record["FullName"] as? String ?? "لا توجد بيانات",
                            "\(record["Age"] as? Int ?? 0)",
                            "\(record["Gender"] as? String ?? "لا توجد بيانات")",
                            "\(record["NationalID"] as? Int ?? 0)"
                        ]
                    } else {
                        print("Error fetching personal information record: \(error?.localizedDescription ?? "No error description")")
                    }
                }
            }
            
            print("انا هنا")

            let healthPredicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
            let healthInfoQuery = CKQuery(recordType: "HealthInformation", predicate: healthPredicate)
            
            privateDatabase.perform(healthInfoQuery, inZoneWith: nil) { records, error in
                DispatchQueue.main.async {
                  

                    if let records = records, error == nil {
                        

                        print("Records fetched successfully: \(records)")
                        for record in records {
                            

                            self.bloodType = record["BloodType"] as? String ?? "No data"
                            self.allergies = record["Allergies"] as? String ?? "No data"
                            self.medicalNotes = record["MedicalNotes"] as? String ?? "No data"
                        }
                    } else {
                        print("Error fetching health information records: \(error?.localizedDescription ?? "No error description")")
                    }
                }
            }
            
            // Fetch medications
            let medicationPredicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
            let medicationQuery = CKQuery(recordType: "Medications", predicate: medicationPredicate)
            
            privateDatabase.perform(medicationQuery, inZoneWith: nil) { records, error in
                DispatchQueue.main.async {
                    if let records = records, !records.isEmpty {
                        self.medications = records.compactMap {
                            if let name = $0["MedicineName"] as? String,
                               let dose = $0["DoseOfMedication"] as? String,
                               let doseUnit = $0["DoseUnit"] as? String {
                                return "\(name), \(dose) \(doseUnit)"
                            }
                            return nil
                        }
                    } else {
                        self.medications = ["لا توجد بيانات"]
                        print("No Medications found: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
            
            // Fetch chronic diseases
            let chronicPredicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
            let chronicQuery = CKQuery(recordType: "ChroincDiseses", predicate: chronicPredicate)
            
            privateDatabase.perform(chronicQuery, inZoneWith: nil) { records, error in
                DispatchQueue.main.async {
                    if let records = records, !records.isEmpty {
                        self.chronincs = records.compactMap { $0["DiseseName"] as? String }
                    } else {
                        self.chronincs = ["لا توجد بيانات"]
                        print("No Chronic Diseases found: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
            
            // Fetch previous surgeries
            let surgeryPredicate = NSPredicate(format: "UserID == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
            let surgeryQuery = CKQuery(recordType: "PerviousSurgies", predicate: surgeryPredicate)
            
            privateDatabase.perform(surgeryQuery, inZoneWith: nil) { records, error in
                DispatchQueue.main.async {
                    if let records = records, !records.isEmpty {
                        self.surgeries = records.compactMap { $0["SurgeryName"] as? String }
                    } else {
                        self.surgeries = ["لا توجد بيانات"]
                        print("No Previous Surgeries found: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
  
    private func fetchCallerRecord(completion: @escaping (CKRecord.ID?) -> Void) {
        guard let userRecordIDString = viewModel.needaRecords.first else {
               print("User record ID not found")
               return
           }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    if let userReference = record["UserID"] as? CKRecord.Reference {
                        completion(userReference.recordID) // Now correctly passing the referenced recordID
                    } else {
                        print("UserID is not a reference or not found")
                        completion(nil)
                    }
                } else {
                    print("Error fetching record: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }
    

    
} // end of the stract





struct HealthCardInfo: View {
    var title: String
    var personal: [String] // This array should contain the name, age, gender, and national ID.
    var bloodType: String
    var height: String
    var weight: String
    var allergies: String
    var medicalNotes: String
    var chronincs: [String]
    var medications: [String]
    var surgeries: [String]
    var graphName: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 30))
                .padding(.bottom, 5)
                .padding(.leading, 30)
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 5) {
                // Personal Information
                if personal.indices.contains(0) {
                    Text("الاسم: \(personal[0])")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
                
                if personal.indices.contains(1) {
                    Text("العمر: \(personal[1])")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
                
                if personal.indices.contains(2) {
                    Text("الجنس: \(personal[2])")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
                
                if personal.indices.contains(3) {
                    Text("الهوية الوطنية: \(personal[3])")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
                
                // Medical Information
                Text("فصيلة الدم: \(bloodType)")
                    .font(.subheadline)
                    .padding(.vertical, 2)
                
                Text("الطول: \(height)")
                    .font(.subheadline)
                    .padding(.vertical, 2)
                
                Text("الوزن: \(weight)")
                    .font(.subheadline)
                    .padding(.vertical, 2)
                
                Text("الحساسية: \(allergies)")
                    .font(.subheadline)
                    .padding(.vertical, 2)
                
                Text("الملاحظات الطبية: \(medicalNotes)")
                    .font(.subheadline)
                    .padding(.vertical, 2)
                
                // Displaying Medications, Chronic Diseases, Surgeries
                if !chronincs.isEmpty {
                    Text("الأمراض المزمنة: \(chronincs.joined(separator: ", "))")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
                
                if !medications.isEmpty {
                    Text("الأدوية: \(medications.joined(separator: ", "))")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
                
                if !surgeries.isEmpty {
                    Text("العمليات السابقة: \(surgeries.joined(separator: ", "))")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
        
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}




struct CallerDetails {
    var name: String
    var locationDescription: String
    var medicalCondition: String
    var personal: [String]
    var bloodType: String
    var height: String
    var weight: String
    var allergies: String
    var medicalNotes: String
    var chronics: [String]
    var medications: [String]
    var surgeries: [String]
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedURL = urls.first else { return }
            
            // Start accessing security-scoped resource
            if selectedURL.startAccessingSecurityScopedResource() {
                parent.fileURL = selectedURL
            } else {
                print("Failed to access security scoped resource")
            }
        }
    }
}

struct ReportView: View {
    @EnvironmentObject var viewModel: SharedViewModel
    
    @State private var reportText: String = ""
    @State private var selectedFileURL: URL? // URL of the selected file
    @State private var showFilePicker: Bool = false
    @State private var uploadStatus: String?
    @State private var showingHomePage = false

    
    @State private var inputSaveWord = ""
    @State private var showSaveWordPrompt = false

    @State private var errorCount = 0 // Track number of errors

    // List of phone numbers
    let phoneNumbers = ["966550060469", "966501245264"]
    // Triggered after a successful upload
    private func promptForSaveWord() {
        DispatchQueue.main.async {
            self.showSaveWordPrompt = true
        }
    }


    private func verifySaveWord() {
        // Assuming you have a method to fetch the saved word from CloudKit
        fetchSavedWord { (savedWord) in
            if savedWord == inputSaveWord {
                print("Verification successful")
                self.showSaveWordPrompt = false
                // Reset the first active state, location, and record
                if !self.viewModel.isActiveStates.isEmpty {
                    self.viewModel.isActiveStates.removeFirst()
                }
                if !self.viewModel.selectedLocations.isEmpty {
                    self.viewModel.selectedLocations.removeFirst()
                }
                if !self.viewModel.needaRecords.isEmpty {
                    self.viewModel.needaRecords.removeFirst()
                }
                self.showingHomePage = true
            } else {
                print("Verification failed")
                self.showSaveWordPrompt = false
                notSameSaveWord() // Call function when verification fails
            }
        }
    }
    func fetchSavedWord(completion: @escaping (String) -> Void) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Assuming you have saved the user's record ID in UserDefaults
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordIDhcp") else {
            print("User record ID not found")
            return
        }
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)


        privateDatabase.fetch(withRecordID: userRecordID) { (record, error) in
            DispatchQueue.main.async {
                if let record = record, error == nil, let saveWord = record["saveword"] as? String {
                    completion(saveWord)
                } else {
                    print("Failed to fetch save word: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    // Function to send WhatsApp messages to multiple recipients
        func sendWhatsAppMessages() {
            errorCount = 0 // Reset error count

            for phoneNumber in phoneNumbers {
                sendWhatsAppMessage(to: phoneNumber) { success in
                    DispatchQueue.main.async {
                        if success {
                            if errorCount == 0 { // If no errors yet, mark as successful
                                print("yeah sent")                            }
                        } else {
                            errorCount += 1
                            print("no, not sent")
                        }
                    }
                }
            }
        }

        // Function to send a WhatsApp message to a recipient
        func sendWhatsAppMessage(to phoneNumber: String, completion: @escaping (Bool) -> Void) {
            // API URL
            let urlString = "https://graph.facebook.com/v21.0/496457546884497/messages"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion(false)
                return
            }

            // Authorization Token
            let authorizationToken = "EAAN35PF8waMBO81YsZCTnuMsDR6U3RjZAe7ULhPZAPSHvqzl91d7NEMOOrbl4sbF5dyRd2o7D4rY7ndZBr6LZC18EsMj1UAjpSioTJlRpeRxhZAy3KPHG4oNQIO5zuZBUSmjkw7CuqZAEmdxr8DWLath8gPk5hqZCxI9qAWspnjEVQ8Rz1O3ZA0gZBPVjcZA93dOy5u7Yk6eHWXsrGuZByejqZBFWGnY1oaZBErkKyxUsIZD"

            // Request Body
            let requestBody: [String: Any] = [
                "messaging_product": "whatsapp",
                "to": phoneNumber,
                "type": "template",
                "template": [
                    "name": "needa_support_ar", // my template name
                    "language": [
                        "code": "ar"
                    ],
                    "components": [
                        [
                            "type": "header", // Header component
                            "parameters": [
                                [
                                    "type": "location",
                                    "location": [
                                        "latitude": "37.483307",    // hard coded
                                        "longitude": "122.148981",  // hard coded
                                        "name": "See my location",
                                        "address": "Need your help!"
                                    ]
                                ]
                            ]
                        ],
                        [
                            "type": "body", // Body component
                            "parameters": [
                                [
                                    "type": "text",
                                    "text": "أحمد"     // hard coded
                                ]
                            ]
                        ]
                    ]
                ]
            ]


            // Create URL Request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")

            // Set the HTTP Body
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            } catch {
                print("Error serializing JSON: \(error.localizedDescription)")
                completion(false)
                return
            }

            // Perform the Request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending message to \(phoneNumber): \(error.localizedDescription)")
                    completion(false)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("Message sent successfully to \(phoneNumber).")
                        completion(true)
                    } else {
                        print("Failed to send message to \(phoneNumber). Status code: \(httpResponse.statusCode)")
                        completion(false)
                    }
                }
            }

            task.resume()
        }
    func notSameSaveWord() {
        // Handle the scenario where the save word doesn't match
        print("Save word verification failed. Please try again.")
        sendWhatsAppMessages()
        if !self.viewModel.isActiveStates.isEmpty {
            self.viewModel.isActiveStates.removeFirst()
        }
        if !self.viewModel.selectedLocations.isEmpty {
            self.viewModel.selectedLocations.removeFirst()
        }
        if !self.viewModel.needaRecords.isEmpty {
            self.viewModel.needaRecords.removeFirst()
        }
              self.showingHomePage = true
    }
    

    var body: some View {
        VStack {
            Text("التقرير الطبي")
                .font(.title2)
                .bold()
                .foregroundColor(.red)
                .padding(.vertical, 10)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
                .fullScreenCover(isPresented: $showingHomePage) {
                                    NeedaHomePage()
                                }
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.button, lineWidth: 1)
                    .background(Color(UIColor.systemBackground))
                    .frame(height: 250)
                
                TextEditor(text: $reportText)
                    .padding(8)
                    .background(Color.clear)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .font(.body)
                    .environment(\.layoutDirection, .rightToLeft)
                
                if reportText.isEmpty {
                    Text("اكتب تقريرك الطبي هنا ...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }
                
                Image("needasmall")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 179, height: 179)
                    .opacity(0.3)
                    .position(x: UIScreen.main.bounds.width / 2 - 20, y: 125)
            }
            .padding(.horizontal)
            .environment(\.layoutDirection, .rightToLeft)
            
            HStack {
                Divider()
                    .frame(height: 1)
                    .frame(width: 130)
                    .background(Color.gray)
                Text("أو")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                Divider()
                    .frame(height: 1)
                    .frame(width: 130)
                    .background(Color.gray)
            }
            .padding(.horizontal)
            
            Button(action: {
                showFilePicker = true
            }) {
                Label("تحميل ملف", systemImage: "doc.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.button)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .sheet(isPresented: $showFilePicker) {
                DocumentPicker(fileURL: $selectedFileURL)
            }
            
            if let fileName = selectedFileURL?.lastPathComponent {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.accentColor)
                    Text("الملف الذي تم اختياره: \(fileName)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal)
                .environment(\.layoutDirection, .rightToLeft)
            }
            
            Button(action: {
                uploadReport()
            }) {
                Label("إرسال", systemImage: "icloud.and.arrow.up.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canUpload() ? Color.button : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .disabled(!canUpload())
            
            if let status = uploadStatus {
                Text(status)
                    .foregroundColor(.green)
                    .font(.footnote)
                    .padding(.top, 10)
            }
        }

        .sheet(isPresented: $showSaveWordPrompt) {
            ZStack {
                Color("backgroundColor") // Match the page background
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("أدخل كلمة الآمان للتحقق")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color("primaryText")) // Use your primary text color
                        .padding(.bottom, 10)
                    
                    TextField("كلمة الآمان", text: $inputSaveWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white) // Background color for the text field
                        .cornerRadius(10) // Rounded corners
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
                        .padding(.horizontal, 20) // Add horizontal padding

                    Button(action: {
                        verifySaveWord()
                    }) {
                        Text("تأكيد")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("button")) // Use your button color
                            .foregroundColor(.white) // Button text color
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20) // Button horizontal padding
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 30) // Center the VStack with some spacing
            }
        }

    }
    
    private func canUpload() -> Bool {
        return !reportText.isEmpty || selectedFileURL != nil
    }
    
    func uploadReport() {
        guard canUpload() else { return }
        
        // Get the existing record ID
        guard let userRecordIDString = viewModel.needaRecords.first else {
               print("User record ID not found")
               return
           }
        
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the existing record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    // Update the existing record with new data
                    
                    if !reportText.isEmpty {
                        record["HCPReportText"] = reportText as CKRecordValue
                    }
                    
                    record["NeedaStatus"] = "4" as CKRecordValue
                    
                    // Attach file if available
                    if let fileURL = selectedFileURL {
                        do {
                            guard fileURL.startAccessingSecurityScopedResource() else {
                                self.uploadStatus = "فشلت محاولة الوصول للملف"
                                return
                            }
                            
                            defer {
                                fileURL.stopAccessingSecurityScopedResource()
                            }
                            
                            let fileData = try Data(contentsOf: fileURL)
                            let fileName = UUID().uuidString + "-" + fileURL.lastPathComponent
                            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let localURL = documentDirectory.appendingPathComponent(fileName)
                            
                            try fileData.write(to: localURL)
                            let asset = CKAsset(fileURL: localURL)
                            record["HCPReportFile"] = asset
                            
                        } catch {
                            print("File handling error: \(error.localizedDescription)")
                            self.uploadStatus = "Failed to prepare file for upload."
                            return
                        }
                    }

                    // Save the updated record (after all modifications)
                    privateDatabase.save(record) { _, saveError in
                        DispatchQueue.main.async {
                            if let saveError = saveError {
                                print("Error saving updated record: \(saveError.localizedDescription)")
                                self.uploadStatus = "فشل تحديث البيانات: \(saveError.localizedDescription)"
                            } else {
                                self.promptForSaveWord()
                                self.sendNotificationForReport(recordID: recordID)

                                print("NeedaStatus updated to '3' and report uploaded successfully.")
                                self.uploadStatus = "تم تحميل التقرير بنجاح."
                          
                                
                                // Prompt for save word after successful upload
                            }
                        }
                    }
                    
                } else {
                    if let fetchError = error {
                        print("Error fetching the record: \(fetchError.localizedDescription)")
                        self.uploadStatus = "فشل في جلب السجل: \(fetchError.localizedDescription)"
                    }
                }
            }
        }
    }

    func sendNotificationForReport(recordID: CKRecord.ID) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase

        // Fetch the associated user record to get the token
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let record = record, let userReference = record["UserID"] as? CKRecord.Reference {
                let userRecordID = userReference.recordID

                // Fetch the token from the user record
                privateDatabase.fetch(withRecordID: userRecordID) { userRecord, userError in
                    if let userRecord = userRecord, let token = userRecord["token"] as? String {
                        // Use FirebaseManager.shared to send the notification
                        FirebaseManager.shared.sendNotification(
                            token: token,
                            needaRecordId: recordID.recordName,
                            title: "تم إرسال التقرير الطبي",
                            body: "تم رفع التقرير الطبي الخاص بك بنجاح."
                        )
                    } else {
                        print("Error fetching user record or token: \(userError?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else {
                print("Error fetching associated user record: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }


}


#Preview {
    CallerInformation()
}
