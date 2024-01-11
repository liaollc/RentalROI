//
//  PaymentScheduleDto.swift
//  RentalROI
//
//  Created by Sean Liao on 1/8/21.
//

import Foundation

struct PaymentScheduleDto: Codable, Identifiable {
    var id: Int {
        return pmtNo
    }

    var pmtNo: Int
    var balance0: Double
    var rate: Double
    var principal: Double
    var interest: Double
    var escrow: Double
    var extra: Double
    
    // convienence ...
    func invested(_ property: RentalProperty) -> Double {
        let invested = property.purchasePrice - property.loanAmt + (property.extra * Double(pmtNo))
        return invested
    }
    func net(_ property: RentalProperty) -> Double {
        let net = property.rent - property.escrow - interest - property.expenses;
        return net
    }
    func cashFlow(_ property: RentalProperty) -> Double {
        let cash = net(property) - principal
        return cash
    }

    func roi(_ property: RentalProperty) -> Double {
        let invested = self.invested(property)
        let net = self.net(property)
        let roi = net * 12 / invested
        
        return roi * 100
    }
    func roc(_ property: RentalProperty) -> Double {
        let invested = self.invested(property)
        let cash = self.cashFlow(property)
        let roc = cash * 12 / invested
        
        return roc * 100
    }
    func equity(_ property: RentalProperty) -> Double {
        let equity = property.purchasePrice - balance0 + principal
        return equity
    }
    func roe(_ property: RentalProperty) -> Double {
        let net = self.net(property)
        let roe = net * 12 / equity(property)
        return roe * 100
    }
    var remainingBalance: Double {
       return balance0 - principal - extra
    }
}
