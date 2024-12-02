//
//  completeyourhealthstructs.swift
//  NeedaApp
//
//  Created by Reham  on 03/09/1445 AH.
//

import SwiftUI
import CloudKit
import CommonCrypto
import HealthKit

// Enum to manage yes/no options
enum YesNoOption: String, CaseIterable {
    case yes = "نعم"
    case no = "لا"
    
}

// Struct to represent surgical interventions with unique identifiers
struct Surgery: Identifiable {
    let id = UUID()
    var name: String
    var year: String
}

// Enum to define units for dosages, supporting multiple units
enum DoseUnit: String, CaseIterable, Identifiable {
    case mg = "ملغ"
    case ml = "ملل"
    case g = "غرام"
    case notSet = "غير محدد"

    var id: String { self.rawValue }
}

// Struct to represent chronic diseases with necessary attributes
struct ChronicDisease: Identifiable {
    let id = UUID()
    var name: String
    var medication: String
    var dose: String
    var unit: DoseUnit
}

// Enum to represent different blood types with the added flexibility of expanding or updating the types
enum BloodType: String, CaseIterable, Identifiable {
    case Apl = "A+"
    case Ami = "A-"
    
    case Bpl = "B+"
    case Bmi = "B-"
    
    case Opl = "O+"
    case Omi = "O-"
    
    case ABpl = "AB+"
    case ABmi = "AB-"
    case notSet = "غير محدد"
    
    var id: String { self.rawValue }
}


extension BloodType {
    static func from(hkBloodType: HKBloodType) -> BloodType {
        switch hkBloodType {
        case .aPositive: return .Apl
        case .aNegative: return .Ami
        case .bPositive: return .Bpl
        case .bNegative: return .Bmi
        case .abPositive: return .ABpl
        case .abNegative: return .ABmi
        case .oPositive: return .Opl
        case .oNegative: return .Omi
        case .notSet: return .notSet // Make sure to handle this case
        @unknown default: return .notSet // Handle potential future values
        }
    }
}

struct LabelTextField: View {
   var label: String
   @Binding var text: String

   var body: some View {
       VStack(alignment: .leading) {
           Text(label)
               .foregroundColor(.gray)
           TextField(label, text: $text)
               .textFieldStyle(RoundedBorderTextFieldStyle())
       }
       .frame(minWidth: 0, maxWidth: .infinity)
   }
}

struct LabelMenuPicker: View {
    var label: String
    @Binding var selection: String
    var options: [String]

    var body: some View {
        Menu {
            Picker(label, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        } label: {
            HStack {
                Text(selection)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity) // Adjust minWidth if needed
            .background(Color.white)
            .cornerRadius(10)
        }
        .fixedSize(horizontal: false, vertical: true) // This ensures the menu tries to present its content without truncation
    }
}
