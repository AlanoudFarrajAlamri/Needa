import CommonCrypto
import SwiftUI
import Foundation
import CloudKit
import HealthKit


// Enum to represent gender
enum Gender: String, CaseIterable, Identifiable {
    case male = "ذكر"
    case female = "أنثى"
    case notSet = "غير محدد" // To handle unknown or not set cases
    
    var id: String { self.rawValue }
}

struct patientRegestrationPage: View {
    
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
    // @State private var saveWord = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var nameError = ""
    @State private var ageError = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var confirmPasswordError = ""
    @State private var heightError = ""
    @State private var weightError = ""
    @State private var shouldNavigate = false
    @State private var genderError = ""
    @State private var idNUMError = ""
    
    @State private var bubbleText =  "يجب أن تحوي حرف كبير، حرف صغير، رقم، رمز، ٨ خانات على الأقل"
    @State private var isBubbleVisible = false
    
    // Define consistent padding for all elements
    private let elementPadding: CGFloat = 20
    
    
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
                        
                        
                        Text("إنشاء حساب مستخدم")
                            .font(.title)
                            .bold()
                            .padding(.trailing, -20.0) //-60 ->
                        //.offset(x:70, y:-30)
                            .foregroundColor(Color("button"))
                            .multilineTextAlignment(.leading)
                        
                        Group {
                            HStack {
                                Text("الاسم الرباعي")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("*")
                                    .foregroundColor(.red)
                                    .padding(.leading, -255)
                            }  .edgesIgnoringSafeArea(.all)
                            
                            
                            
                            TextField("", text: $name, onEditingChanged: { editing in
                                if !editing {
                                    nameError =
                                    validateEnglishName(name)||validateArabicName(name) ? "" : "أدخل الاسم الرباعي بشكل صحيح "
                                }
                            })
                            
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            
                            
                            if !nameError.isEmpty {
                                Text(nameError)
                                    .foregroundColor(.red)
                            }
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
                            
                            TextField("", text: $idNUM, onEditingChanged: { editing in
                                if !editing {
                                    idNUMError = validateId(idNUM) ? "" : "أدخل هوية وطنية صحيحة"
                                }
                            })
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .environment(\.layoutDirection, .rightToLeft)
                            
                            if !idNUMError.isEmpty {
                                Text(idNUMError)
                                    .foregroundColor(.red)
                            }
                            
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
                                    .padding(.leading, -235)
                            }
                            
                            TextField("", text: $email, onEditingChanged: { isEditing in
                                if !isEditing {
                                    emailError = validateEmail(email) ? "" : "أدخل بريد إلكتروني صحيح"
                                }
                            })
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .environment(\.layoutDirection, .rightToLeft)
                            
