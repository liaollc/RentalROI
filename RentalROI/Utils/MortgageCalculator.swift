//
//  MortgageCalculator.swift
//  RentalROI
//
//  Created by Sean Liao on 1/10/21.
//

import Foundation

struct MortgageCalculator {
    let mortgage: RentalProperty = {
        return RentalProperty.sharedInstance
    }()
    static let sharedInstance: MortgageCalculator = {
        let instance = MortgageCalculator()
        // setup code
        return instance
    }()
    
    func calcPayments() -> [PaymentScheduleDto] {
        var mt: PaymentScheduleDto!
        let n = self.mortgage.numOfTerms * 12
        var balance = self.mortgage.loanAmt
        
        var paymentTerms: [PaymentScheduleDto] = []
        for i in 0...n {
            mt = newMonthlyTermLoan(balance: balance, term: n-i, rate: self.mortgage.interestRate, escrow: self.mortgage.escrow, extra: self.mortgage.extra);
            paymentTerms.append(mt) //.add(mt);
            balance = mt.remainingBalance
            if(balance <= 0) {
                break;
            }
        }
        return paymentTerms
    }
    
    private func newMonthlyTermLoan(balance: Double, term: Int, rate: Double, escrow: Double, extra: Double) -> PaymentScheduleDto {
        //      NSLog(@">>>newPaymentScheduleDtoLoan");
        //L = loan,
        //N = number of months for repayment, starting at end of first month,
        //R = percentage interest rate per year, (take r/12 as monthly rate).
        //Payment = amount of repayment per month (starting at end of first month).
        //Principle = amount of principle per month (starting at end of first month).
        //Interest = amount of interest per month (starting at end of first month).
        
        // P = L * R * (1+R/1200)^N/[1200{(1+R/1200)^N - 1}]
        
        let f = 1 + rate / 1200;
        let d = pow(M_E, Double(term)*log(f)) // Math.exp(term* Math.log(f)); // (1+R/1200)^N
        let principleAndInterest = balance * rate * d / (1200.0 * (d-1.0));
        let interest = balance * rate / 1200.0;
        let principle = principleAndInterest - interest;
        
        let totalPaymentToPrinciple = principle + extra;
        
        var mp: Double = 0
        var me: Double = 0
        if (totalPaymentToPrinciple < balance) {
            mp = principle;
            me = extra;
        }else {
            mp = balance;
        }
        
        let pmtNo = self.mortgage.numOfTerms * 12 - term + 1;
        let m = PaymentScheduleDto(
            pmtNo: pmtNo,
            balance0: balance,
            rate: rate,
            principal: mp,
            interest: interest,
            escrow: escrow,
            extra: me
        )

        return m;
    }
}

