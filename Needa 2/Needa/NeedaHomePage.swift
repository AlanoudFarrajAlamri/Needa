
// 2 8 sprint3

import SwiftUI
import CoreLocation
import CloudKit
import FirebaseFunctions
import AVFoundation //for sound
import MapKit


struct NeedaHomePage: View {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // State variables to manage navigation to different views
    
    @State private var showingPatientMedicalHistory = false
    @State private var showingPatientHealthInfo = false
    @State private var showingReportPage = false
    
    @State private var showingPatientStatistics = false
    @State private var showAlert = false
    
    //to go to maps
    @EnvironmentObject var viewModel: SharedViewModel
    // State variables for navigation and role checking
    @State private var navigateToMaps = false
    @State private var isHealthPractitioner = false
    // State and environment variables for opening URLs and managing alerts
    @State private var goToAppStore = false
    @State private var showingAlert = false
    @Environment(\.openURL) var openURL
    // Delegates app lifecycle methods
    @ObservedObject var callerlocationManager = LocationManager.shared
    
    //-----------------
    @State private var emergencyAccepted = false
    @State private var showCallerInformation = false
    @State private var showConfirmingAlert : Bool = false
    @State private var showNoNeedAlert : Bool = false
    @State private var showConfirmingAlertTwo : Bool = false
    //-----------------
    // sound vars
    @State private var audioPlayer: AVAudioPlayer?
    @State private var countdown: Int = 5
    @State private var showCountdownAlert = false
    @State private var countdownTimer: Timer?
    @State private var isSoundPlaying: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showSpeakerImage = false
    @State private var tokens: [String] = []
    
    
    
