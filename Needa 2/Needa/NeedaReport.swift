import SwiftUI
import CloudKit

struct NeedaReport: View {
    @State private var number: Int = 0
    @State private var showingHomePage: Bool = false
    @State private var counter: Int = 0
    @State private var goal: Int = 200 // Set a goal for solved cases
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 40) { // Increased spacing between logo and stats
                    // Use Toolbar for navigation
                    Spacer()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    self.showingHomePage = true
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.red)
                                }
                            }
                        }

                    // Logo with smoother layout
                    Image("needa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 240)
                        .padding(.top, -20) // Adjusted padding

                    // Spacer added to push the statistics higher
                    Spacer()

                    // Statistics with increased spacing
                    VStack(spacing: 50) { // Adjusted space between progress ring and counter
                        // Case number with progress ring
                        VStack(spacing: 30) {
                            Text("عدد الحالات المستفيدة:")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            // Progress Ring
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 20)
                                    .opacity(0.3)
                                    .foregroundColor(.gray)
                                
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(min(Double(number) / Double(goal), 1.0)))
                                    .stroke(LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom), style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                                    .rotationEffect(Angle(degrees: 270.0))
                                    .animation(.easeInOut, value: number)
                                
                                Text("\(number)")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.red)
                            }
                            .frame(width: 150, height: 150)
                        }

                        // Health practitioners counter
                        VStack(spacing: 8) {
                            Text("عدد الممارسين الصحيين:")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("\(counter)")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.red)
                                
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.bottom, 100) // Increased padding to push everything upwards
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .fullScreenCover(isPresented: $showingHomePage) {
                NeedaHomePage()
            }
        }
        .onAppear {
            fetchAcceptedRecordsCount()
            countHealthPractitioners { count in
                self.counter = count
                print("Counter updated with \(count) healthcare practitioners.")
            }
        }
    }
    private func fetchAcceptedRecordsCount() {
           countAcceptedRecords { count, error in
               DispatchQueue.main.async {
                   if let count = count {
                       self.number = count
                   } else {
                       print("Error counting accepted records: \(error?.localizedDescription ?? "Unknown error")")
                   }
               }
           }
       }

    private func countHealthPractitioners(completion: @escaping (Int) -> Void) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase
        
        let recordType = "Individual"
        let predicate = NSPredicate(format: "UserType == %@", "healthcarePractitioner")
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch healthcare practitioners: \(error.localizedDescription)")
                    completion(0)
                    return
                }
                
                guard let records = records else {
                    print("No healthcare practitioners found.")
                    completion(0)
                    return
                }
                
                let count = records.count
                print("Number of healthcare practitioners: \(count)")
                
                withAnimation(.easeInOut) {
                    self.counter = count
                }
                
                completion(count)
            }
        }
    }
    
    func countAcceptedRecords(completion: @escaping (Int?, Error?) -> Void) {
        let container = CKContainer(identifier: "iCloud.NeedaDB")
        let privateDatabase = container.privateCloudDatabase

        // Create a predicate to find records where "HCPResponse" is equal to "accepted"
        let predicate = NSPredicate(format: "NeedaStatus == %@", "4")

        // Create a query using the "NeedaCall" record type and the predicate
        let query = CKQuery(recordType: "NeedaCall", predicate: predicate)

        // Perform the query on the private database
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                // Handle error case
                print("Error fetching records: \(error.localizedDescription)")
                completion(nil, error)
            } else if let records = records {
                // Count the number of records with "accepted" status
                let count = records.count
                print("Number of records with HCPResponse = 'accepted': \(count)")
                number=count
                completion(count, nil)
            } else {
                // No records found
                print("No records found")
                completion(0, nil)
            }
        }
    }

}

#Preview {
    NeedaReport()
}
