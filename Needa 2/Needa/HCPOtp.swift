import SwiftUI
import FirebaseFunctions
import CloudKit
import FirebaseAuth

struct HCPOtp: View {
    @State private var emailError = "" // Error message for email issues
    @State private var email = "" // User email
    @State private var authUserEmail = "" // Authenticated user's email
    @State private var id = 0 // User ID
    @State private var profileID = "" // User's national ID input
    @State private var showingContentView = false
    @State private var isEmailVerified: Bool? = nil // Email verification status
    @State private var errorMessage = "" // General error message for operations
    @State private var showingAlert = false // Controls visibility of alert dialog
    @State private var alertMessage = "تحذير!" // Message to show in alerts
    @State private var navigateToRegistration = false // Controls navigation to the registration page
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor").ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            self.showingContentView = true
                        }) {
                            Image(systemName: "chevron.backward").padding().foregroundColor(Color("button"))
                        }
                        .fullScreenCover(isPresented: $showingContentView) {
                            ContentView()
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    .zIndex(1)
                    
                    VStack(spacing: 20) {
                        Image("needa").resizable().scaledToFit().frame(width: 250, height: 350).padding(.top, -50)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ادخل الهوية الوطنية:")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.leading)
                            
                            TextField("", text: $profileID)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding()
                                .keyboardType(.numberPad)
                            
                            
                            if isEmailVerified == false {
                                sendOTPButton() // Show button to send OTP if email is not verified
                            } else if isEmailVerified == true {
                                verifyIdentityButton() // Show button to verify identity if email is verified
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            verifyEmail { isVerified in
                self.isEmailVerified = isVerified // Check if the email is verified on appear
            }
        }
    }
    
    @ViewBuilder
    func sendOTPButton() -> some View {
        Button(action: {
            // Check if the profile ID is a valid number
            if let idValue = Int64(profileID) { 
                self.id = Int(idValue)  // Convert and store the ID
                
                // Fetch the email using the valid ID
                fetchHealthcarePractitionerEmail(id: Int64(self.id)) { result in
                    switch result {
                    case .success(let fetchedEmail):
                        // Update the email state
                        self.email = fetchedEmail
                        
                        // Send verification email
                        sendVerificationEmail(email: fetchedEmail) { success, error in
                            if success {
                                self.alertMessage = "تم ارسال رسالة لتوثيق البريد الالكتروني"
                                self.isEmailVerified = true  // Assuming you want to track verification status
                            } else {
                                self.alertMessage = "Failed to send verification email: \(error?.localizedDescription ?? "Unknown error")"
                                self.showingAlert = true
                            }
                        }
                    case .failure(let error):
                        // Handle failure in fetching the email
                        self.alertMessage = "الايميل غير موجود: \(error.localizedDescription)"
                        self.showingAlert = true
                    }
                }
            } else {
                // Handle invalid input for profile ID
                self.alertMessage = "هذه الهوية غير صالحة"
                self.showingAlert = true
            }
        }) {
            Text("أرسل للبريد الالكتروني لتوثيق المستخدم")
                .frame(maxWidth: 350, minHeight: 50)
                .background(Color("button"))
                .foregroundColor(.white)
                .cornerRadius(30)
                .padding(.horizontal)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    
    @ViewBuilder
    func verifyIdentityButton() -> some View {
        Button(action: {
            if let idValue = Int64(profileID) {
                self.id = Int(idValue)
                UserDefaults.standard.set(self.id, forKey: "idNum")
                fetchHealthcarePractitionerEmail(id: Int64(self.id)) { result in
                    switch result {
                    case .success(let email):
                        DispatchQueue.main.async {
                            self.email = email
                            if let currentUser = Auth.auth().currentUser {
                                let authUserEmail = currentUser.email ?? "def email"
                                print("Fetching data for email: \(authUserEmail)")
                            }
                            if let currentUser = Auth.auth().currentUser, currentUser.email == self.email {
                                self.navigateToRegistration = true
                            } else {
                                self.alertMessage = "البريد الالكتروني المقابل لهذه الهوية مختلف عن البريد الموثق \(self.email) != \(authUserEmail ?? "لا يوجد ")"
                                self.showingAlert = true
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.alertMessage = "الايميل غير موجود: \(error.localizedDescription)"
                            self.showingAlert = true
                        }
                    }
                }
            } else {
                self.alertMessage = "هذه الهوية غير صالحة"
                self.showingAlert = true
            }
        }) {
            Text("تحقق من الهوية وانتقل لصفحة التسجيل")
                .frame(maxWidth: 350, minHeight: 50)
                .background(Color("button"))
                .foregroundColor(.white)
                .cornerRadius(30)
                .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $navigateToRegistration) {
            PractitionerRegestrationPage() // Navigate to registration page if verification is successful
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("اشعار"), message: Text(alertMessage), dismissButton: .default(Text("حسنًا")))
        }
    }
    
    func fetchHealthcarePractitionerEmail(id: Int64,  completion: @escaping (Result<String, Error>) -> Void) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordType = "Individual"
        let idField =  "NationalID"
        print("Updating personal information with:", id)
        
        
        // Create a query predicate that matches the ID to the corresponding field
        let predicate = NSPredicate(format: "%K == %lld", idField, id)
        
        // Perform the query
        privateDatabase.perform(CKQuery(recordType: recordType, predicate: predicate), inZoneWith: nil) { records, error in
            if let error = error {
                // Log error for debugging
                print("Database query failed: \(error.localizedDescription)")
                completion(.failure(NSError(domain: "DatabaseQueryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database query failed: \(error.localizedDescription)"])))
                return
            }
            
            guard let records = records, !records.isEmpty else {
                print("No records found for ID: \(id)")
                completion(.failure(NSError(domain: "RecordNotFoundError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No records found for the provided ID"])))
                return
            }
            
            // Handle Individual records
            guard let record = records.first,
                  let userType = record.value(forKey: "UserType") as? String,
                  userType == "healthcarePractitioner",
                  let email = record.value(forKey: "Email") as? String else {
                print("Invalid or missing data for individual record.")
                completion(.failure(NSError(domain: "DataValidationError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid or missing data for healthcare practitioner"])))
                return
            }
            
            completion(.success(email))
            
        }
    }
    
    func sendVerificationEmail(email: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: "temporaryPassword123!") { authResult, error in
            guard let user = authResult?.user, error == nil else {
                completion(false, error)
                return
            }
            
            user.sendEmailVerification { error in
                completion(error == nil, error)
            }
        }
    }
    
    func verifyEmail(completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            user.reload { error in
                if let error = error {
                    print(error)
                    completion(false)
                } else if user.isEmailVerified {
                    print("Email verified.")
                    completion(true)
                } else {
                    print("Email not verified.")
                    completion(false)
                }
            }
        } else {
            print("No user logged in.")
            completion(false)
        }
    }
}

// Preview for SwiftUI view
struct HCPOtp_Previews: PreviewProvider {
    static var previews: some View {
        HCPOtp()
    }
}
