import UIKit
import UserNotifications
import CloudKit
import FirebaseCore
import FirebaseMessaging
import Firebase



class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, ObservableObject {
    
    var window: UIWindow?  // Main window for the app
    var sharedViewModel = SharedViewModel()  // Shared view model instance
    static var userIsRegistered = false  // Static variable to track user registration status
    static var pendingFCMToken = "hi rub"
    static let shared = AppDelegate()
    static var watchConnector: WatchConnector?
    let statusTracker = NeedaStatusTracker.shared


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase on app launch
        FirebaseApp.configure()

        // Set up messaging delegate and notification center.
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        AppDelegate.watchConnector =  WatchConnector.shared // to start the session early
        LocationManager.shared.requestLocation()

        return true
    }

    // MARK: - Firebase Messaging and Notifications Setup
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token from system: \(token)")
        
        // Send this system token to Firebase to get the corresponding Firebase token.
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("Token from Firebase: \(token)")
        AppDelegate.pendingFCMToken = token

        if AppDelegate.userIsRegistered {
            updateTokenIfNeeded()
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Message received in foreground: \(userInfo)")
        
        if let needaRecordId = userInfo["needaRecordId"] as? String {
            print("needaRecordId: \(needaRecordId)")
            fetchLocation(for: needaRecordId)
        }
        
        let notificationTitle = notification.request.content.title
        handleNotification(with: notificationTitle)

        // Present the notification as a banner with sound
        completionHandler([[.banner, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("User interacted with notification: \(userInfo)")
        
        if let needaRecordId = userInfo["needaRecordId"] as? String {
            print("needaRecordId: \(needaRecordId)")
        }

        completionHandler()
    }
    
  
    func handleNotification(with title: String) {
        DispatchQueue.main.async {
            switch title {
            case "هناك ممارس صحي متوجه اليك":
                NeedaStatusTracker.shared.status = 1
                NeedaStatusTracker.shared.statusDetails["قبول"] = self.getCurrentTime() // Store only the time
            case "الممارس الصحي متوجه إليك":
                NeedaStatusTracker.shared.status = 2
                NeedaStatusTracker.shared.statusDetails["تحرك"] = self.getCurrentTime() // Store only the time
            case "الممارس الصحي وصل إلى الموقع":
                NeedaStatusTracker.shared.status = 3
                NeedaStatusTracker.shared.statusDetails["وصول"] = self.getCurrentTime() // Store only the time

            case "تم إرسال التقرير الطبي":
                NeedaStatusTracker.shared.reset() // Reset on report submission
            default:
                break
            }
        }
    }

    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss" // Adjust format as needed, e.g., "h:mm a" for 12-hour format
        return formatter.string(from: Date())
    }

    // MARK: - CloudKit and Firebase Token Handling
    func updateTokenIfNeeded() {
        print("Printing token: \(AppDelegate.pendingFCMToken)")
        
        if let userRecordIDString = UserDefaults.standard.string(forKey: "userRecordID") {
            updateTokenInCloudKit(token: AppDelegate.pendingFCMToken, userRecordIDString: userRecordIDString)
        } else {
            print("No user ID")
        }
    }

    func updateTokenInCloudKit(token: String, userRecordIDString: String) {
        print("Updating token in CloudKit: \(token)")
        
        let userRecordID = CKRecord.ID(recordName: userRecordIDString)
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        privateDatabase.fetch(withRecordID: userRecordID) { record, error in
            guard let record = record, error == nil else {
                print("Error fetching user record: \(String(describing: error?.localizedDescription))")
                return
            }

            record["token"] = token
            privateDatabase.save(record) { _, error in
                if let error = error {
                    print("Error saving token to CloudKit: \(error.localizedDescription)")
                } else {
                    print("Token updated in CloudKit successfully.")
                    AppDelegate.userIsRegistered = true
                }
            }
        }
    }

    func fetchLocation(for needaRecordId: String) {
        print("\(self.sharedViewModel.selectedLocations) ddd \(self.sharedViewModel.isActiveStates) dddd \(self.sharedViewModel.needaRecords)")

        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: needaRecordId)
        
        privateDatabase.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                print("Error fetching record with ID \(needaRecordId): \(error.localizedDescription)")
                return
            }
            
            guard let record = record else {
                print("Record not found for ID \(needaRecordId)")
                return
            }

            if let location = record["UserLocation"] as? CLLocation {
                print("Location associated with needaRecordId \(needaRecordId): \(location)")
                
                DispatchQueue.main.async {
                    let identifiableLocation = IdentifiableLocation(id: needaRecordId, location: location)
                    if !self.sharedViewModel.selectedLocations.contains(where: { $0.id == needaRecordId }) {
                        self.sharedViewModel.selectedLocations.append(identifiableLocation)
                        self.sharedViewModel.isActiveStates.append(true)
                        self.sharedViewModel.needaRecords.append(needaRecordId)
                    }
                    print("\(self.sharedViewModel.selectedLocations) ddd \(self.sharedViewModel.isActiveStates) dddd \(self.sharedViewModel.needaRecords)")
                }

            } else {
                print("UserLocation attribute not found or is not a CLLocation")
            }
        }
    }
}
