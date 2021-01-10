//
//  RentalProperty.swift
//  RentalROI
//
//  Created by Sean on 9/29/14.
//  Copyright (c) 2014 PdaChoice. All rights reserved.
//

import Foundation

// view model should be seperated from domain model
public class RentalProperty: ObservableObject {
    
    static let sharedInstance: RentalProperty = {
        let instance = RentalProperty()
        // setup code
        return instance
    }()

    
    @Published var purchasePrice: Double = 200000.0;
    @Published var loanAmt = 160000.0;
    @Published var interestRate = 5.0;
    @Published var numOfTerms = 30;
    @Published var escrow = 0.0;
    @Published var extra = 0.0;
    @Published var expenses = 0.0;
    @Published var rent = 0.0;
    
    var textNumOfTerms: String {
        get {
            return String(format: "%d", numOfTerms)
        }
        
        set {
            numOfTerms = Int(newValue) ?? 0
        }
    }
    
    
    struct MyStatic {
        static let KEY_AMO_SAVED = "KEY_AMO_SAVED";
        static let KEY_PROPERTY = "KEY_PROPERTY";
        private static let PREFS_NAME = "MyPrefs";
        private static let MODE = 0; // probably Android thing
//        static var _sharedInstance = RentalProperty()
    }
    
    /////////////////////////////////////////////
    
    private init() {
        // Commented Java code ommitted
    }
    
//    class func sharedInstance() -> RentalProperty {
//        return MyStatic._sharedInstance
//    }
    
    func getAmortizationPersistentKey() -> String {
        let aKey = String(format: "%.2f-%.3f-%d-%.2f-%.2f", self.loanAmt, self.interestRate, self.numOfTerms, self.escrow, self.extra);
        return aKey;
    }
    
    func getSavedAmortization() -> [PaymentScheduleDto]? {
        let savedKey: String? = retrieveUserdefault(key: MyStatic.KEY_AMO_SAVED) as? String
        let aKey = self.getAmortizationPersistentKey()
        if let str = savedKey {
            if(str.count > 0 && str == aKey) {
                let data: Data? = retrieveUserdefault(key: str) as? Data
                if let data = data {
                    if let jo = try? JSONDecoder().decode([PaymentScheduleDto].self, from: data) {
                        return jo
                    }
                }
            }
        }
        return nil
    }
    
    func saveAmortization<T:Encodable>(_ object: [T]) {
        let aKey = self.getAmortizationPersistentKey()
        if saveUserdefault(data: aKey, forKey: MyStatic.KEY_AMO_SAVED) {
            if let data = try? JSONEncoder().encode(object) {
                _ = saveUserdefault(data: data, forKey: aKey)
            }
        }
    }
    
    // public boolean load(Context activity) {
    func load() {
        let data = retrieveUserdefault(key: MyStatic.KEY_PROPERTY) as! NSDictionary?
        if let jo = data {
            self.purchasePrice = jo["purchasePrice"] as! Double
            self.loanAmt = jo["loanAmt"] as! Double
            self.interestRate = jo["interestRate"] as! Double
            self.numOfTerms = jo["numOfTerms"]  as! Int
            self.escrow = jo["escrow"] as! Double
            self.extra = jo["extra"] as! Double
            self.expenses = jo["expenses"] as! Double
            self.rent = jo["rent"] as! Double
        }
    }
    
    // public boolean save(Context activity) {
    func save() {
        let jo : [String : Any] = [
            "purchasePrice": purchasePrice,
            "loanAmt" : loanAmt,
            "interestRate" : interestRate,
            "numOfTerms" : Double(numOfTerms),
            "escrow" : escrow,
            "extra" : extra,
            "expenses" : expenses,
            "rent" : rent]
        
        _ = self.saveUserdefault(data: jo, forKey: MyStatic.KEY_PROPERTY)
    }
    
    /////////// SharedPreferences usage /////////////////
    let userDefaults = UserDefaults.standard
    func saveUserdefault(data:Any, forKey:String) -> Bool{
        userDefaults.set(data, forKey: forKey)
        return userDefaults.synchronize()
    }
    
    func retrieveUserdefault(key: String) -> Any? {
        let obj = userDefaults.object(forKey: key)
        return obj
    }
    
    func deleteUserDefault(key: String) {
        self.userDefaults.removeObject(forKey: key)
    }
}


enum RoiAttribute: Identifiable {
    var id: UUID {
        get {
            return UUID() //.uuidString
        }
    }
    
    case purchasePrice
    case downPayment
    case loanAmt
    case interestRate
    case numOfTerms
    case escrow
    case extra
    case expenses
    case rent
    case na
    
    var name: String {
        let str: String!
        switch self {
        case .purchasePrice:
            str = "Purchase Price"
        case .downPayment:
            str = "Down Payment"
        case .loanAmt:
            str = "Loan Amount"
        case .interestRate:
            str = "Interest Rate"
        case .numOfTerms:
            str = "Mortgate Term"
        case .escrow:
            str = "Escrow Amount"
        case .extra:
            str = "Extra Payment"
        case .expenses:
            str = "Expenses"
        case .rent:
            str = "Rent income"
        case .na:
            str = "N/A"
        }
        return str
    }
}
