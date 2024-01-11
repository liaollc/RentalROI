//
//  MonthlyTermView.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI

struct MonthlyTermView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State var payment: PaymentScheduleDto

    var body: some View {
//        Text("Hello, World: \(payment.balance0)")
        ScrollView {
            let p = payment
            VStack {
                // first Mortgage Payment Section
                TableSectionView(title: "MORTGAGE PAYMENT")
                
                RightDetailCellView(text: "No. \(p.pmtNo)", detailText: String(format: "$%.2f", p.interest + p.principal))
                RightDetailCellView(text: "principal", detailText: String(format: "$%.2f", p.principal))
                RightDetailCellView(text: "Interest", detailText: String(format: "$%.2f", p.interest))
                RightDetailCellView(text: "Escrow", detailText: String(format: "$%.2f", p.escrow))
                RightDetailCellView(text: "Add'l Payment", detailText: String(format: "$%.2f", p.extra))
                RightDetailCellView(text: "Mortgage Balance", detailText: (p.balance0 - p.principal).toCurrencyString())

            }
            VStack {
                // 2nd Investment Section
                TableSectionView(title: "INVESTMENT")
                RightDetailCellView(text: "Equity", detailText: p.equity(AppViewModel.sharedRentalProperty).toCurrencyString())
                RightDetailCellView(text: "Down Pay & Extra", detailText: p.invested(AppViewModel.sharedRentalProperty).toCurrencyString())
                
                RightDetailCellView(text: "ROI", detailText: String(format: "%.2f%% (%@/mo)", p.roi(AppViewModel.sharedRentalProperty), p.net(AppViewModel.sharedRentalProperty).toCurrencyString()))

                RightDetailCellView(text: "Cash Flow", detailText: String(format: "$%.2f/mo", p.cashFlow(AppViewModel.sharedRentalProperty)))
                
                RightDetailCellView(text: "Rent", detailText: String(format: "$%.2f/mo", viewModel.rent))

                RightDetailCellView(text: "Expense", detailText: String(format: "$%.2f/mo", viewModel.expenses))
            }
        }.navigationTitle("Payment")
    }    
}

struct MonthlyTermView_Previews: PreviewProvider {
    @State static var payment: PaymentScheduleDto = PaymentScheduleDto(
        pmtNo: 1,
        balance0: 12000.0,
        rate: 0.0,
        principal: 120.0,
        interest: 2.5,
        escrow: 0.0,
        extra: 0.0
    )
    
    static var property: RentalProperty {
        let p = RentalProperty.sharedInstance
        p.purchasePrice = 300000.0
        p.rent = 1800.0
        p.expenses = 500.0
        return p
    }
    static var previews: some View {
        MonthlyTermView(payment: payment).environmentObject(AppViewModel())
//            .previewLayout(.fixed(width: 300, height: 70))
    }
}

extension Double {
    func toCurrencyString() -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        return fmt.string(from: NSNumber(value: self)) ?? ""
    }
}
