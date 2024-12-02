
import SwiftUI
import CloudKit
import HealthKit
import CommonCrypto
import FirebaseAuth

struct PractitionerRegestrationPage: View {
    
    @FocusState private var isConfirmPasswordFieldFocused: Bool
    @FocusState private var isFocused: Bool
    
    @State private var showingcompleteYourHealthPage = false
    @State private var showingContentView = false
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var idNUM = ""
    @State private var age = ""
    @State private var gender: Gender = .notSet
    @State private var height = ""
    @State private var weight = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var saveWord = ""
    @State private var currentLocation = ""
    @State private var profileID = ""
    
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var ageError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""
    @State private var heightError = ""
    @State private var weightError = ""
    @State private var shouldNavigate = false
    @State private var genderError = ""
    
    @State private var bubbleText =  "يجب أن تحوي حرف كبير، حرف صغير، رقم، رمز، ٨ خانات على الأقل"
    @State private var bubbleText2 =  "يجب أن تحوي حرف كبير، حرف صغير، رقم، رمز، ٨ خانات على الأقل"
    
    @State private var isBubbleVisible = false
    @State private var isBubbleVisible2 = false
    
    @State private var userEmail = "def email"
    
    
    // Constant for uniform padding across all elements
    private let elementPadding: CGFloat = 20
    
    @ObservedObject var locationManager = LocationManager.shared
    
    
    var body: some View {
        NavigationStack{
            
            ZStack {
                
                
                Color("backgroundColor")
                    .ignoresSafeArea(.all)
                
                VStack {
                    HStack {
                        Button(action: {
                            // Dismiss the current view to navigate back
                            self.showingContentView = true
                        }) {
                            HStack {
                                Image(systemName: "chevron.backward") // The back arrow icon
                                //Text("رجوع") // The text "Back"
                            }
                            .padding()
                            .foregroundColor(Color("button")) // Change the color as needed
                        }
                        .fullScreenCover(isPresented: $showingContentView) {
                            ContentView()
                        }
                        Spacer() // Pushes the button to the left
                    }
                    // Make sure the rest of your content is pushed down
                    Spacer()
                }
                .padding(.leading)
                .zIndex(1)
                // end of VStack
                
                
                ScrollView {
                    VStack(spacing: 10) //20
                    {
                        
                        
                        Text("إنشاء حساب ممارس صحي")
                            .font(.title)
                            .bold()
                            .padding(.trailing, -20.0)
                            .foregroundColor(Color("button"))
                            .multilineTextAlignment(.leading)
                        // Grouped input fields with validation and UI handling
                        
                        Group {
                            HStack {
                                Text("الاسم الرباعي")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -255)
                            }  .edgesIgnoringSafeArea(.all)
                            
                            
                            
                            TextField("", text: $name)
                            
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .disabled(true)
                            
                            
                            
                            
                        }
                        .environment(\.layoutDirection, .rightToLeft) //end of group 1
                        
                        
                        Group {
                            HStack {
                                Text("الهوية الوطنية")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -248)
                            }
                            
                            TextField("", text: $idNUM)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .disabled(true)
                                .environment(\.layoutDirection, .rightToLeft)
                            
                            
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        Group {
                            HStack {
                                Text("رقم الرخصة المهنية")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -215) //.leading, -248
                            }
                            
                            TextField("", text: $profileID)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .disabled(true)
                                .environment(\.layoutDirection, .rightToLeft)
                            
                            
                            
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        Group {
                            
                            HStack {
                                Text("الجنس")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -295)
                            }
                            
                            Menu {
                                Picker("", selection: $gender) {
                                    ForEach(Gender.allCases) { gender in
                                        Text(gender.rawValue).tag(gender)
                                    }
                                }
                                .onChange(of: gender) { newValue in
                                    handleGenderChange(newValue.rawValue)
                                }
                            } label: {
                                HStack {
                                    Text(gender.rawValue)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                
                            }
                            if !genderError.isEmpty {
                                Text(genderError)
                                    .foregroundColor(.red)
                            }}
                        .accentColor(.white)
                        .environment(\.layoutDirection, .rightToLeft)
                        
                        Group {
                            HStack {
                                Text("العمر")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -305)
                            }
                            
                            TextField("", text: $age, onEditingChanged: { editing in
                                if !editing {
                                    ageError = validateAge(age) ? "" : "أدخل عمرًا بين ١٨ و١٠٠ رجاءً"
                                }
                            })
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .environment(\.layoutDirection, .rightToLeft)
                            
                            if !ageError.isEmpty {
                                Text(ageError)
                                    .foregroundColor(.red)
                            }
                            
                        }.environment(\.layoutDirection, .rightToLeft) //end of group3
                        
                        
                        Group {
                            HStack {
                                Text("الطول")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -300)
                            }
                            
                            TextField("", text: $height, onEditingChanged: { editing in
                                if !editing {
                                    if !validateHeight(height) {
                                        heightError = " أدخل طولًا متاحًا"
                                    } else {
                                        heightError = ""
                                    }
                                }
                            })
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            
                            if !heightError.isEmpty {
                                Text(heightError)
                                    .foregroundColor(.red)
                            }
                            
                        }.environment(\.layoutDirection, .rightToLeft) //end of group 4
                        
                        
                        Group {
                            HStack {
                                Text("الوزن")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -306)
                            }
                            
                            TextField("", text: $weight, onEditingChanged: { editing in
                                if !editing {
                                    if !validateWeight(weight) {
                                        weightError = "أدخل وزنًا متاحًا"
                                    } else {
                                        weightError = ""
                                    }
                                }
                            })
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            
                            if !weightError.isEmpty {
                                Text(weightError)
                                    .foregroundColor(.red)
                            }
                            
                        }.environment(\.layoutDirection, .rightToLeft) //end of group 5
                        
                        
                        
                        Group {
                            HStack {
                                Text("البريد الإلكتروني")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -180)
                            }
                            
                            TextField("", text: $email)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .disabled(true)
                                .environment(\.layoutDirection, .rightToLeft)
                            
                            
                            
                            
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        
                        Group {
                            HStack{
                                Text("كلمة الآمان")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .environment(\.layoutDirection, .rightToLeft)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -245)
                                
                                InfoButtonView(isBubbleVisible: $isBubbleVisible2, bubbleText: $bubbleText2)
                                    .padding(.leading, -10)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        
                                        if isBubbleVisible2 {
                                            isBubbleVisible2 = false
                                        }
                                    }
                            }
                            
