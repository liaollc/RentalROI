//
//  AmortizationView.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI

struct AmortizationListView: View {
    @EnvironmentObject var rentalProperty: RentalProperty    
    @Binding var payments: [PaymentScheduleDto]

    var body: some View {
        List(payments) {payment in
            NavigationLink(
                destination:
                    MonthlyTermView(payment: payment)
            ) {
                PaymentScheduleRow(payment: payment)
            }
        }
        .navigationBarTitle(Text("Amorization"), displayMode: .automatic)
        
    }
    
}

struct AmortizationView_Previews: PreviewProvider {
    @State static var payments: [PaymentScheduleDto] = []
    
    static var previews: some View {
        AmortizationListView(payments: $payments).environmentObject(RentalProperty.sharedInstance)
    }
}
