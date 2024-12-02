import SwiftUI
import CloudKit
import CommonCrypto

struct PractitionerLogIn: View {
    @State private var showingContentView = false
    @State private var nationalID = ""
    @State private var password = ""
    @State private var loginError = ""
    @State private var showNeedaHomePage = false
    @State private var showErrorAlert = false
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor").ignoresSafeArea(.all)
                
                VStack {
                    HStack {
                        Button(action: {
                            self.showingContentView = true
                        }) {
                            HStack {
                                Image(systemName: "chevron.backward")
                            }
                            .padding()
                            .foregroundColor(Color("button"))
                        }
                        .fullScreenCover(isPresented: $showingContentView) {
                            ContentView()
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    .zIndex(1)
                    
                    VStack {
                        Image("needa").resizable().scaledToFit().frame(width: 350, height: 350).padding(.top, -60)
                        
                        VStack(alignment: .leading) {
                            Text("ادخل الهوية الوطنية:")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 20)
                            
                            TextField("", text: $nationalID)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(50)
                                .padding(.top, 5)
                                .keyboardType(.numberPad)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            Text("ادخل كلمة المرور:")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 20)
                            
                            SecureField("", text: $password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(50)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        NavigationLink(
                            destination: NeedaHomePage(),
                            isActive: $showNeedaHomePage
                        ) {
                            Button(action: {
                                verifyUser()
                            }) {
                                Text("التالي")
                                    .frame(maxWidth: 150, minHeight: 50)
                                    .background(Color("button"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal)
                            }
                            .padding(.bottom, max(keyboardHeight, 80))
                        }
                        
                    }
                    .padding(.bottom, max(keyboardHeight, 5))
                    //.animation(.easeOut(duration: 0.3))
                }
            }
            .onAppear(perform: setupKeyboardObservers)
            .onDisappear(perform: removeKeyboardObservers)
            .gesture(
                TapGesture()
                    .onEnded {
                        hideKeyboard()
                    }
            )
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("خطأ في تسجيل الدخول"), message: Text(loginError), dismissButton: .default(Text("حسناً")))
            }
        }
    }
    
    func verifyUser() {
        let hashedPassword = hashPassword(password)
        authenticate(nationalID: nationalID, hashedPassword: hashedPassword) { success in
            DispatchQueue.main.async {
                if success {
                    print("self.showNeedaHomePage = true,, inside verifyUser()")
                    self.showNeedaHomePage = true
                } else {
                    print("showErrorAlert = true,, inside verifyUser()")
                    loginError = "الهوية الوطنية أو كلمة المرور خاطئه"
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        guard let data = password.data(using: .utf8) else { return "defaultHashValue" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    private func authenticate(nationalID: String, hashedPassword: String, completion: @escaping (Bool) -> Void) {
        guard let nationalIDInt = Int64(nationalID) else {
            print("Invalid national ID format")
            completion(false)
            return
        }

        let predicate = NSPredicate(format: "NationalID == %d AND Password == %@", nationalIDInt, hashedPassword)
        let query = CKQuery(recordType: "Individual", predicate: predicate)
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
                    if let record = records.first {
                        let userRecordIDString = record.recordID.recordName
                        UserDefaults.standard.set(userRecordIDString, forKey: "userRecordID")
                    }
                    print("Success in user login")
                    saveHealthInfoRecord()
                    saveMedicationRecord()
                    saveChronicRecord()
                    savesurgeryRecord()
                    completion(true)
                } else {
                    print("Failed in user login")
                    completion(false)
                }
            }
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            self.keyboardHeight = keyboardFrame.height
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    

    
    func saveHealthInfoRecord() {
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("No userRecordID found in UserDefaults")
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format: "UserID == %@", reference)
        let query = CKQuery(recordType: "HealthInformation", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit error: \(error.localizedDescription)")
                    return
                }
                
                if let records = records, !records.isEmpty {
                    if let healthInfoRecord = records.first {
                        let healthInfoRecordIDString = healthInfoRecord.recordID.recordName
                        UserDefaults.standard.set(healthInfoRecordIDString, forKey: "healthInfoRecord")
                        print("HealthInfoRecord ID saved in UserDefaults: \(healthInfoRecordIDString)")
                    }
                } else {
                    print("No HealthInformation record found for the given USERID")
                }
            }
        }
    }

    
    func saveChronicRecord() {
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("No userRecordID found in UserDefaults")
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format: "UserID == %@", reference)
        let query = CKQuery(recordType: "ChroincDiseses", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit error: \(error.localizedDescription)")
                    return
                }
                
                if let records = records, !records.isEmpty {
                    if let chroincRecord = records.first {
                        let chroincRecordIDString = chroincRecord.recordID.recordName
                        UserDefaults.standard.set(chroincRecordIDString, forKey: "chroincRecord")
                        print("chroincRecord ID saved in UserDefaults: \(chroincRecordIDString)")
                    }
                } else {
                    print("No HealthInformation record found for the given USERID")
                }
            }
        }
    }

    
    func saveMedicationRecord() {
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("No userRecordID found in UserDefaults")
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format: "UserID == %@", reference)
        let query = CKQuery(recordType: "Medications", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit error: \(error.localizedDescription)")
                    return
                }
                
                if let records = records, !records.isEmpty {
                    if let medicationRecord = records.first {
                        let medicationRecordIDString = medicationRecord.recordID.recordName
                        UserDefaults.standard.set(medicationRecordIDString, forKey: "medicationRecord")
                        print("medicationRecord ID saved in UserDefaults: \(medicationRecordIDString)")
                    }
                } else {
                    print("No HealthInformation record found for the given USERID")
                }
            }
        }
    }

    
    func savesurgeryRecord() {
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("No userRecordID found in UserDefaults")
            return
        }
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format: "UserID == %@", reference)
        let query = CKQuery(recordType: "PerviousSurgies", predicate: predicate)
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("CloudKit error: \(error.localizedDescription)")
                    return
                }
                
                if let records = records, !records.isEmpty {
                    if let surgeryRecord = records.first {
                        let surgeryRecordIDString = surgeryRecord.recordID.recordName
                        UserDefaults.standard.set(surgeryRecordIDString, forKey: "surgeryRecord")
                        print("HealthInfoRecord ID saved in UserDefaults: \(surgeryRecordIDString)")
                    }
                } else {
                    print("No HealthInformation record found for the given USERID")
                }
            }
        }
    }

    
    
    private func hideKeyboard() {
        UIApplication.shared.endEditing()
    }
}

extension UIApplication {
    func endEditing() {
        self.windows.forEach { $0.endEditing(true) }
    }
}

struct PractitionerLogIn_Previews: PreviewProvider {
    static var previews: some View {
        PractitionerLogIn()
    }
}
