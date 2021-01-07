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
    
    @Published var purchasePrice = 120.0;
    @Published var loanAmt = 0.0;
    @Published var interestRate = 5.0;
    @Published var numOfTerms = 30;
    @Published var escrow = 0.0;
    @Published var extra = 0.0;
    @Published var expenses = 0.0;
    @Published var rent = 0.0;
    
//    @Published var inputText: String = "xxx"
    
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
        static var _sharedInstance = RentalProperty()
    }
    
    /////////////////////////////////////////////
    
    // private RentalProperty() {
    private init() {
        // Commented Java code ommitted
    }
    
    // public static RentalProperty sharedInstance() {
    class func sharedInstance() -> RentalProperty {
        return MyStatic._sharedInstance
    }
    
    // public String getAmortizationPersistentKey() {
    func getAmortizationPersistentKey() -> String {
        let aKey = String(format: "%.2f-%.3f-%d-%.2f-%.2f", self.loanAmt, self.interestRate, self.numOfTerms, self.escrow, self.extra);
        return aKey;
    }
    
    // public JSONArray getSavedAmortization(Context activity) {
    func getSavedAmortization() -> NSArray? {
        let savedKey = retrieveUserdefault(key: MyStatic.KEY_AMO_SAVED) as! String?
        let aKey = self.getAmortizationPersistentKey()
        if let str = savedKey {
            if(str.utf16.count > 0 && str == aKey) {
                let jo = retrieveUserdefault(key: str) as! NSArray?
                return jo
            }
        }
        return nil
    }
    
    // public boolean saveAmortization(String data, Context activity){
    func saveAmortization(data: NSArray) -> Bool {
        let aKey = self.getAmortizationPersistentKey()
        if saveUserdefault(data: aKey, forKey: MyStatic.KEY_AMO_SAVED) {
            return saveUserdefault(data: data, forKey: aKey)
        } else {
            return false
        }
    }
    
    // public boolean load(Context activity) {
    func load() -> Bool {
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
            return true;
            
        } else {
            return false
        }
    }
    
    // public boolean save(Context activity) {
    func save() -> Bool {
        let jo : [String : Any] = [
            "purchasePrice": purchasePrice,
            "loanAmt" : loanAmt,
            "interestRate" : interestRate,
            "numOfTerms" : Double(numOfTerms),
            "escrow" : escrow,
            "extra" : extra,
            "expenses" : expenses,
            "rent" : rent]
        
        return self.saveUserdefault(data: jo, forKey: MyStatic.KEY_PROPERTY)
    }
    
    /////////// SharedPreferences usage /////////////////
    // public boolean saveSharedPref(String key, String data, Context activity) {
    func saveSharedPref(key:String,data:AnyObject)->Bool{
        // Commented Java code ommitted
        return true
    }
    
    // public String retrieveSharedPref(String key, Context activity) {
    func retrieveSharedPref(key: String) -> AnyObject? {
        // Commented Java code ommitted
        return nil
    }
    
    // public void deleteSharedPref(String key,Context activity) {
    func deleteSharedPref(key: String) {
        // Commented Java code ommitted
    }
    
    // JavaBean accessors
    func getPurchasePrice()-> Double {
        return self.purchasePrice;
    }
    
    func setPurchasePrice(purchasePrice: Double) {
        self.purchasePrice = purchasePrice;
    }
    
    func getLoanAmt()-> Double {
        return self.loanAmt;
    }
    
    func setLoanAmt(loanAmt: Double) {
        self.loanAmt = loanAmt;
    }
    
    func getInterestRate()-> Double {
        return self.interestRate;
    }
    
    func setInterestRate(interestRate: Double) {
        self.interestRate = interestRate;
    }
    
    func getNumOfTerms()-> Int {
        return self.numOfTerms;
    }
    
    func setNumOfTerms(numOfTerms: Int) {
        self.numOfTerms = numOfTerms;
    }
    
    func getEscrow()-> Double {
        return self.escrow;
    }
    
    func setEscrow(_ escrow: Double) {
        self.escrow = escrow;
    }
    
    func getExtra()-> Double {
        return self.extra;
    }
    
    func setExtra(_ extra: Double) {
        self.extra = extra;
    }
    
    func getExpenses()-> Double {
        return self.expenses;
    }
    
    func setExpenses(_ expenses: Double) {
        self.expenses = expenses;
    }
    
    func getRent()-> Double {
        return self.rent;
    }
    
    func setRent(_ rent: Double) {
        self.rent = rent;
    }
    
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
