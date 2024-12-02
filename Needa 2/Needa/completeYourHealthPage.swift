import SwiftUI
import CloudKit
import HealthKit
import Vision
import UIKit

struct completeYourHealthPage: View {
    
    
    @State private var isImagePickerPresented = false // State for showing the image picker
       @State private var capturedImage: UIImage? // Store the captured image
       @State private var detectedMedicationName: String = "" // Store the detected medication name
       
    
    @State private var previousSurgerySelection: YesNoOption = .no
    @State private var surgeriesList: [Surgery] = [Surgery(name: "", year: "")]
    @State private var chronicDiseasesSelection: YesNoOption = .no
    @State private var chronicDiseasesList: [ChronicDisease] = [
        ChronicDisease(name: "", medication: "", dose: "غير محدد", unit: .notSet)]
    // Options for dosages and years of surgeries
    let doseNumbers = ["غير محدد"] + Array(1...10).map { String($0) }
    
    @State private var yearOptions: [String] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = 1960
        return (startYear...currentYear).map { String($0) }.reversed()
    }()
    
    @State private var allergySelection: YesNoOption = .no
    
    
    @State private var phoneNumber = ""
    @State private var alargies = ""
    @State private var medicalNotes = ""
    @State private var heartrate = ""
    @State private var temperature = ""
    @State private var bloodpressure = ""
    @State private var chronicDiseases = ""
    @State private var previousSergiuers = ""
    @State private var firstPhoneNumber = ""
    @State private var secondPhoneNumber = ""
    @State private var surgeyName = ""
    @State private var surgeyYear = ""
    
    @State private var NeedaHomePage = true
    // States for navigation and alerts

    @State private var isBubble1Visible = false
    @State private var isBubble2Visible = false
    @State private var showingPatientRegestrationPage = false
    @State private var shouldNavigate = false
    
    // Text for informational bubbles
    @State private var bubbleText = "يُستخدم رقم جوال القريب للتبليغ وقت النداء"
    @State private var bubbleText2 = "أدخل ملاحظات صحية"
    
    // Blood type selection
    @State private var bloodtype: BloodType = .notSet
    private let elementPadding: CGFloat = 20
    
    // Error messages for validation
    @State private var errorMessage = ""
    @State private var phoneError = ""
    @State private var firstPhoneError = ""
    @State private var secondPhoneError = ""
    @State private var alargiesError = ""
    @State private var previousSergiuersError = ""
    @State private var medicalNotesError = ""
    @State private var chronicDiseasesError = ""
    @State private var bloodTypeError: String = ""
    @State private var errorYear: String = ""
    @State private var errorSurName: String = ""
    @State private var errorChroncError: String = ""
    @State private var errorMedName: String = ""
    
    
    @State private var isHealthPractitioner = false

    
    @State private var repeated = false
    var body: some View {
        
        ZStack {
            
            Color("backgroundColor")
                .ignoresSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        // Dismiss the current view to navigate back
                        self.showingPatientRegestrationPage = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                        }
                        .padding()
                        .foregroundColor(Color("button"))
                    }
                    .fullScreenCover(isPresented: $showingPatientRegestrationPage) {
                        patientRegestrationPage()
                    }
                    Spacer()
                }
                
                Spacer()
            }.padding(elementPadding)
                .zIndex(1)
            // end of VStack
            
            ScrollView {
                
                
                
                VStack(spacing: 10) {
                    
                    Text("أكمل معلوماتك")
                        .font(.title)
                        .bold()
                        .foregroundColor(Color("button"))
                        .multilineTextAlignment(.trailing)
                        .offset(x:90, y:0)
                        .padding(.bottom)
                    
                    
                    // Phone Number Field
                    Group {
                        
                        HStack{
                            Text("رقم الجوال")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("*")
                                .foregroundColor(.red)
                                .font(.system(size: 30))
                                .padding(.leading, -280)
                        }
                        
                        TextField("", text: $phoneNumber, onEditingChanged: { isEditing in
                            if !isEditing {
                                phoneError = validatePhoneNumber(phoneNumber) ? "" : "أدخل رقمًا سعوديًا مكون من ١٠أرقام"
                            }
                        })
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        if !phoneError.isEmpty {
                            Text(phoneError)
                                .foregroundColor(.red)
                        }  }
                    .environment(\.layoutDirection, .rightToLeft)// end of Phone Number Field
                    
                    
                    // First Relative Phone Number Field
                    Group {
                        HStack{
                            Text("رقم جوال القريب الأول")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("*")
                                .foregroundColor(.red)
                                .font(.system(size: 30))
                                .padding(.leading, -185)
                            
                            InfoButtonView(isBubbleVisible: $isBubble1Visible, bubbleText: $bubbleText)
                                .padding(.leading, -10)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    // Dismiss the bubble if tapped outside of it
                                    if isBubble1Visible {
                                        isBubble1Visible = false
                                    }
                                }
                            
                        }
                        
                        TextField("", text: $firstPhoneNumber, onEditingChanged: { isEditing in
                            if !isEditing {
                                firstPhoneError = validatePhoneNumber(firstPhoneNumber) ? "" : "أدخل رقمًا سعوديًا مكون من  ١٠أرقام"
                            }
                        })
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        //   .offset(x:0, y:-70) //x:0, y:-60
                        
                        
                        
                        
                        if !firstPhoneError.isEmpty {
                            Text(firstPhoneError)
                                .foregroundColor(.red)
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)   
                    // end of First Relative Phone Number Field
                    
                    
                    // Second Relative Phone Number Field
                    Group {
                        HStack{
                            Text("رقم جوال القريب الثاني")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("*")
                                .foregroundColor(.red)
                                .font(.system(size: 30))
                                .padding(.leading, -200)
                            
                        }
                        
                        TextField("", text: $secondPhoneNumber, onEditingChanged: { isEditing in
                            if !isEditing {
                                secondPhoneError = validatePhoneNumber(secondPhoneNumber) ? "" : "أدخل رقمًا سعوديًا مكون من  ١٠ أرقام"
                            }
                        })
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        
                        
                        if !secondPhoneError.isEmpty {
                            Text(secondPhoneError)
                                .foregroundColor(.red)
                        }
                    } .environment(\.layoutDirection, .rightToLeft) 
                    // end of Second Relative Phone Number Field
                    
                    
                    // Blood Type Picker
                    Group {
                        HStack{
                            Text("فصيلة الدم")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("*")
                                .foregroundColor(.red)
                                .padding(.leading, -275)
                                .font(.system(size: 30))
                        }
                        Menu {
                            Picker("", selection: $bloodtype) {
                                ForEach(BloodType.allCases) { bloodtype in
                                    Text(bloodtype.rawValue).tag(bloodtype)
                                }
                            }
                            .onChange(of: bloodtype) { newValue in
                                handleBloodTypeChange(newValue.rawValue)
                            }
                        } label: {
                            HStack {
                                Text(bloodtype.rawValue)
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
                        .accentColor(.white)
                        .environment(\.layoutDirection, .rightToLeft)
                        if !bloodTypeError.isEmpty {
                            Text(bloodTypeError)
                                .foregroundColor(.red)
                        }
                    }  .environment(\.layoutDirection, .rightToLeft)// end of Blood Type Picker
                    
                    
                    Group {
                        HStack{    Text("هل تعاني من حساسية؟")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                            
                            Text("*")
                                .foregroundColor(.red)
                                .font(.system(size: 30))
                                .padding(.leading, -190)
                                .padding(.top, 10)
                        }// Picker for selecting Yes or No
                        Menu {
                            Picker("هل تعاني من حساسية؟", selection: $allergySelection) {
                                ForEach(YesNoOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            HStack {
                                Text(allergySelection.rawValue)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            
                        }
                        .onChange(of: allergySelection) { newValue in
                            if newValue == .no {
                                
                                alargiesError = ""
                                
                            }
                        }
                        .padding(.bottom, allergySelection == .yes ? 20 : 0) // Adjust padding based on selection
                        
                        // Conditional TextField for entering allergies details
                        if allergySelection == .yes {
                            TextField("أدخل تفاصيل الحساسية", text: $alargies)
                                .onChange(of: alargies) { newValue in
                                    validateFieldsAll()
                                    
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            if allergySelection == .yes && !alargiesError.isEmpty {
                                Text(alargiesError)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    //.padding()
                    .environment(\.layoutDirection, .rightToLeft)
                    // end of Allergies Field
                    
                    
                    
                    
                    Group {
                        HStack {
                            Text("هل أجريت أي عمليات جراحية سابقة؟")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("*")
                                .foregroundColor(.red)
                                .font(.system(size: 30))
                                .padding(.leading, -100)
                        }
                        Menu {
                            Picker("Select", selection: $previousSurgerySelection) {
                                ForEach(YesNoOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            HStack {
                                Text(previousSurgerySelection.rawValue)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                        .accentColor(.white)
                        .onChange(of: previousSurgerySelection) { newValue in
                            if newValue == .no {
                                // Clear the surgery-related error messages and reset the list
                                errorYear = ""
                                errorSurName = ""
                                surgeriesList = [Surgery(name: "", year: "")]
                            }
                        }
                        
                        if previousSurgerySelection == .yes {
                            ForEach($surgeriesList.indices, id: \.self) { index in
                                HStack {
                                    TextField("ادخل اسم العملية", text: $surgeriesList[index].name)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .onChange(of: surgeriesList[index].name) { newValue in
                                            validateNameOnChange()
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                    
                                        .frame(height: 36) // Match the Menu's height for consistency
                                    
                                    Menu {
                                        Picker("سنة العملية", selection: $surgeriesList[index].year) {
                                            ForEach(yearOptions, id: \.self) { year in
                                                Text(year).tag(year)
                                                
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(surgeriesList[index].year.isEmpty ? "اختر سنة العملية" : surgeriesList[index].year)
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .frame(height: 36) // Ensure consistent height with TextField
                                        .background(Color.white)
                                        .cornerRadius(10)
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 1))
                                    
                                    if surgeriesList.count > 1 {
                                        Button(action: {
                                            surgeriesList.remove(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                            Text("إزالة")
                                        }.foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            
                            Button(action: {
                                surgeriesList.append(Surgery(name: "", year: ""))
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                    Text("أضف آخر")
                                }.foregroundColor(.green)
                            }
                            .padding()
                        }
                        
                        if previousSurgerySelection == .yes && !errorSurName.isEmpty {
                            Text(errorSurName)
                                .foregroundColor(.red)
                        }
                        if previousSurgerySelection == .yes && !errorYear.isEmpty{
                            Text(errorYear)
                                .foregroundColor(.red)
                        }
                        
                    }.environment(\.layoutDirection, .rightToLeft)
                    
                    
                    
                    
                    
                    // Chronic Diseases Section
                    Group {
                                           HStack {
                                               Text("هل تعاني من امراض مزمنة؟")
                                                   .foregroundColor(.black)
                                                   .frame(maxWidth: .infinity, alignment: .leading)
                                               Text("*").foregroundColor(.red).font(.system(size: 30))
                                           }
                                           Menu {
                                               Picker("Select", selection: $chronicDiseasesSelection) {
                                                   ForEach(YesNoOption.allCases, id: \.self) { option in
                                                       Text(option.rawValue).tag(option)
                                                   }
                                               }
                                           } label: {
                                               HStack {
                                                   Text(chronicDiseasesSelection.rawValue)
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
                                           .accentColor(.white)
                                           .onChange(of: chronicDiseasesSelection) { newValue in
                                               if newValue == .no {
                                                   chronicDiseasesList = [ChronicDisease(name: "", medication: "", dose: "1", unit: .mg)]
                                               }
                                           }
                                           
                                           if chronicDiseasesSelection == .yes {
                                               ForEach($chronicDiseasesList.indices, id: \.self) { index in
                                                   VStack {
                                                       TextField("اسم المرض", text: $chronicDiseasesList[index].name)
                                                           .textFieldStyle(RoundedBorderTextFieldStyle())
                                                           .onChange(of: chronicDiseasesList[index].name) { newValue in
                                                               validateChronicDiseasesOnChange()
                                                           }
                                                       
                                                       HStack {
                                                           Button(action: {
                                                               isImagePickerPresented = true // Show the custom image picker
                                                           }) {
                                                               Image(systemName: "camera")
                                                                   .font(.title)
                                                                   .padding()
                                                                   .background(Color.gray.opacity(0.2))
                                                                   .clipShape(Circle())
                                                           }

                                                           TextField("ادخل اسم الدواء", text: $chronicDiseasesList[index].medication, onEditingChanged: { editing in
                                                               if !editing {
                                                                   errorMedName = chronicDiseasesList[index].medication.isEmpty ? "أدخل اسم الدواء" : ""
                                                               }
                                                           })
                                                           .textFieldStyle(RoundedBorderTextFieldStyle())
                                                           .onChange(of: detectedMedicationName) { newValue in
                                                               chronicDiseasesList[index].medication = newValue // Update medication when detected
                                                           }
                                                       }
                                                       
                                                       LabelMenuPicker(label: "الجرعة", selection: $chronicDiseasesList[index].dose, options: doseNumbers)
                                                       LabelMenuPicker(label: "وحدة الجرعة", selection: Binding(
                                                           get: { chronicDiseasesList[index].unit.rawValue },
                                                           set: { chronicDiseasesList[index].unit = DoseUnit(rawValue: $0)! }
                                                       ), options: DoseUnit.allCases.map { $0.rawValue })
                                                       
                                                       if chronicDiseasesList.count > 1 {
                                                           Button(action: {
                                                               chronicDiseasesList.remove(at: index)
                                                           }) {
                                                               HStack {
                                                                   Image(systemName: "minus.circle.fill")
                                                                   Text("إزالة")
                                                               }
                                                               .foregroundColor(.red)
                                                           }
                                                       }
                                                   }
                                                   .padding()
                                                   .background(Color.white)
                                                   .cornerRadius(10)
                                                   .overlay(
                                                       RoundedRectangle(cornerRadius: 10)
                                                           .stroke(Color.gray, lineWidth: 1)
                                                   )
                                               }
                                               
                                               Button(action: {
                                                   if chronicDiseasesList.count < 3 {
                                                       chronicDiseasesList.append(ChronicDisease(name: "", medication: "", dose: "1", unit: .mg))
                                                   }
                                               }) {
                                                   HStack {
                                                       Image(systemName: "plus.circle.fill")
                                                       Text("أضف آخر")
                                                   }
                                .foregroundColor(.green)
                            }
                            //   .offset(x:0, y:-360)
                            if  !errorChroncError.isEmpty && chronicDiseasesSelection == .yes{
                                Text(errorChroncError)
                                    .foregroundColor(.red)
                            }
                            
                            if  !errorMedName.isEmpty && chronicDiseasesSelection == .yes{
                                Text(errorMedName)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        
                    } .environment(\.layoutDirection, .rightToLeft)
                    // End of Chronic Diseases Section
                    
                    
                    
                    //medical notes
                    Group {
                        HStack{  Text("الملاحظات الطبية")
                            
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            //    .offset(x:111, y:-360) //x:90, y:-60
                            Text("*")
                                .foregroundColor(.red)
                                .padding(.leading, -220)
                            //    .offset(x:-32, y:-355)
                                .font(.system(size: 30))
                            
                            InfoButtonView(isBubbleVisible: $isBubble2Visible, bubbleText: $bubbleText2)
                                .padding(.leading, -10)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    // Dismiss the bubble if tapped outside of it
                                    if isBubble2Visible {
                                        isBubble2Visible = false
                                    }
                                }}
                        
                        TextField("", text: $medicalNotes)
                            .onChange(of: medicalNotes) {validateFieldsMed()
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        
                        if !medicalNotesError.isEmpty {
                            Text(medicalNotesError)
                                .foregroundColor(.red)
                        }
                    }  .environment(\.layoutDirection, .rightToLeft)  // end of medical notes Field
                    
                        .navigationDestination(isPresented: $shouldNavigate) {
                            Needa.NeedaHomePage().navigationBarBackButtonHidden(true)
                        }
                    
                    Button(action: {
                        
                        validateFields()
                        
                        
                        if shouldNavigate{
                            
                            saveIndividualPersonalInformation { record in
                                if let record = record {
                                    self.saveHealthInformation(medicalNotes: medicalNotes, bloodtype: bloodtype.rawValue, alargies: alargies)
                                    self.saveSurgeries()
                                    self.saveChroinc()
                                }else{
                                    self.showErrorMessage("Failed to save saveSurgeries.")
                                }
                            }
                            
                        }
                        
                        
                    }) {
                        Text("التالي")
                            .frame(width:300, height:50)
                            .foregroundColor(Color.white)
                            .background(Color.button)
                            .cornerRadius(8)
                            .padding()
                    }
                    
                    
                } // end of vstack
                
                .padding()
            }
        }// end of scroll view
        
        .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(isPresented: $isImagePickerPresented, selectedImage: $capturedImage)
                        .onDisappear {
                            if let image = capturedImage {
                                detectTextInImage(image) // Detect text if an image is selected
                            }
                        }
                }
        .onAppear {
            HealthDataManager.shared.requestHealthKitPermissions { success, _ in
                if success {
                    HealthDataManager.shared.fetchBloodType { bloodTypeObject, _ in
                        // Directly use bloodTypeObject.bloodType since it's not optional
                        let hkBloodType = bloodTypeObject?.bloodType ?? .notSet // Assume .notSet represents an unknown value in HKBloodType
                        DispatchQueue.main.async {
                            self.bloodtype = BloodType.from(hkBloodType: hkBloodType)
                        }
                    }
                }
            }
            
            checkIfHealthPractitioner { isPractitioner in
                self.isHealthPractitioner = isPractitioner
                retrievePhoneNum()
            }
        }
        
        
    }// end of the body
    
    
    
    func detectTextInImage(_ image: UIImage) {
          guard let cgImage = image.cgImage else { return }
          
          let request = VNRecognizeTextRequest { (request, error) in
              guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
              
              var detectedText = ""
              
              for observation in observations {
                  guard let topCandidate = observation.topCandidates(1).first else { continue }
                  detectedText += topCandidate.string + "\n"
              }
              
              DispatchQueue.main.async {
                  self.detectedMedicationName = detectedText.trimmingCharacters(in: .whitespacesAndNewlines) // Update detected name
              }
          }
          
          request.recognitionLanguages = ["ar", "en"] // Support for Arabic and English
          request.recognitionLevel = .accurate
          
          let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
          try? handler.perform([request])
      }
    
    
    //--------------------- clould kit functions
    
    //DONE
    func saveIndividualPersonalInformation(completion: @escaping (CKRecord?) -> Void) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Retrieve the stored user record ID
        if let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") {
            let userRecordID = CKRecord.ID(recordName: userRecordIDString)
            
            // Fetch and update the existing record
            privateDatabase.fetch(withRecordID: userRecordID) { record, error in
                if let error = error {
                    print("Error fetching record: \(error.localizedDescription)")
                    completion(nil)
                    return
                    
                }
                
                if let record = record {
                    // Update the record with new data
                    record["phoneNumber"] = self.phoneNumber /*NSString(string: self.phoneNumber)*/
                    record["FirstRelativePhoneNumber"] = self.firstPhoneNumber /*NSString(string: self.firstPhoneNumber)*/
                    record["SecondRelativePhoneNumber"] = self.secondPhoneNumber /*NSString(string: self.secondPhoneNumber)*/
                    
                    
                    // Save the updated record
                    privateDatabase.save(record) { savedRecord, saveError in
                        DispatchQueue.main.async {
                            if let saveError = saveError {
                                print("CloudKit Save Error phone numbers function: \(saveError.localizedDescription)")
                                completion(nil)
                            } else {
                                completion(savedRecord)
                            }
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        } else {
            print("User record ID not found")
            completion(nil)
        }
    }
    
    
    //--------------------------
    //DONE
    func saveHealthInformation(medicalNotes: String, bloodtype: String , alargies: String) {
        // Check if the userRecordID is available
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Convert the userRecordIDString into a CKRecord.ID
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Create a new CKRecord for HealthInformation
        let healthInfoRecord = CKRecord(recordType: "HealthInformation")
        
        // Set the fields for the HealthInformation record
        healthInfoRecord["MedicalNotes"] = medicalNotes /*as NSString*/
        healthInfoRecord["BloodType"] = bloodtype /*as NSString*/
        healthInfoRecord["Allergies"] = alargies.isEmpty ? "لا" : alargies
        /*as NSString*/
        
        // Create a CKRecord.Reference to link this health record to the user's Individual record
        let reference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
        healthInfoRecord["UserID"] = reference
        
        // Save the HealthInformation record to the CloudKit database
        privateDatabase.save(healthInfoRecord) { record, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Handle the error appropriately
                    print("CloudKit Save Error: \(error.localizedDescription)")
                } else {
                    // Health information record was saved successfully
                    // to store the health information recordID if necessary
                    UserDefaults.standard.set(healthInfoRecord.recordID.recordName, forKey: "healthInfoRecord")
                    print("Health information saved successfully for userRecordID: \(userRecordIDString)")
                    
                }
            }
        }
    }
    
    //---------------------
    
    //DONE
    private func showErrorMessage(_ message: String) {
        print("error func showErrorMessage 775line")
    }
    
    //---------------------
    
    //DONE
    func saveSurgeries() {
        
        // Check if the userRecordID is available
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Convert the userRecordIDString into a CKRecord.ID
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        
        for surgery in surgeriesList where !surgery.name.isEmpty && !surgery.year.isEmpty {
            let surgeryRecord = CKRecord(recordType: "PerviousSurgies")
            
            // Set the surgery details
            surgeryRecord["SurgeryName"] = surgery.name
            surgeryRecord["Year"] = surgery.year
            
            // Create a CKRecord.Reference to link this surgery record to the user's Individual record
            let reference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
            surgeryRecord["UserID"] = reference
            
            // Save the surgery record
            privateDatabase.save(surgeryRecord) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        // Handle any errors during save operation
                        print("CloudKit Save Error: \(error.localizedDescription)")
                    } else {
                        // The surgery record was saved successfully
                        UserDefaults.standard.set(surgeryRecord.recordID.recordName, forKey: "surgeryRecord")
                        print("saveSurgeries done")
                    }
                }
            }
        } // End of the for loop
        
        // If there are three surgeries, all three will have the same reference to the 'IndividualPersonalInformation' ensuring they are connected to the same user.
        
    } // End of the saveSurgeries
    
    //---------------------
    
    func saveChroinc() {
        
        // Check if the userRecordID is available
        guard let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") else {
            print("User record ID not found")
            return
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Convert the userRecordIDString into a CKRecord.ID
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        
        // This loop goes through each surgery that the user has entered.
        for chroinc in chronicDiseasesList where !chroinc.name.isEmpty && !chroinc.medication.isEmpty {
            let chroincRecord = CKRecord(recordType: "ChroincDiseses")
            let medicationRecord = CKRecord(recordType: "Medications")
            
            // Set the surgery details
            chroincRecord["DiseseName"] = chroinc.name
            medicationRecord["MedicineName"] = chroinc.medication
            medicationRecord["DoseOfMedication"] = chroinc.dose
            medicationRecord["DoseUnit"] = chroinc.unit.rawValue
            
            // Create a CKRecord.Reference to link this surgery record to the user's Individual record
            let reference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
            chroincRecord["UserID"] = reference
            
            // let medicationreference = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
            medicationRecord["UserID"] = reference
            
            // Save the surgery record
            privateDatabase.save(chroincRecord) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        // Handle any errors during save operation
                        print("CloudKit Save Error: \(error.localizedDescription)")
                    } else {
                        // The surgery record was saved successfully
                        UserDefaults.standard.set(chroincRecord.recordID.recordName, forKey: "chroincRecord")
                        print("chroincRecord was saved ")
                    }
                }
            }
            
            // Save the surgery record
            privateDatabase.save(medicationRecord) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        // Handle any errors during save operation
                        print("CloudKit Save Error: \(error.localizedDescription)")
                    } else {
                        // The surgery record was saved successfully
                        UserDefaults.standard.set(medicationRecord.recordID.recordName, forKey: "medicationRecord")
                        print("medicationRecord was saved ")
                    }
                }
            }
            
            
        } // End of the for loop
        
    } // End of the saveChroinc
    
    
    
    //--------------------- vailation functions here
    
    func validateFields() {
        shouldNavigate = true
        phoneError = ""
        phoneError = ""
        firstPhoneError = ""
        secondPhoneError = ""
        alargiesError = ""
        previousSergiuersError = ""
        medicalNotesError = ""
        chronicDiseasesError = ""
        bloodTypeError = ""
        
        
        
        phoneError = phoneNumber.isEmpty || !validatePhoneNumber(phoneNumber) ? "أدخل رقمًا سعوديًا مكون من  ١٠ أرقام" : ""
        
        
        
        
        
        
        firstPhoneError = firstPhoneNumber.isEmpty || !validatePhoneNumber(firstPhoneNumber) ? "أدخل رقمًا سعوديًا مكون من  ١٠ أرقام" : ""
        
        secondPhoneError = secondPhoneNumber.isEmpty || !validatePhoneNumber(secondPhoneNumber) ? "أدخل رقمًا سعوديًا مكون من  ١٠ أرقام" : ""
        
        
        
        if !firstPhoneNumber.isEmpty && !secondPhoneNumber.isEmpty{
            if (firstPhoneNumber == secondPhoneNumber){
                secondPhoneError = "يرجى عدم تكرار الرقم"
                
            }
            
        }
        
        if !phoneNumber.isEmpty && !secondPhoneNumber.isEmpty{
            if (phoneNumber == secondPhoneNumber){
                secondPhoneError = "يرجى عدم تكرار الرقم"
                
            }
            
        }
        
        if !phoneNumber.isEmpty && !firstPhoneNumber.isEmpty{
            if (phoneNumber == firstPhoneNumber){
                firstPhoneError = "يرجى عدم تكرار الرقم"
                
            }
            
        }
        
        
        if allergySelection == .yes{
            alargiesError = alargies.isEmpty ? "أدخل الحساسية التي تعاني منها" : ""
        }
        
        medicalNotesError = medicalNotes.isEmpty ? "أدخل الحالة والملاحظات الطبية" : ""
        
        handleBloodTypeChange(bloodtype.rawValue)
        
        
        
        if previousSurgerySelection == .yes {
            validateSurgeryYears()
            validateNameOnChange()
            
        }
        
        if chronicDiseasesSelection == .yes{
            validateChronicDiseasesOnChange()
            validatechronicMed()
        }
        
        
        //       Set shouldNavigate to false if there are errors
        if phoneError.isEmpty && firstPhoneError.isEmpty && secondPhoneError.isEmpty && alargiesError.isEmpty && medicalNotesError.isEmpty && bloodTypeError.isEmpty && errorYear.isEmpty  &&  errorMedName.isEmpty {
            shouldNavigate = true
        }
    } //end of the vaild fun
    
    
    func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^05[0-9]{8}$"
        let phoneValidation = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneValidation.evaluate(with: phoneNumber)
    } //end of validatePhoneNumber
    
    func handleBloodTypeChange(_ bloodtype: String) {
        if bloodtype == "غير محدد" {
            bloodTypeError = "يجب عليك تحديد فصيلة الدم"
        } else {
            bloodTypeError = ""
        }
    }
    
    
    
    func validateNameOnChange(){
        errorSurName=""
        if previousSurgerySelection == .yes{
            for surgery in surgeriesList {
                if (surgery.name.isEmpty) {
                    errorSurName = "أدخل اسم العملية"
                }
            }
        }
    }
    
    
    func  validateChronicDiseasesOnChange(){
        errorChroncError=""
        
        if chronicDiseasesSelection == .yes{
            for chronicDisease in chronicDiseasesList {
                if chronicDiseasesSelection == .yes{
                    if (chronicDisease.name.isEmpty)  {
                        
                        errorChroncError = "أدخل المرض"
                    }
                }
            }
        }
    }
    
    
    
    
    func validateFieldsAll() {
        // Resetting error messages for relevant fields
        alargiesError = ""
        
        
        // Validate allergies field
        if allergySelection == .yes{
            if (alargies.isEmpty) {
                alargiesError = "يرجى إدخال الحساسية ."}
        }
    }
    func validateFieldsMed() {
        
        medicalNotesError = ""
        // Validate medical notes field
        if (medicalNotes.isEmpty) {
            medicalNotesError = "يرجى إدخال الملاحظات الطبية ."
        }
        
        
    }
    
    func validateSurgeryYears() {
        // Reset error message at the beginning of validation
        errorYear = ""
        
        // Flag to track if any surgery has a year not selected
        var isAnyYearNotSelected = false
        
        // Check each surgery in the list
        for surgery in surgeriesList {
            if surgery.year.isEmpty || surgery.year == "اختر سنة العملية" {
                isAnyYearNotSelected = true
                break // Exit the loop on the first occurrence
            }
        }
        
        // Set the error message if any surgery year was not selected
        if isAnyYearNotSelected {
            errorYear = "اختر السنة للعملية الجراحية"
        }
    }
    
    
    func validatechronicMed() {
        // Reset error message at the beginning of validation
        errorMedName = ""
        
        // Flag to track if any medication has a year not selected
        var isAnyMwedNEmpty = false
        
        // Check each medication in the list
        for med in chronicDiseasesList {
            if med.medication.isEmpty  {
                isAnyMwedNEmpty = true
                break // Exit the loop on the first occurrence
            }
        }
        
        // Set the error message if any medication was not selected
        if isAnyMwedNEmpty {
            errorMedName = "أدخل اسم الدواء للمرض المزمن"
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
    
    
    
    func retrievePhoneNum() {
        
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
                        
                        DispatchQueue.main.async {
                            self.phoneNumber = record["phoneNumber"] as? String ?? ""

                        }
                        
                        
                    } else {
                        print( "No record found for this National ID")
                    }
                }
            }
        }
    }
        
} // end of struct completeYourHealthPage


#Preview {
    completeYourHealthPage()
}
