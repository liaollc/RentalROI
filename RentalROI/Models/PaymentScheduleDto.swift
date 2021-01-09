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
    
    //"pmtNo":1,
    //"balance0":8000.0,
    //"rate":5.0,
    //"principal":29.93015680599037,
    //"interest":33.333333333333336,
    //"escrow":100.0,
    //"extra":300.0

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
    func roi(_ property: RentalProperty) -> Double {
        let invested = self.invested(property)
        let net = self.net(property)
        let roi = net * 12 / invested
        
        return roi * 100
    }
    func equity(_ property: RentalProperty) -> Double {
        let equity = property.purchasePrice - balance0
        return equity
    }

//    override func viewDidLoad() {
//      super.viewDidLoad()
//      let principal = self.monthlyTerm["principal"] as! Double
//      let interest = self.monthlyTerm["interest"] as! Double
//      let escrow = self.monthlyTerm["escrow"] as! Double
//      let extra = self.monthlyTerm["extra"] as! Double
//      let balance = (self.monthlyTerm["balance0"] as! Double) - principal
//      let paymentPeriod = self.monthlyTerm["pmtNo"] as! Int
//      let totalPmt = principal + interest + escrow + extra
//      self.mTotalPmt.text = String(format: "$%.2f", totalPmt)
//      self.mPaymentNo.text = String(format: "No. %d", paymentPeriod)
//      self.mPrincipal.text = String(format: "$%.2f", principal)
//      self.mInterest.text = String(format: "$%.2f", interest)
//      self.mEscrow.text = String(format: "$%.2f", escrow)
//      self.mAddlPmt.text = String(format: "$%.2f", extra)
//      self.mBalance.text = String(format: "$%.2f", balance)
//
//      let property = RentalProperty.sharedInstance();
//      let invested = property.getPurchasePrice() - property.getLoanAmt() + (property.getExtra() * Double(paymentPeriod))
//      let net = property.getRent() - escrow - interest - property.getExpenses();
//      let roi = net * 12 / invested
//
//      self.mEquity.text = String(format: "$%.2f", property.getPurchasePrice() - balance)
//      self.mCashInvested.text = String(format: "$%.2f", invested)
//      self.mRoi.text = String(format: "%.2f%% ($%.2f/mo)", roi * 100, net)
//    }
}