    @State private var savedNeedaRecord: String? = nil
    @State private var noResponseTimer: Timer? = nil
    
    
    @StateObject var statusTracker = NeedaStatusTracker.shared
    @State private var isSectionVisible = true  // Track whether the section is visible
    
    
    @State private var showSuccessAlert = false // Toggle for success alert
    @State private var showErrorAlert = false // Toggle for error alert
    @State private var errorCount = 0 // Track number of errors
    
    
    @State private var showLogoutAlert = false
    
    
    // List of phone numbers
    let phoneNumbers = ["966533861118", "966593637662"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea(.all)
                
                VStack { // Start of VStack
                    if statusTracker.status > 0 {
                        VStack(spacing: 20) {  // Vertical stack for buttons and information, with spacing
                            // Toggle Button
                            
                            Button(action: {
                                withAnimation {
                                    isSectionVisible.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: isSectionVisible ? "chevron.down" : "chevron.up")
                                        .font(.title)
                                    Text(isSectionVisible ? "إخفاء الحالة" : "إظهار الحالة")
                                        .font(.body)
                                }
                                .foregroundColor(.blue)
                            }
                            .padding(.top)
                            
                            if isSectionVisible {  // Show this section only when isSectionVisible is true
                                VStack(alignment: .leading, spacing: 10) {  // Vertical stack for status information
                                    Text("تفاصيل الحالة")  // Title text
                                        .font(.title2)  // Set font size
                                        .bold()  // Make text bold
                                        .multilineTextAlignment(.trailing) // Align text to the right
                                        .frame(maxWidth: .infinity, alignment: .trailing) // Right align in the container
                                    if statusTracker.status > 0 {
                                        
                                        VStack(alignment: .leading, spacing: 8) {  // Vertical stack for status details
                                            
                                            ForEach(statusTracker.statusDetails.sorted(by: { $0.value < $1.value }), id: \.key) { key, value in
                                                HStack {  // Horizontal stack for each status detail
                                                    Text("\(value)")  // Display key
                                                        .bold()  // Make text bold
                                                    Spacer()  // Add flexible space
                                                    Text("\(key)")  // Display value
                                                }
                                                .padding(.vertical, 5)  // Add vertical padding to each status detail
                                                .frame(maxWidth: .infinity, alignment: .trailing) // Right align in the container
                                                
                                            }
                                        }
                                        .padding()  // Add padding around the status details
                                        .background(Color.white)  // Set background color to white
                                        .cornerRadius(15)  // Round the corners of the status detail box
                                        .shadow(radius: 5)  // Add shadow to the status detail box
                                    } else {
                                        Text("لا توجد تفاصيل للحالة حالياً.")  // Placeholder text for no status
                                            .foregroundColor(.gray)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                    }
                                }
                                .padding()  // Add padding around the status section
                                .frame(maxWidth: .infinity, alignment: .trailing) // Align all content to the right
                            }
                        }
                        
                        .padding()  // Add padding around the entire view
                        .background(Color.white)  // Set background color to white
                        .cornerRadius(15)  // Round the corners of the entire view
                        .shadow(radius: 5)  // Add shadow to the entire view
                        .padding(.horizontal)  // Add horizontal padding to the entire view
                    }
                    
                    
                    HStack{
                        if showSpeakerImage {
                            Button(action: toggleSound) {
                                Image(systemName: isSoundPlaying ? "speaker.wave.3.fill" : "speaker.slash.fill")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .frame(width: 40, height: 40)
                                    .padding()
                            }
                        }
                    }
                    .padding(.horizontal , 20)
                    
                                        .alert(isPresented: $showNoNeedAlert) {
                                            Alert(
                                                title: Text("تم قبول هذا النداء بالفعل"),
                                                message: Text("قام ممارس صحي آخر بقبول هذا النداء بالفعل، شكرًا لك."),
                                                dismissButton: .default(Text("حسناً")){ endNeeda()}
                    
                                            )
                                        }
                    // red rectnagle
                    // new code
                    HStack {
                        if isHealthPractitioner && !viewModel.selectedLocations.isEmpty  {
                            if emergencyAccepted {
                                HStack {
                                    if let firstLocation = viewModel.selectedLocations.first {
                                        NavigationLink(destination: MapsView(location: firstLocation)) {
                                            Text("موقع المريض")
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color("button"))
                                                .cornerRadius(10)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    
                                }
                                .padding()
                            } else {
                                Button("يوجد لديك طلب نداء") {
                                    // Call the function
                                    checkIfAcceptedHCPsExist { hasAcceptedHCPs in
                                        DispatchQueue.main.async {
                                            if hasAcceptedHCPs {
                                                showNoNeedAlert=true
                                            } else {
                                                showConfirmingAlert = true
                                            }
                                        }
                                    }
                                    
                                    
                                    
                                }
                                .frame(width: 340)
                                .padding()
                                .background(Color("button"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .alert("يوجد مريض يحتاج إلى مساعدة طبية", isPresented: $showConfirmingAlert) {
                                    Button("قبول الحالة") {
                                        guard let currentLocation = callerlocationManager.userLocation else {
                                            print("Current location not available")
                                            return
                                        }
                                        GlobalLocationManager.shared.acceptedLocation = currentLocation
                                        emergencyAccepted = true
                                        sendNeedaWithRecord(tokens: tokens, hcpResponse: "accepted")
                                        someoneIsHeadingToYou()
                                        acceptEmergency()
                                    }
                                    Button("رفض الحالة", role: .cancel) {
                                        if !viewModel.isActiveStates.isEmpty {
                                            viewModel.isActiveStates.removeFirst() // Remove the first active state from the array
                                        }
                                        if !viewModel.selectedLocations.isEmpty {
                                            viewModel.selectedLocations.removeFirst() // Remove the first location from the array
                                        }
                                        if !viewModel.needaRecords.isEmpty {
                                            viewModel.needaRecords.removeFirst() // Remove the first needa record from the array
                                        }
                                    }
                                }
                            }
                        } else if isHealthPractitioner {
                            Text("لا يوجد أي نداء في الوقت الحالي")
                                .frame(width: 340)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    
                    //----------------------------
                    Spacer()
                    //----------------------------
                    
                    // Call button with alert on tap
                    // Needa call
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("نداء") // 'Call' button text
                            .font(.system(size: 80)) // Font for the button , 60
                            .foregroundColor(.white)
                            .frame(width: 230, height: 230) // Set frame for button , width: 190, height: 190
                            .background(Color("button")) // Set button color
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 90) // ******** 50
                    } // End of Call button
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("تأكيد النداء"),
                            message: Text("هل أنت متأكد أنك تريد إرسال نداء الحاجة؟"),
                            primaryButton: .destructive(Text("نعم")) {
                                toggleSound()
                                sendEmergencyCall()
                                sendWhatsAppMessages() // NEW FUNCTION ADDED
                                
                                showSpeakerImage = true
                                FechCloseHP  { tokens in
                                    // Here 'tokens' is an array of tuples containing the record names and their corresponding tokens.
                                    if tokens.isEmpty {
                                        print("No nearby tokens received or error occurred.")
                                    } else {
                                        for token in tokens {
                                            print("Received token for \(token)")
                                        }
                                    }
                                }
                                
                            },
                            secondaryButton: .cancel(Text("إلغاء"))
                        )
                    }
//                    .alert(isPresented: $showSuccessAlert) {
//                        Alert(
//                            title: Text("تم الإرسال بنجاح"), // "Sent Successfully"
//                            message: Text("تم إرسال رسالة الطوارئ بنجاح إلى \(phoneNumbers.count - errorCount) من \(phoneNumbers.count)."), // Success message
//                            dismissButton: .default(Text("حسنًا")) // "OK"
//                        )
//                    }
//                    .alert(isPresented: $showErrorAlert) {
//                        Alert(
//                            title: Text("خطأ"), // "Error"
//                            message: Text("فشل إرسال الرسالة إلى \(errorCount) من \(phoneNumbers.count)."), // Error message
//                            dismissButton: .default(Text("حسنًا")) // "OK"
//                        )
//                    }

                    Spacer() // Spacer to push content to top and bottom
                    
                    //----------------------------
                    HStack(alignment: .center){ // Start of bottom HStack for icons and text
                        
                        VStack{ // Start of VStack for health information icon and text
                            Button(action: {
                                // Action to navigate to health information page
                                self.showingPatientHealthInfo = true
                            }) {
                                Image(systemName: "heart.text.square") // Icon for health information
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                            }
                            Text("معلوماتي الصحية") // Text label for icon
                                .foregroundColor(.white)
                                .font(.caption)
                        } // End of VStack for health information icon and text
                        .padding(.horizontal, 10)
                        .fullScreenCover(isPresented: $showingPatientHealthInfo) {
                            newViewHealthInfoPage() // Show health info page on button tap
                        }
                        
                        Spacer()
                        
                        VStack {
                            Button(action: {
                                self.showingPatientMedicalHistory = true
                            }) {
                                Image(systemName: "book.closed")
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                            }
                            Text("التاريخ الطبي")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .fullScreenCover(isPresented: $showingPatientMedicalHistory) {
                            NewmedicalHistory() // Show medical history page on button tap
                        }
                        
                        
                        Spacer()
                        
                        
                        VStack { // Start of VStack for health information icon and text
                            Button(action: {
                                self.showingReportPage = true
                            }) {
                                Image(systemName: "chart.bar.doc.horizontal") // Icon for health information
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                            }
                            Text("إحصائيات نداء") // Text label for icon
                                .foregroundColor(.white)
                                .font(.caption)
                        } // End of VStack for health information icon and text
                        .padding(.horizontal, 10)
                        .fullScreenCover(isPresented: $showingReportPage) {
                            NeedaReport()
                        }
                        
                        Spacer()
                        VStack {
                            Button(action: {
                                performLogout()
                                
                                //showLogoutAlert = true
                            }) {
//                                VStack {
//                                    Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(.white).imageScale(.large)
//                                    Text("تسجيل الخروج").foregroundColor(.white).font(.caption)
//                                }
                            }
                            
                        }
                        .padding(.horizontal, 10)
                        
                    } // End of bottom HStack
                    .frame(maxWidth: 330)
                    .padding()
                    .background(Color("button"))
                    .cornerRadius(20)
                    
                    
                    VStack {
                        Button(action: {
                            showLogoutAlert = true // Trigger the logout alert
                        }) {
                            VStack {
//                                Image(systemName: "rectangle.portrait.and.arrow.right")
//                                    .foregroundColor(Color("button"))
//                                    .imageScale(.large)
                                Text("تسجيل الخروج")
                                    .foregroundColor(Color("button"))
                                    .font(.title2)
                                    .padding(.horizontal, 10)
                                    
                            }
                        }
                    }
                    .alert("تأكيد تسجيل الخروج", isPresented: $showLogoutAlert) {
                        Button("نعم", role: .destructive) {
                            performLogout() // Perform the logout action
                        }
                        Button("إلغاء", role: .cancel) { }
                    } message: {
                        Text("هل أنت متأكد أنك تريد تسجيل الخروج؟")
                    }
                    
                    //----------------------------
                    
                    // Alert for errors or notifications
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("عذرًا"), message: Text(alertMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                    }
                }// End of VStack
                .onChange(of: statusTracker.status) { newStatus in
                    print("Status updated to: \(newStatus)") // Debug log for status changes
                }
                .onAppear {
                    AppDelegate.shared.updateTokenIfNeeded()
                    configureAudioSession()
                    setupAudioPlayer()
                    requestNotificationPermission()
                    updateUserLocationIfNeeded()
                    checkIfHealthPractitioner { isPractitioner in
                        self.isHealthPractitioner = isPractitioner
                    }
                    
                    // Listen for the notification from the Watch
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("SendNeedaFromWatch"), object: nil, queue: .main) { _ in
                        sendEmergencyCall()
                    }
                }
                .onDisappear {
                    // Remove observer when view disappears
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name("SendNeedaFromWatch"), object: nil)
                }
            }
        }.navigationBarBackButtonHidden(true) // for hiding the un-wanted back button..
        
    } // END OF THE BODY
    func someoneIsHeadingToYou() {
        guard let userRecordIDString = viewModel.needaRecords.first else {
            print("User record ID not found")
            return
        }
        print("userRecordIDString: \(userRecordIDString)")
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the record
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    if let callerRecordReference = record["UserID"] as? CKRecord.Reference {
                        let callerRecordId = callerRecordReference.recordID
                        // Continue with next query using the callerRecordId
                        self.fetchTokenForCaller(callerRecordId: callerRecordId, database: privateDatabase)
                    } else {
                        print("Caller ID not found or not a reference")
                    }
                } else {
                    print("No caller: \(error?.localizedDescription ?? "Unknown error")")
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
                            showSuccessAlert = true
                        }
                    } else {
                        errorCount += 1
                        showErrorAlert = true
                    }
                }
            }
        }
    }
    
    // Function to send a WhatsApp message to a single recipient
    func sendWhatsAppMessage(to phoneNumber: String, completion: @escaping (Bool) -> Void) {
        // API URL
        let urlString = "https://graph.facebook.com/v21.0/496457546884497/messages"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        
        // Retrieve User Location
          guard let userLocation = self.callerlocationManager.userLocation else {
              print("User location not found.")
              completion(false)
              return
          }
          
          // Extract latitude and longitude
          let latitude = userLocation.coordinate.latitude
          let longitude = userLocation.coordinate.longitude
        
        
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
    func fetchTokenForCaller(callerRecordId: CKRecord.ID, database: CKDatabase) {
        guard let userRecordIDString = viewModel.needaRecords.first else {
            print("User record ID not found")
            return
        }
        let predicate = NSPredicate(format: "recordID == %@", callerRecordId)
        let query = CKQuery(recordType: "Individual", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let records = records, !records.isEmpty, let record = records.first {
                    let token = record["token"] as? String ?? "لا توجد بيانات"
                    if !token.isEmpty {
                        print("Token: \(token)")
                        sendNotification(token: token, needaRecordId: userRecordIDString, title: "هناك ممارس صحي متوجه اليك", body: "تم قبول طلبك والممارس الصحي متوجه اليك")
                    } else {
                        print("Token not found")
                    }
                } else {
                    print("No records found for individual: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    
    func acceptEmergency() {
        
        guard let userRecordIDString = viewModel.needaRecords.first else {
            print("User record ID not found")
            return
        }
        
        
        guard let currentHCPRecordName = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("HCP user record ID not found in UserDefaults.")
            return
        }
        
        print("Accepting emergency for needa record: \(userRecordIDString) by HCP: \(currentHCPRecordName)")
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the existing record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    // Update the record's field
                    print("\(userRecordIDString)")
                    record["NeedaStatus"] = "1" as CKRecordValue
                    record["acceptanceTime"] = Date() as CKRecordValue
                    
                    
                    // Append the current HCP's record name to the acceptedHCP array
                    var acceptedHCPs = record["acceptedHCP"] as? [String] ?? []
                    if !acceptedHCPs.contains(currentHCPRecordName) {
                        acceptedHCPs.append(currentHCPRecordName)
                    }
                    record["acceptedHCP"] = acceptedHCPs as CKRecordValue
                    
                    // Save the updated record
                    privateDatabase.save(record) { _, error in
                        if let error = error {
                            print("CloudKit Save Error: \(error.localizedDescription)")
                        } else {
                            print("Record updated successfully with HCPResponse accepted.")
                            savedNeedaRecord = userRecordIDString
                            print("i am here3")
                            
                            startNoAnswerTimer()
                            
                        }
                    }
                } else {
                    print("Error fetching the record: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    
    func startNoAnswerTimer() {
        print("i am here1")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 900) {
            self.checkNoResponse()
        }
    }
    
    
    
    func checkNoResponse() {
        // Check if viewModel.isActive is true and needarecord is the same as saved
        print("i am here")
        if let activeIndex = viewModel.isActiveStates.firstIndex(of: true),
           activeIndex < viewModel.needaRecords.count,
           let savedRecord = savedNeedaRecord,
           savedRecord == viewModel.needaRecords[activeIndex] {
            noAnswerFromPractitioner()
        }
        
    }
    
    
    func noAnswerFromPractitioner() {
        // Logic for no response from practitioner
        print("No response from practitioner within 15 minutes.")
        sendWhatsAppMessages()
        noResponseTimer?.invalidate()
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func triggerSound() {
        configureAudioSession() // Call this before playing the sound
        
        if let soundURL = Bundle.main.url(forResource: "emergencysound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Unable to play sound: \(error)")
            }
        }
    }
    
    
    func setupAudioPlayer() {
        if let soundURL = Bundle.main.url(forResource: "emergencysound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.numberOfLoops = -1 // Loop
            } catch {
                print("Unable to set up sound: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found")
        }
    }
    
    func toggleSound() {
        if isSoundPlaying {
            audioPlayer?.stop()
            isSoundPlaying = false
        } else {
            audioPlayer?.play()
            isSoundPlaying = true
        }
    }
    
    func sendEmergencyCall() {
        FechCloseHP { fetchedTokens in
            if fetchedTokens.isEmpty {
                print("No nearby tokens received or error occurred.")
            } else {
                self.tokens = fetchedTokens
                sendNeedaWithRecord(tokens: tokens)
            }
        }
    }
    
    func FechCloseHP(completion: @escaping ([String]) -> Void) {
        var closeLocations: [String: CLLocation] = [:]
        var tokens: [String] = []
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Retrieve the stored user record ID
        if let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") {
            let userRecordID = CKRecord.ID(recordName: userRecordIDString)
            
            // Fetch and update the existing record
            privateDatabase.fetch(withRecordID: userRecordID) { record, error in
                if let error = error {
                    print("Error fetching user record: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let userLocation = self.callerlocationManager.userLocation else {
                    print("User location not found.")
                    completion([])
                    return
                }
                
                let predicate = NSPredicate(value: true)
                let query = CKQuery(recordType: "HCP", predicate: predicate)
                
                privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
                    if let error = error {
                        print("CloudKit Query Error: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    guard let records = records else {
                        print("No records found")
                        completion([])
                        return
                    }
                    
                    for record in records {
                        if let location = record["location"] as? CLLocation,
                           let reference = record["UserID"] as? CKRecord.Reference {
                            let recordName = reference.recordID.recordName
                            if recordName != userRecordIDString && userLocation.distance(from: location) <= 5000 {
                                closeLocations[recordName] = location
                            }
                        }
                    }
                    
                    if closeLocations.isEmpty {
                        print("No nearby locations found.")
                        DispatchQueue.main.async {
                            self.alertMessage = "لا يوجد ممارسين صحيين بالقرب منك"
                            self.showingAlert = true
                        }
                        completion([])
                        return
                    }
                    
                    // Fetch tokens for each close location
                    let group = DispatchGroup()
                    for (recordName, _) in closeLocations {
                        group.enter()
                        let recordID = CKRecord.ID(recordName: recordName)
                        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
                            if let error = error {
                                print("Failed to fetch token for \(recordName): \(error.localizedDescription)")
                            } else if let record = record, let token = record["token"] as? String {
                                tokens.append(token)
                            } else {
                                print("Token not found for \(recordName)")
                            }
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        print("Tokens fetched for nearby locations: \(tokens)")
                        completion(tokens)
                    }
                }
            }
        } else {
            print("User record ID not found in UserDefaults.")
            completion([])
        }
        
    }
    
    func sendNeedaWithRecord(tokens:Array<Any>, hcpResponse: String? = nil){
        var needaRecordName = ""
        var userLocation = self.callerlocationManager.userLocation
        
        
        // Check if the userRecordID is available
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Convert the userRecordIDString into a CKRecord.ID
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        let needaRecord = CKRecord(recordType: "NeedaCall")
        
        // Set the surgery details
        needaRecord["UserLocation"] = userLocation
        
        // Create a CKRecord.Reference to link this needa record to the user's Individual record
        let reference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
        needaRecord["UserID"] = reference
        
        // Set the healthcare practitioner's response if provided
        if let response = hcpResponse {
            needaRecord["HCPResponse"] = response
        }
        
        // Save the needa record
        privateDatabase.save(needaRecord) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle any errors during save operation
                    print("CloudKit Save Error: \(error.localizedDescription)")
                    return
                } else {
                    needaRecordName = needaRecord.recordID.recordName
                    print ("needaRecordName: \(needaRecordName)")
                    print("save Needa done")
                    // Ensure tokens are valid strings
                    let validTokens = tokens.compactMap { $0 as? String }
                    if validTokens.isEmpty {
                        print("No valid tokens to send inside sendNeedaThroughServer function")
                        return
                    }
                    for token in validTokens{
                        sendNotification(token: token, needaRecordId: needaRecordName, title: "هناك نداء بانتظارك", body: "اقبل الطلب لتتمكن من استعراض معلومات النداء")}
                }
            }
        }
        
        
    }
    
    func sendNotification(token: String, needaRecordId: String, title: String, body: String) {
        // URL of the Firebase Cloud Function
        guard let url = URL(string: "https://us-central1-needa-efd17.cloudfunctions.net/sendNotificationV3") else {
            print("Invalid URL")
            return
        }
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare the JSON payload with the dynamic data
        let json: [String: Any] = [
            "token": token,
            "needaRecordId": needaRecordId,
            "title": title,
            "body": body
        ]
        
        // Convert JSON to Data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        // Perform the HTTP request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle error
            if let error = error {
                print("Error sending request: \(error)")
                return
            }
            
            // Handle response
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                // Optionally parse and handle response data here
                let responseData = String(data: data, encoding: .utf8)
                print("Response Data: \(responseData ?? "No Data")")
            }
        }
        
        task.resume() // Start the request
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                // Handle success - for example, you might want to call a function to register for remote notifications.
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                // Handle errors here
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateUserLocationIfNeeded() {
        // Retrieve the user record ID from UserDefaults
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found.")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the user record from CloudKit
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch user record: \(error.localizedDescription)")
                    return
                }
                
                guard let record = record, let userType = record["UserType"] as? String else {
                    print("Failed to retrieve UserType from user record.")
                    return
                }
                
                // Check if the user is a healthcare practitioner
                if userType == "healthcarePractitioner" {
                    self.updateLocationForHCP(userRecordID: userRecordID)
                } else {
                    print("User is not a healthcare practitioner.")
                }
            }
        }
    }
    
    private func checkIfHealthPractitioner(completion: @escaping (Bool) -> Void) {
        // Retrieve the user record ID from UserDefaults
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found.")
            completion(false)
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the user record from CloudKit
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch user record: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let record = record, let userType = record["UserType"] as? String else {
                    print("Failed to retrieve UserType from user record.")
                    completion(false)
                    return
                }
                
                // Check if the user is a healthcare practitioner
                if userType == "healthcarePractitioner" {
                    completion(true)
                } else {
                    print("User is not a healthcare practitioner.")
                    completion(false)
                }
            }
        }
    }
    
    private func updateLocationForHCP(userRecordID: CKRecord.ID) {
        // Ensure we have a valid user location to use
        guard let userLocation = self.callerlocationManager.userLocation else {
            print("User location not found.")
            return
        }
        
        // Call saveHCPRecord and proceed only when it completes
        saveHCPRecord { success in
            guard success else {
                print("Failed to save HCP record, stopping further execution.")
                return
            }
            
            // Retrieve the healthcare record ID from UserDefaults
            guard let healthcareRecordIDString = UserDefaults.standard.string(forKey: "userRecordIDhcp"), !healthcareRecordIDString.isEmpty else {
                print("Healthcare record ID not found or is empty in UserDefaults.")
                return
            }
            
            // Create the healthcare record ID object
            let healthcareRecordID = CKRecord.ID(recordName: healthcareRecordIDString)
            
            let container = CKContainer(identifier: "iCloud.NeedaDB")
            let privateDatabase = container.privateCloudDatabase
            
            // Fetch the existing healthcare practitioner record from CloudKit
            privateDatabase.fetch(withRecordID: healthcareRecordID) { record, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Failed to fetch healthcare record: \(error.localizedDescription)")
                        return
                    }
                    
                    // Use the fetched record or create a new one if it doesn't exist
                    let healthcareRecord: CKRecord
                    if let fetchedRecord = record {
                        healthcareRecord = fetchedRecord
                    } else {
                        print("No healthcare record found, creating a new one.")
                        healthcareRecord = CKRecord(recordType: "HCP", recordID: healthcareRecordID)
                    }
                    
                    // Update the healthcare record with the current location
                    healthcareRecord["location"] = userLocation
                    
                    // Save the updated healthcare record back to CloudKit
                    privateDatabase.save(healthcareRecord) { savedRecord, saveError in
                        if let saveError = saveError {
                            print("Failed to update location in CloudKit: \(saveError.localizedDescription)")
                        } else if savedRecord != nil {
                            print("Location updated successfully for healthcare practitioner.")
                        } else {
                            print("Unknown error occurred while saving healthcare practitioner location.")
                        }
                    }
                }
            }
        }
    }
    
    
    func saveHCPRecord(completion: @escaping (Bool) -> Void) {
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("No userRecordID found in UserDefaults")
            completion(false)
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format: "UserID == %@", reference)
        let query = CKQuery(recordType: "HCP", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let records = records, !records.isEmpty {
                    if let userRecordIDhcp = records.first {
                        let userRecordIDhcpString = userRecordIDhcp.recordID.recordName
                        UserDefaults.standard.set(userRecordIDhcpString, forKey: "userRecordIDhcp")
                        print("HealthInfoRecord ID saved in UserDefaults: \(userRecordIDhcpString)")
                        completion(true)
                    } else {
                        print("No valid record found.")
                        completion(false)
                    }
                } else {
                    print("No HealthInformation record found for the given USERID")
                    completion(false)
                }
            }
        }
    }
    
    private func performLogout() {
        
        print ("loggggggggg out")
        // 1. Clear all general user-related data from UserDefaults if they exist
        let userDefaultsKeys = [
            "userRecordID",
            "healthInfoRecord",
            "chroincRecord",
            "medicationRecord",
            "surgeryRecord"
        ]
        
        for key in userDefaultsKeys {
            if UserDefaults.standard.object(forKey: key) != nil {
                UserDefaults.standard.removeObject(forKey: key)
                print("Deleted value for key: \(key)")
            } else {
                print("No value found for key: \(key)")
            }
        }
        
        // 2. Handle the userRecordIDhcp key specifically for healthcare practitioners
        checkIfHealthPractitioner { isPractitioner in
            if isPractitioner {
                if UserDefaults.standard.object(forKey: "userRecordIDhcp") != nil {
                    UserDefaults.standard.removeObject(forKey: "userRecordIDhcp")
                    print("Deleted value for 'userRecordIDhcp'")
                } else {
                    print("No value found for 'userRecordIDhcp'")
                }
            } else {
                print("User is not a healthcare practitioner. Skipping 'userRecordIDhcp' cleanup.")
            }
            
            // 3. Redirect to the login page
            DispatchQueue.main.async {
                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: PractitionerLogIn())
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }
    
    
    
    func checkIfAcceptedHCPsExist(completion: @escaping (Bool) -> Void) {
        guard let userRecordIDString = viewModel.needaRecords.first else {
            print("User record ID not found")
            completion(false)
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the existing record
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    if let acceptedHCPs = record["acceptedHCP"] as? [String], !acceptedHCPs.isEmpty {
                        print("There are \(acceptedHCPs.count) HCP(s) in the acceptedHCP list.")
                        completion(true)
                    } else {
                        print("No HCPs found in the acceptedHCP list.")
                        completion(false)
                    }
                } else {
                    print("Error fetching the record: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }
    }
    
    func endNeeda(){
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
    }
    
} //end of the struct NeedaHomePage




#Preview {
    
    NeedaHomePage()
}


class GlobalLocationManager: ObservableObject {
    static let shared = GlobalLocationManager()
    @Published var acceptedLocation: CLLocation? = nil
    private init() {} // Ensures this class can't be instantiated outside
}
