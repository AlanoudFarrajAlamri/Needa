//
//  ContentView.swift
//  NeedaApp
//
//  Created by shouq on 17/08/1445 AH.
//

import SwiftUI
import CoreLocation
import CloudKit

struct ContentView: View {
    
    @State private var showingPatientRegistration = false  // State to track visibility of the patient registration page
    @State private var showingPractitionerRegistration = false  // State to track visibility of the practitioner registration page
    @State private var showingotp = false  // State to track visibility of the OTP page (currently unused)
    @State private var showingmap = false  // State to track visibility of the map (currently unused)
    @State private var showingpractionerLogIn = false
    @State private var showingReportPage = false
    
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var watchConnector: WatchConnector = WatchConnector()
    
    
    var body: some View {
        content
            .onAppear(perform: fetchFirstIndividualRecord)
    }// end of the body
    
    
}


// MARK: - UIVIew Extension
extension ContentView {
    
    @ViewBuilder
    var content: some View {
        
        ZStack {
            Color("backgroundColor")
            .ignoresSafeArea(.all)
            
            loadView
        }
        
            
    }
    
    
    @ViewBuilder
    var loadView: some View {
        VStack (spacing: 40) {
            //logo config
            Image("needa")
                .resizable()
                .frame(width:330, height:400)
            
            Spacer()
            
            
            VStack {
                LongButton(text: "إنشاء حساب مستخدم", action: {
                    self.showingPatientRegistration = true
                })
                .onAppear { // Use onAppear to load the name when the view appears
                    nameValueUpdate()}
                .fullScreenCover(isPresented: $showingPatientRegistration) {
                    patientRegestrationPage()  // Presents the patient registration page when the button is tapped
                }

                // Button for practitioner registration
                LongButton(text: "إنشاء حساب ممارس صحي", action: {
                    self.showingPractitionerRegistration = true
                }).fullScreenCover(isPresented: $showingPractitionerRegistration) {
                    HCPOtp()  // Presents the OTP page for health care practitioners when the button is tapped
                }
            }.padding(.horizontal)
            
            // Button for practitioner registration
            Button(action: {
                self.showingpractionerLogIn = true
            }) {
                Text("تسجيل الدخول")
                    .background(Color("backgroundColor"))
                    .foregroundColor(Color("button"))
                    .padding(.horizontal) //.horizontal
                
                Text("لديك حساب بالفعل؟")
                    .background(Color("backgroundColor"))
                    .foregroundColor(.black)
                    .padding(.horizontal, -14)
                
            }
                .fullScreenCover(isPresented: $showingpractionerLogIn) {
                    PractitionerLogIn()
                }
        }
    }
    
}

// MARK: Custom function Ex
extension ContentView {
    
    func fetchFirstIndividualRecord() {
        let predicate = NSPredicate(value: true)  // Fetches all records, but we limit to one below
        let query = CKQuery(recordType: "Individual", predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1  // Limit the fetched records to just one
        
        operation.recordFetchedBlock = { record in
            // This block is called for each record that is fetched
            DispatchQueue.main.async {
                if let name = record["name"] as? String {
                    print("Fetched Individual Name: \(name)")
                } else {
                    print("Name field not found in the record")
                }
            }
        }
        
        operation.queryCompletionBlock = { cursor, error in
            // This block is called when the operation is complete
            if let error = error {
                print("Failed to fetch Individual record: \(error.localizedDescription)")
            } else {
                print("Successfully fetched the first Individual record")
            }
        }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        privateDatabase.add(operation)
    }
}


// Function to update a value in UserDefaults
public func nameValueUpdate(){
    UserDefaults.standard.set("name", forKey: "myname")
}

// Preview provider for SwiftUI previews in Xcode

#Preview {
    ContentView()
}
