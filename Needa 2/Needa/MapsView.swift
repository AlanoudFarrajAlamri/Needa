import SwiftUI  // Import SwiftUI for building UI components
import CloudKit  // Import CloudKit for interacting with iCloud
import MapKit  // Import MapKit for map functionalities
import CoreLocation  // Import CoreLocation for location services

struct IdentifiableLocation: Identifiable, Hashable {
    let id: String  // Unique identifier for the location
    let location: CLLocation  // Object representing the geographical location
    
    // Equatable protocol conformance to compare locations
    static func == (lhs: IdentifiableLocation, rhs: IdentifiableLocation) -> Bool {
        return lhs.id == rhs.id && lhs.location.coordinate.latitude == rhs.location.coordinate.latitude && lhs.location.coordinate.longitude == rhs.location.coordinate.longitude
    }
    
    // Hash function to enable hashing of the object, used in collections like sets
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(location.coordinate.latitude)
        hasher.combine(location.coordinate.longitude)
    }
}




struct MapsView: View {
    @StateObject private var locationManager = LocationManager.shared  // Shared location manager instance
    @State private var trackingMode: MapUserTrackingMode = .follow  // Tracking mode for the map
    @State private var navigateToCallerInformation = false  // State to control navigation to CallerInformation
    @State private var navigateToPatientInformation = false  // State to control navigation to PatientInformation
    @State private var operationDetails: [String] = []  // State variable to hold operation follow-up information
    @State private var hasLocationChanged = false  // To track if location has already changed
    
    @State private var hasArrived = false // Track if the "لقد وصلت" button is pressed

    @State private var areButtonsEnabled = false
    @State private var showAlert = false

    var location: IdentifiableLocation  // A single identifiable location
    @EnvironmentObject var viewModel: SharedViewModel  // Shared view model for app state
    
    @State private var isSectionVisible = true  // Track whether the section is visible

    var body: some View {
        NavigationView {  // Container for managing view navigation
            ZStack(alignment: .top) {  // Overlay multiple views on top of each other
                VStack {  // Vertical stack for arranging views vertically
                    // MapView that binds to the locationManager's region and trackingMode
                    MapView(region: $locationManager.region, trackingMode: $trackingMode, location: location)
                        .navigationBarTitle("خريطة نداء", displayMode: .inline)  // Set navigation bar title
                }
                .onAppear {  // Perform actions when the view appears
                    print("Requesting location update...")
                    locationManager.requestLocation()  // Request location update on appear
                    checkNeedaRecordStatus()  // Call the method to check NeedaStatus
                    monitorLocationChanges()  // Start monitoring for location changes
                }
                
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
                            Text(isSectionVisible ? "إخفاء العملية" : "إظهار العملية")
                                .font(.body)
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.top)

                    if isSectionVisible {  // Show this section only when isSectionVisible is true
                        HStack(spacing: 20) {  // Horizontal stack for action buttons, with spacing
                            NavigationLink(destination: ReportView(), isActive: $navigateToCallerInformation) {
                                EmptyView()  // Placeholder for navigation link to CallerInformation
                            }
                            NavigationLink(destination: CallerInformation(), isActive: $navigateToPatientInformation) {
                                EmptyView()  // Placeholder for navigation link to PatientInformation
                            }
                            
                            ActionButton(title: "كتابة تقرير", systemImage: "note.text.badge.plus") {
                                // Set the state to navigate to CallerInformation
                                navigateToCallerInformation = true
                            }
                            .disabled(!areButtonsEnabled) // Disable if areButtonsEnabled is false
                            .opacity(areButtonsEnabled ? 1.0 : 0.5) // Adjust opacity to indicate disabled state
                            
                            ActionButton(title: "معلومات المريض", systemImage: "heart.text.square") {
                                // Set the state to navigate to PatientInformation
                                navigateToPatientInformation = true
                            }
                            .disabled(!areButtonsEnabled) // Disable if areButtonsEnabled is false
                            .opacity(areButtonsEnabled ? 1.0 : 0.5) // Adjust opacity to indicate disabled state
                        }
                        .padding(.top)  // Add top padding to the horizontal stack
                        
                        if !hasArrived && operationDetails.contains(where: { $0.contains("تحرك") }) {
                            Button(action: validateArrivalAndHandle) {
                                Text("لقد وصلت")
                                    .font(.title2)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("تنبيه"),
                                    message: Text("لم تصل الموقع بعد، حاول مجددا."),
                                    dismissButton: .default(Text("حسناً"))
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {  // Vertical stack for operation follow-up information
                            Text("متابعة العملية")  // Title text
                                .font(.title2)  // Set font size
                                .bold()  // Make text bold
                                .multilineTextAlignment(.trailing) // Align text to the right
                                .frame(maxWidth: .infinity, alignment: .trailing) // Right align in the container
                            VStack(alignment: .leading, spacing: 8) {  // Vertical stack for event details
                                ForEach(operationDetails, id: \.self) { info in  // Loop through event details
                                    HStack {  // Horizontal stack for each event detail
                                        Text(info.components(separatedBy: " ")[0])  // Extract and display time
                                            .bold()  // Make text bold
                                        Spacer()  // Add flexible space
                                        Text(info.components(separatedBy: " ")[1])  // Extract and display status
                                    }
                                    .padding(.vertical, 5)  // Add vertical padding to each event detail
                                }
                            }
                            .padding()  // Add padding around the event details
                            .background(Color.white)  // Set background color to white
                            .cornerRadius(15)  // Round the corners of the event detail box
                            .shadow(radius: 5)  // Add shadow to the event detail box
                        }
                        .padding()  // Add padding around the operation follow-up section
                    }
                }

                .padding()  // Add padding around the entire information section
                .background(Color.white)  // Set background color to white
                .cornerRadius(15)  // Round the corners of the information section
                .shadow(radius: 5)  // Add shadow to the information section
                .padding(.horizontal)  // Add horizontal padding to the information section
            }
        }
    }
    
