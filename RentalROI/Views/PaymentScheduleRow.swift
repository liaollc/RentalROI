//
//  PaymentScheduleRow.swift
//  RentalROI
//
//  Created by Sean Liao on 1/7/21.
//

import SwiftUI

struct PaymentScheduleRow: View {
    @EnvironmentObject var rentalProperty: RentalProperty
    @State var payment: PaymentScheduleDto
    
    var body: some View {
        HStack {
            Text("\(payment.pmtNo)").font(.headline)
            VStack {
                HStack {
                    Text("\(payment.balance0, specifier: "$%.2f")").font(.headline)
                    Spacer()
                    Text("ROI: \(roi, specifier: "%.2f")%").font(.headline)
                }
                HStack {
                    Text("Interest: \(payment.interest, specifier: "$%.2f")").font(.subheadline)
                    Spacer()
                    Text("Principal: \(payment.principal, specifier: "$%.2f")").font(.subheadline)
                }.foregroundColor(.secondary)
            }.padding(.leading, 8)
        }
        
    }
    
    private var roi: Double {
        let property = rentalProperty
        let invested = property.purchasePrice - property.loanAmt + (property.extra * Double(payment.pmtNo))
        let net = property.rent - property.escrow - payment.interest - property.expenses;
        let roi = net * 12 / invested
        
        return roi * 100
    }
}

struct PaymentScheduleRow_Previews: PreviewProvider {
    @State static var payment: PaymentScheduleDto = PaymentScheduleDto(
        pmtNo: 1,
        balance0: 12000.0,
        rate: 0.0,
        principal: 0.0,
        interest: 0.0,
        escrow: 0.0,
        extra: 0.0
    )
    static var previews: some View {
        PaymentScheduleRow(payment: payment).environmentObject(RentalProperty.sharedInstance)
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