                            SecureField("", text: $saveWord)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .focused($isFocused)
                                .onChange(of: isFocused) { focused in
                                    if !focused {
                                        passwordError = isPasswordStrong(saveWord) ? "" : "كلمة السر لا توافق معايير كلمة السر القوية"
                                    }
                                }
                            
                            if !passwordError.isEmpty {
                                Text(passwordError)
                                    .foregroundColor(.red)
                            }
                        }.environment(\.layoutDirection, .rightToLeft)
                        
                        
                        Group {
                            HStack{
                                Text("كلمة المرور")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .environment(\.layoutDirection, .rightToLeft)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -245)
                                
                                InfoButtonView(isBubbleVisible: $isBubbleVisible, bubbleText: $bubbleText)
                                    .padding(.leading, -10)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        
                                        if isBubbleVisible {
                                            isBubbleVisible = false
                                        }
                                    }
                            }
                            
                            SecureField("", text: $password)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .focused($isFocused)
                                .onChange(of: isFocused) { focused in
                                    if !focused {
                                        passwordError = isPasswordStrong(password) ? "" : "كلمة السر لا توافق معايير كلمة السر القوية"
                                    }
                                }
                            
                            if !passwordError.isEmpty {
                                Text(passwordError)
                                    .foregroundColor(.red)
                            }
                        }.environment(\.layoutDirection, .rightToLeft)  //end of group 6
                        
                        Group {
                            HStack{
                                Text("تأكيد كلمة المرور")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -225)
                            }
                            
                            SecureField("", text: $confirmPassword)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .focused($isConfirmPasswordFieldFocused)
                                .onChange(of: isConfirmPasswordFieldFocused) { focused in
                                    if !focused{
                                        confirmPasswordError = (password == confirmPassword) ? "" : "كلمتا السر غير متطابقتان"}
                                }
                            
                            if !confirmPasswordError.isEmpty {
                                Text(confirmPasswordError)
                                    .foregroundColor(.red)
                            }
                        }.environment(\.layoutDirection, .rightToLeft) //end of group 8
                        
                        
                        // Define the navigation destination
                            .navigationDestination(isPresented: $shouldNavigate) {
                                completeYourHealthPage().navigationBarBackButtonHidden(true)
                            }
                        
                        Button(action: {
                            print("Button tapped")
                            //   self.saveIndivisulInfo()
                            self.hcpInfo()
                            self.validateFields()
                            self.shouldNavigate = true
                        })
                        {
                            Text("التالي")
                                .frame(width:300, height:50)
                                .foregroundColor(Color.white)
                                .background(Color.button)
                                .cornerRadius(8)
                                .padding()
                        }
                        
                        
                        
                        
                    } // end of VStack in side ScrollView
                    .padding(elementPadding)
                } // end of ScrollView
                
            }.navigationBarHidden(true) // end of container ZStack
                .onAppear {
                    
                    
                    
                    fetchHealthData()
                    retrieveHcpData()
                    locationManager.requestLocation()
                }
            
            
            
            
        } // end of NavigationStack
        
        
        
        
    } // end of the body
    
    
    func fetchHealthData() {
        HealthDataManager.shared.requestHealthKitPermissions { [self] success, _ in
            if success {
                // Fetch Gender
                HealthDataManager.shared.fetchBiologicalSex { result, _ in
                    if let biologicalSex = try? result?.biologicalSex {
                        DispatchQueue.main.async {
                            self.gender = Gender.from(hkBiologicalSex: biologicalSex)
                        }
                    }
                }
                
                // Fetch Age
                HealthDataManager.shared.fetchDateOfBirth { result, _ in
                    if let dobComponents = try? result, let birthDate = Calendar.current.date(from: dobComponents), let ageYears = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year {
                        DispatchQueue.main.async {
                            self.age = "\(ageYears)"
                        }
                    }
                }
                
                HealthDataManager.shared.fetchHeight { result, error in
                    // Assuming fetchHeight correctly returns an array of HKQuantitySample? and an Error?
                    if let error = error {
                        print("Error fetching height: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let sample = result?.first else {
                        print("No height samples available.")
                        return
                    }
                    
                    let heightValue = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
                    DispatchQueue.main.async {
                        self.height = String(format: "%.0f", heightValue) // Convert heightValue to a string without decimal points
                    }
                }
                
                // Fetch Weight
                HealthDataManager.shared.fetchWeight { result, _ in
                    if let sample = result?.first {
                        let weightValue = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                        DispatchQueue.main.async {
                            self.weight = String(format: "%.0f", weightValue) // Format and update the UI
                        }
                    }
                }
                
            } else {
                // Handle the case where permissions were not granted
                print("HealthKit permissions were not granted.")
            }
        }
    }
    
    //---------------clould kit functions
    
    //    private func fetchAuthenticatedUserEmail() {
    //        if let currentUser = Auth.auth().currentUser {
    //            userEmail = currentUser.email // Assigning the email to userEmail state
    //            print("Fetching data for email: \(userEmail ?? "unknown")")
    //           // retrieveHcpData()
    //        }
    //    }
    
    
    private func updateUI(with record: CKRecord) {
        DispatchQueue.main.async {
            self.name = record["FullName"] as? String ?? ""
            self.email = record["Email"] as? String ?? ""
            let tempId = record["NationalID"] as? Int ?? 0
            self.idNUM = "\(tempId)"
            // Retrieve the userRecordID
            let userRecordIDString = record.recordID.recordName
            // Fetch the associated HCP record
            fetchHCPRecord(for: userRecordIDString)
        }
    }
    
    
    
    
    
    private func fetchHCPRecord(for userRecordID: String) {
        print("hi here \(userRecordID)")
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        let userRecordID = CKRecord.ID(recordName: userRecordID)
        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        
        let predicate = NSPredicate(format: "UserID == %@", reference)
        let query = CKQuery(recordType: "HCP", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit Fetch Error: \(error.localizedDescription)")
                } else if let record = records?.first {
                    // Retrieve and handle the saveword
                    if let ProfileID = record["ProfileID"] as? Int {
                        // Update any UI element with the retrieved saveword
                        print("Retrieved profileID: \(ProfileID)")
                        UserDefaults.standard.set(record.recordID.recordName, forKey: "userRecordIDhcp")
                        self.profileID = "\(ProfileID)"
                        
                    } else {
                        print("profileID not found in the HCP record.")
                    }
                } else {
                    print("No HCP record found for the user.")
                }
            }
        }
    }
    
    
    
    func saveIndividualData() {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        guard let idValue = UserDefaults.standard.object(forKey: "idNum") as? Int, idValue != 0 else {
            print("No id found in UserDefaults or not set to a valid non-zero value.")
            return
        }
        print("Retrieved id from UserDefaults: \(idValue)")
        print("Yes, number is not empty")
        
        let predicate = NSPredicate(format: "NationalID == %d", idValue)
        let query = CKQuery(recordType: "Individual", predicate: predicate)
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit Fetch Error: \(error.localizedDescription)")
                    return
                }
                
                guard let record = records?.first else {
                    print("No record found for this National ID")
                    return
                }
                
                guard let ageInt = Int(age), let idInt = Int(idNUM) else {
                    print("Validation failed. Age or National ID is not in the correct format.")
                    return
                }
                
                record["Age"] = ageInt
                record["Gender"] = gender.rawValue
                record["Hight"] = height
                record["Wight"] = weight
                record["Password"] = hashPassword(password)
                print("Record to be saved: \(record)")
                
                // Update the fetched record
                AppDelegate.shared.updateTokenIfNeeded()
                
                privateDatabase.save(record) { savedRecord, saveError in
                    DispatchQueue.main.async {
                        if let saveError = saveError {
                            print("Error saving record: \(saveError.localizedDescription)")
                        } else {
                            UserDefaults.standard.set(savedRecord?.recordID.recordName, forKey: "userRecordID")
                            print("Record and UserDefaults updated successfully.")
                        }
                    }
                }
            }
        }
    }
    
    
    
    func retrieveHcpData() {
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        var idValue = 0
        
        if let savedID = UserDefaults.standard.object(forKey: "idNum") as? Int {
            idValue = savedID
            print("Retrieved id from UserDefaults: \(savedID)")
        } else {
            print("No id found in UserDefaults or unable to cast to Int.")
        }
        
        
        if (idValue == 0) {
            print ("no id")
            
        }
        else {
            print ("yes number not empty")
            
            let predicate = NSPredicate(format: "NationalID == %ld", idValue)
            let query = CKQuery(recordType: "Individual", predicate: predicate)
            privateDatabase.perform(query, inZoneWith: nil) { records, error in
                DispatchQueue.main.async {
                    if let records = records, !records.isEmpty, let record = records.first {
                        
                        self.updateUI(with: record)
                        
                        
                    } else {
                        print( "No record found for this National ID")
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    private func hcpInfo() {
        // Guard to ensure user location is available
        guard let userLocation = locationManager.userLocation else {
            print("User location not found.")
            return
        }
        
        // Guard to ensure user record ID string is available
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found.")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        
        // Create a query to fetch the record by reference
        let recordType = "HCP"
        let predicate = NSPredicate(format: "UserID = %@", reference)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        // Perform the query
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit Fetch Error: \(error.localizedDescription)")
                } else if let records = records, !records.isEmpty {
                    // Handle the fetched record
                    let fetchedRecord = records.first!
                    print("Record fetched: \(fetchedRecord)")
                    
                    
                    fetchedRecord["saveword"] = saveWord
                    fetchedRecord["location"] = userLocation
                    
                    // Save the updated record back to CloudKit
                    privateDatabase.save(fetchedRecord) { savedRecord, saveError in
                        DispatchQueue.main.async {
                            if let saveError = saveError {
                                print("Error saving record: \(saveError.localizedDescription)")
                            } else {
                                UserDefaults.standard.set(savedRecord?.recordID.recordName, forKey: "userRecordIDhcp")
                                print("Record and UserDefaults updated successfully.")
                            }
                        }
                    }
                } else {
                    print("No record found.")
                }
            }
        }
    }
    
    // end of the hcpInfo
    
    // Method to send the user's name to the Apple Watch
    private func sendUserNameToWatch(name: String) {
        //        Use watchConnector class for data sending and reciving >>> Ammar
        
        
//        if WCSession.default.isReachable {
//            let message = ["userName": name]
//            WCSession.default.sendMessage(message, replyHandler: nil) { error in
//                DispatchQueue.main.async {
//                    // Handle any errors here, perhaps by showing an error message to the user
//                    self.showErrorMessage("Could not send user name to the Apple Watch: \(error.localizedDescription)")
//                }
//            }
//        }
    }
    
    private func hashPassword(_ password: String) -> String {
        // Convert the password string to data using UTF-8 encoding
        guard let data = password.data(using: .utf8) else { return "defaultHashValue" }
        
        // Initialize an array to hold the hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        // Calculate the SHA-256 hash of the password data
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        // Convert the hash array to Data, then encode it in Base64
        let hashedPassword = Data(hash).base64EncodedString()
        
        // Return the hashed password
        return hashedPassword
    }
    
    
    // Function to show an error message to the user
    private func showErrorMessage(_ message: String) {
        print("error func showErrorMessage 405line registraion page")
    }
    
    //--------------- end of clould kit functions
    
    
    //--------------- vaildation function
    
    
    
    func validateFields() {
        ageError = ""
        passwordError = ""
        confirmPasswordError = ""
        heightError = ""
        weightError = ""
        genderError = ""
        
        isLoading = true
        
        
        
        // Validate age
        ageError = age.isEmpty || !validateAge(age) ? "أدخل عمرًا بين ١٨ و١٠٠ رجاءً" : ""
        
        
        // Validate password
        passwordError = password.isEmpty ? " أدخل كلمة السر" : ""
        
        // Validate passwordStrength
        passwordError = isPasswordStrong(password) ? "" : " كلمة السر لا توافق معايير كلمة السر القوية"
        
        // Validate confirmPassword
        confirmPasswordError = confirmPassword.isEmpty ? "أدخل كلمة السر مرة أخرى" : ""
        
        // Validate height
        heightError = height.isEmpty || !validateHeight(height) ? " أدخل طولًا متاحًا" : ""
        
        // Validate weight
        weightError = weight.isEmpty || !validateWeight(weight) ? "أدخل وزنًا متاحًا" : ""
        
        handleGenderChange(gender.rawValue)
        
        //  Set isLoading to false if there are errors
        if  !ageError.isEmpty || !passwordError.isEmpty || !confirmPasswordError.isEmpty || !heightError.isEmpty || !weightError.isEmpty || !genderError.isEmpty || !confirmPasswordError.isEmpty{
            isLoading = false
        }
        
        else {saveIndividualData()}
        
        
    }
    
    
    func isPasswordStrong(_ password: String) -> Bool {
        // Define the checks
        let lengthCheckPredicate = NSPredicate(format: "SELF MATCHES %@", ".{8,}") // At least 8 characters
        let lowercaseCheckPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
        let uppercaseCheckPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        let digitCheckPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
        let specialCharacterCheckPredicate = NSPredicate(format: "SELF MATCHES %@", ".*[^A-Za-z0-9]+.*")
        
        // Evaluate each check and print out the result
        let isLengthValid = lengthCheckPredicate.evaluate(with: password)
        print("Length valid: \(isLengthValid)")
        
        let isLowercaseValid = lowercaseCheckPredicate.evaluate(with: password)
        print("Lowercase valid: \(isLowercaseValid)")
        
        let isUppercaseValid = uppercaseCheckPredicate.evaluate(with: password)
        print("Uppercase valid: \(isUppercaseValid)")
        
        let isDigitValid = digitCheckPredicate.evaluate(with: password)
        print("Digit valid: \(isDigitValid)")
        
        let isSpecialCharacterValid = specialCharacterCheckPredicate.evaluate(with: password)
        print("Special Character valid: \(isSpecialCharacterValid)")
        
        // Return the combined result
        return isLengthValid && isLowercaseValid && isUppercaseValid && isDigitValid && isSpecialCharacterValid
    }
    
    
    
    
    
    
    
    
    func validateAge(_ age: String) -> Bool {
        let ageRegex = NSPredicate(format: "SELF MATCHES %@", #"^(1[8-9]|[2-9][0-9]|100)$"#)
        return ageRegex.evaluate(with: age)
    }
    
    
    
    
    
    func validateHeight(_ height: String) -> Bool {
        let heightRegex = #"^([1-2][0-9][0-9]|300)$"#
        let heightValidation = NSPredicate(format: "SELF MATCHES %@", heightRegex)
        return heightValidation.evaluate(with: height)
    }
    
    // Method to validate weight
    func validateWeight(_ weight: String) -> Bool {
        let weightRegex = #"^([0-3]?[2-9][0-9]|400)$"#
        let weightValidation = NSPredicate(format: "SELF MATCHES %@", weightRegex)
        return weightValidation.evaluate(with: weight)
    }
    
    
    func handleGenderChange(_ gender: String) {
        if gender == "غير محدد" {
            genderError = "يجب عليك تحديد الجنس"
        } else {
            genderError = ""
        }
    }
    
    
    
    
    
    
    
} // end of struct patientRegestrationPage




extension Gender {
    static func genderFromBiologicalSex(_ hkBiologicalSex: HKBiologicalSex?) -> Gender {
        guard let biologicalSex = hkBiologicalSex else {
            return .notSet
        }
        
        switch biologicalSex {
        case .female: return .female
        case .male: return .male
        default: return .notSet
        }
    }
}



#Preview {
    PractitionerRegestrationPage()
}