    // Function to check the Needa record status
    private func checkNeedaRecordStatus() {
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
                    // Get the NeedaStatus value
                    let needaStatus = record["NeedaStatus"] as? String ?? ""
                    print("Fetched NeedaStatus: \(needaStatus)")
                    
                    // Initialize an empty array to store status updates
                    var details: [String] = []
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm:ss"
                    
                    // Check for acceptance time
                    if let acceptanceTime = record["acceptanceTime"] as? Date {
                        let formattedTime = dateFormatter.string(from: acceptanceTime)
                        details.append("\(formattedTime) قبول")
                    }
                    
                    // Check for movement status
                    if needaStatus == "2" || needaStatus == "3" {
                        if let movementTime = record["movementTime"] as? Date {
                            let formattedTime = dateFormatter.string(from: movementTime)
                            details.append("\(formattedTime) تحرك")
                        }
                    }
                    
                    // Check for arrival status
                    if needaStatus == "3" {
                        if let arrivalTime = record["arrivalTime"] as? Date {
                            let formattedTime = dateFormatter.string(from: arrivalTime)
                            details.append("\(formattedTime) وصول الموقع")
                        }
                    }
                    
                    // Update the operationDetails state variable
                    self.operationDetails = details
                } else {
                    print("Error fetching the record: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    
    // Function to monitor location changes
   private func monitorLocationChanges() {
        guard let initialLocation = GlobalLocationManager.shared.acceptedLocation else {
            print("Accepted location not set")
            return
        }
        
       guard let userRecordIDString = viewModel.needaRecords.first else {
              print("User record ID not found")
              return
          }
        
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the existing record to check NeedaStatus
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let record = record, error == nil {
                let needaStatus = record["NeedaStatus"] as? String ?? ""
                print("Current NeedaStatus: \(needaStatus)")
                
                // Only monitor location changes if NeedaStatus is 1
                if needaStatus == "1" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {  // Recursive check every 2 seconds
                        guard let currentLocation = locationManager.userLocation else {
                            print("User location not available for monitoring")
                            return
                        }
                        
                        // Check if the location has changed significantly
                        if currentLocation.distance(from: initialLocation) > 1, !hasLocationChanged {
                            let changeTime = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm:ss"
                            let formattedTime = dateFormatter.string(from: changeTime)
                            
                            // Update the operation details with the new event
                            operationDetails.append("\(formattedTime) تحرك")
                            print("Location changed at: \(formattedTime)")
                            
                            // Update NeedaStatus in the database to "2"
                            updateNeedaStatusToMoved()
                            // Set a flag to stop recursion or further checks
                            hasLocationChanged = true
                        } else {
                            // Continue monitoring if location hasn't changed
                            self.monitorLocationChanges()
                        }
                    }
                } else {
                    print("Movement tracking skipped because NeedaStatus is \(needaStatus)")
                }
            } else {
                print("Error fetching the record to check NeedaStatus: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    
    // Function to update NeedaStatus in the database to "2"
    private func updateNeedaStatusToMoved() {
        guard let userRecordIDString = viewModel.needaRecords.first else {
               print("User record ID not found")
               return
           }
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)
        
        // Fetch the existing record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let record = record, error == nil {
                // Update the NeedaStatus field
                record["NeedaStatus"] = "2" as CKRecordValue
                record["movementTime"] = Date() as CKRecordValue
                // Save the updated record
                privateDatabase.save(record) { _, saveError in
                    if let saveError = saveError {
                        print("Error updating NeedaStatus: \(saveError.localizedDescription)")
                    } else {
                        print("NeedaStatus updated to '2'")
                        self.sendNotificationToUserAfterStatusUpdate(recordID: recordID)
                        
                    }
                }
            } else {
                print("Error fetching the record to update NeedaStatus: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    private func sendNotificationToUserAfterStatusUpdate(recordID: CKRecord.ID) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        // Fetch the associated user record to get the token
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let record = record, let userReference = record["UserID"] as? CKRecord.Reference {
                let userRecordID = userReference.recordID
                
                // Fetch the token from the user record
                privateDatabase.fetch(withRecordID: userRecordID) { userRecord, userError in
                    if let userRecord = userRecord, let token = userRecord["token"] as? String {
                        // Send the notification
                        FirebaseManager.shared.sendNotification(
                            token: token,
                            needaRecordId: recordID.recordName,
                            title: "الممارس الصحي متوجه إليك",
                            body: "تحرك الممارس الصحي وهو في الطريق متجه إليك"
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
    
    
     private func validateArrivalAndHandle() {
       
         guard let userRecordIDString = viewModel.needaRecords.first else {
                print("User record ID not found")
                return
            }

        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)

        // Fetch the existing record to check NeedaStatus
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            DispatchQueue.main.async {
                if let record = record, error == nil {
                    let needaStatus = record["NeedaStatus"] as? String ?? ""
                    print("Current NeedaStatus: \(needaStatus)")

                    // Proceed with arrival handling only if NeedaStatus is "2"
                    //||  needaStatus == "3"
                    if needaStatus == "2"  {
                        self.checkProximityAndHandleArrival()
                    } else {
                        print("Arrival handling skipped because NeedaStatus is \(needaStatus)")
                    }
                } else {
                    print("Error fetching the record to check NeedaStatus: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

//    private func checkProximityAndHandleArrival() {
//        guard let currentLocation = locationManager.userLocation else {
//            print("User location is not available.")
//            return
//        }
//
//        // Calculate distance from the target location
//        let distanceToTarget = currentLocation.distance(from: location.location)
//        print("Distance to target: \(distanceToTarget) meters")
//
//        if distanceToTarget <= 5{
//            // Within 5 meters, allow arrival
//            handleArrival()
//        } else {
//            // Notify the user they are not at the location
//            showAlert = true  // Trigger the alert
//        }
//    }
    private func checkProximityAndHandleArrival() {
        guard let currentLocation = locationManager.userLocation else {
            print("User location is not available.")
            return
        }

        let distanceToTarget = currentLocation.distance(from: location.location)
        let accuracy = currentLocation.horizontalAccuracy
        print("Distance to target: \(distanceToTarget) meters, with accuracy: \(accuracy) meters")

        // Adjust threshold based on accuracy
        let threshold = max(5, accuracy)

        if distanceToTarget <= threshold {
            handleArrival()
        } else {
            // Provide feedback based on the distance and accuracy
            showAlert = true  // Trigger the alert
        }
    }
    
    private func handleArrival() {
        // 1. Update operationDetails
        let arrivalTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let formattedTime = dateFormatter.string(from: arrivalTime)
        operationDetails.append("\(formattedTime) وصول الموقع")

        // 2. Send Notification for Arrival
        sendArrivalNotification()

        // 3. Update NeedaStatus in CloudKit to "3"
        updateNeedaStatusToArrived()

        // Mark that the user has arrived to stop showing the button
        hasArrived = true
        areButtonsEnabled = true
    }

    
    
    private func sendArrivalNotification() {
        guard let userRecordIDString = viewModel.needaRecords.first else {
               print("User record ID not found")
               return
           }

        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)

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
                            title: "الممارس الصحي وصل إلى الموقع",
                            body: "وصل الممارس الصحي إلى موقع المريض"
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

    
    
    private func updateNeedaStatusToArrived() {
        guard let userRecordIDString = viewModel.needaRecords.first else {
               print("User record ID not found")
               return
           }

        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: userRecordIDString)

        // Fetch the existing record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let record = record, error == nil {
                // Update the NeedaStatus field
                record["NeedaStatus"] = "3" as CKRecordValue
                record["arrivalTime"] = Date() as CKRecordValue


                // Save the updated record
                privateDatabase.save(record) { _, saveError in
                    if let saveError = saveError {
                        print("Error updating NeedaStatus to '3': \(saveError.localizedDescription)")
                    } else {
                        print("NeedaStatus updated to '3' (Arrived)")
                    }
                }
            } else {
                print("Error fetching the record to update NeedaStatus: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

}
struct ActionButton: View {
    let title: String  // Title of the button
    let systemImage: String  // System image name for the button icon
    let action: () -> Void  // Action to perform when the button is pressed
    
    var body: some View {
        Button(action: action) {  // Button with the specified action
            VStack {  // Vertical stack for icon and title
                Image(systemName: systemImage)  // Display system image
                    .font(.title)  // Set image font size
                    .foregroundColor(.white)  // Set image color to white
                Text(title)  // Display button title
                    .font(.caption)  // Set font size for the title
                    .foregroundColor(.white)  // Set text color to white
            }
            .padding()  // Add padding around the button content
            .background(Color("button"))  // Set background color to red
            .cornerRadius(10)  // Round the corners of the button
        }
    }
}

struct MapView: View {
    @Binding var region: MKCoordinateRegion  // Binding to the map region state
    @Binding var trackingMode: MapUserTrackingMode  // Binding to the tracking mode state
    var location: IdentifiableLocation  // A single identifiable location
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $trackingMode, annotationItems: [location]) { location in  // Display a map with user location and annotation
            MapPin(coordinate: location.location.coordinate)  // Pin at the specified location
        }
    }
}