                            if !emailError.isEmpty {
                                Text(emailError)
                                    .foregroundColor(.red)
                            }
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        
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
                                        // Dismiss the bubble if tapped outside of it
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
                        }.environment(\.layoutDirection, .rightToLeft)  //end of group 7
                        
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
                            checkIfEmailExists(email) { emailExists in
                                DispatchQueue.main.async {
                                    if emailExists {
                                        self.emailError = "البريد الإلكتروني موجود بالفعل."
                                    } else {
                                        
                                        self.emailError = ""
                                        
                                        checkIfIDExists(idNUM) { idExists in
                                            DispatchQueue.main.async {
                                                if idExists {
                                                    self.idNUMError = "الهوية موجودة بالفعل."
                                                } else {
                                                    
                                                    self.idNUMError = ""
                                                    
                                                    
                                                    // Start the user registration process
                                                    validateFields()
                                                    registerUser()
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
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
    
    private func registerUser() {
        
        // Exit the function if there are any validation errors
        guard nameError.isEmpty, ageError.isEmpty, emailError.isEmpty,
              passwordError.isEmpty, confirmPasswordError.isEmpty,
              heightError.isEmpty, weightError.isEmpty, idNUMError.isEmpty  else {
            showErrorMessage("Validation failed. Please check the fields again. 335line")
            return
        }
        
        // Ensure that the age, height, and weight can be converted into their respective types
        guard let ageInt = Int(age) else {
            showErrorMessage("Validation failed. Age, height, or weight is not in the correct format.")
            return
        }
        
        guard let IdInt = Int(idNUM) else {
            showErrorMessage("Validation failed. Id, age, height, or weight is not in the correct format.")
            return
        }
        
        
        let individualInfoRecord = CKRecord(recordType: "Individual")
        individualInfoRecord["Email"] = email
        individualInfoRecord["FullName"] = name
        individualInfoRecord["Age"] =  ageInt
        individualInfoRecord["NationalID"] =  IdInt
        individualInfoRecord["Gender"] = gender.rawValue
        individualInfoRecord["Hight"] = height
        individualInfoRecord["Wight"] = weight
        individualInfoRecord["UserType"] = "user"
        
        let passwordHash = hashPassword(password)
        individualInfoRecord["Password"] = passwordHash
        
        for (key, value) in individualInfoRecord.allKeys().map({ ($0, individualInfoRecord[$0]!) }) {
            print("\(key): \(value)")
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        privateDatabase.save(individualInfoRecord) {  record, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showErrorMessage("CloudKit Save Error: \(error.localizedDescription)")
                } else if let record = record {
                    
                    // Retrieve the userRecordID from the saved record and save it to UserDefaults
                    let userRecordIDString = record.recordID.recordName
                    UserDefaults.standard.set(userRecordIDString, forKey: "userRecordID")
                    
                    // After the user is successfully registered and you have their CloudKit record ID:
                    if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                        // Send the token to CloudKit using the AppDelegate's method
                        // You need to ensure that the AppDelegate has this method
                        let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        appDelegate?.updateTokenInCloudKit(token: fcmToken, userRecordIDString: userRecordIDString)
                        
                        // Clear the token from UserDefaults as it's no longer needed there
                        UserDefaults.standard.removeObject(forKey: "fcmToken")
                    }
                    
                    //UserDefaults.standard.set(record.recordID.recordName, forKey: "userRecordID")
                    self.sendUserNameToWatch(name: self.name)
                    //save token
                    AppDelegate.shared.updateTokenIfNeeded()
                    
                    self.shouldNavigate = true
                }
            }
        }
    } // end of func registerUser()
    
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
        
        guard let data = password.data(using: .utf8) else { return "defaultHashValue" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hashedPassword = Data(hash).base64EncodedString()
        return hashedPassword
        
    } // end of hashPassword fun
    
    
    // Function to show an error message to the user
    private func showErrorMessage(_ message: String) {
        print("error func showErrorMessage 405line registraion page")
    }
    
    
    
    
    
    //--------------- end of clould kit functions
    
    
    //--------------- vaildation function
    
    
    //validation here 
    func validateFields() {
        nameError = ""
        ageError = ""
        emailError = ""
        passwordError = ""
        confirmPasswordError = ""
        heightError = ""
        weightError = ""
        genderError = ""
        idNUMError = ""
        
        isLoading = true
        
        // Validate name
        nameError = name.isEmpty ? "أدخل الاسم الرباعي بشكل صحيح " : ""
        
        let nameError = validateEnglishName(name) || validateArabicName(name) ? "" : "أدخل الاسم الرباعي بشكل صحيح"
        
        // Validate age
        ageError = age.isEmpty || !validateAge(age) ? "أدخل عمرًا بين ١٨ و١٠٠ رجاءً" : ""
        
        // Validate id
        idNUMError = idNUM.isEmpty || !validateId(idNUM) ? "أدخل هوية وطنية صحيحة" : ""
        
        // Validate email
        emailError = email.isEmpty || !validateEmail(email) ? "أدخل بريد الكتروني صحيح" : ""
        
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
        
        // Set isLoading to false if there are errors
        if !nameError.isEmpty || !ageError.isEmpty || !emailError.isEmpty || !passwordError.isEmpty || !confirmPasswordError.isEmpty || !heightError.isEmpty || !weightError.isEmpty || !genderError.isEmpty || !idNUMError.isEmpty {
            isLoading = false
        }
        
        
        //  let user = createUser()
        //  saveUserToCloudKit(user)
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
    
    
    
    func validateAge(_ age: String) -> Bool {
        let ageRegex = NSPredicate(format: "SELF MATCHES %@", #"^(1[8-9]|[2-9][0-9]|100)$"#)
        return ageRegex.evaluate(with: age)
    }
    
    
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailValidation = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailValidation.evaluate(with: email)
    }
    
    func validateHeight(_ height: String) -> Bool {
        let heightRegex = #"^([1-2][0-9][0-9]|260)$"#
        let heightValidation = NSPredicate(format: "SELF MATCHES %@", heightRegex)
        return heightValidation.evaluate(with: height)
    }
    
    // Method to validate weight
    func validateWeight(_ weight: String) -> Bool {
        let weightRegex = #"^([0-3]?[2-9][0-9]|300)$"#
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
    
    
    private func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(format: "Email == %@", email)
        let query = CKQuery(recordType: "Individual", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error checking email: \(error.localizedDescription)"
                    completion(false)
                } else if let records = records, !records.isEmpty {
                    // Email exists if records are returned
                    self.errorMessage = "البريد الإلكتروني موجود بالفعل."
                    completion(true)
                } else {
                    // Email does not exist if no records are returned
                    completion(false)
                }
            }
        }
    }
    
    
    private func validateId(_ idNUM: String) -> Bool{
        let idRegex = NSPredicate(format: "SELF MATCHES %@", "^\\d{10}$")
        return idRegex.evaluate(with: idNUM)
    }
    
    
    private func checkIfIDExists(_ idNUM: String, completion: @escaping (Bool) -> Void) {
        
        guard let IdInt = Int(idNUM) else {
            showErrorMessage("Validation failed. Id, age, height, or weight is not in the correct format.")
            return
        }
        
        
        
        let predicate = NSPredicate(format: "NationalID == %d", IdInt)
        let query = CKQuery(recordType: "Individual", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error checking ID: \(error.localizedDescription)"
                    completion(false)
                } else if let records = records, !records.isEmpty {
                    // Email exists if records are returned
                    self.errorMessage = "الهوية موجودة بالفعل."
                    completion(true)
                } else {
                    // Email does not exist if no records are returned
                    completion(false)
                }
            }
        }
    }
    
    
} // end of struct patientRegestrationPage



// Extend the Gender enum to convert from HealthKit's biological sex

extension Gender {
    static func from(hkBiologicalSex: HKBiologicalSex?) -> Gender {
        switch hkBiologicalSex {
        case .female: return .female
        case .male: return .male
        default: return .notSet
        }
    }
}

#Preview {
    patientRegestrationPage()
}
