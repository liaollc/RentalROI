//
//  RentalPropertyView.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI

struct RentalPropertyView: View {
    @EnvironmentObject var rentalProperty: RentalProperty
    
    @State var showingEditView: Bool = false
    @State var attrToEdit: RoiAttribute = RoiAttribute.na
    @State var valueText: Double = 0.0
    
    @State var toAmortizationView: Bool = false
    
    var body: some View {
        let downPaymentBinding = Binding(
            get: {
                (rentalProperty.purchasePrice - rentalProperty.loanAmt) * 100.0/rentalProperty.purchasePrice
            },
            set: { newValue in
                rentalProperty.loanAmt = rentalProperty.purchasePrice * (1.0 - newValue/100.0)
            }
        )
        let numOfTermsBinding = Binding(
            get: { Double(rentalProperty.numOfTerms)},
            set: { rentalProperty.numOfTerms = Int($0) }
        )

        
        NavigationView {
            
            ScrollView {
                VStack {
                    Text("  MORTGAGE")
                        .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .leading)
                        .background(Color("TableSection"))
                        .padding(10)
                    
                    RoiAttributeRow(attribute: RoiAttribute.purchasePrice, value: $rentalProperty.purchasePrice, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    
                    VStack {
                        HStack {
                            Text(RoiAttribute.downPayment.name)
                            Slider(value: downPaymentBinding, in: 0...100, step: 1)
                            Text("\(downPaymentBinding.wrappedValue, specifier: "%.2f")%")
                        }
                        Divider().background(Color("TableSection")).grayscale(0.2)
                    }
                    .padding(8).padding(.leading, 16).padding(.trailing, 16)

                    RoiAttributeRow(attribute: RoiAttribute.loanAmt, value: $rentalProperty.loanAmt, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(prefix: "", postfix: "%", attribute: RoiAttribute.interestRate, value: $rentalProperty.interestRate, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(prefix: "", postfix: " yr.", isInt: true, attribute: RoiAttribute.numOfTerms, value: numOfTermsBinding, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.escrow, value: $rentalProperty.escrow, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.extra, value: $rentalProperty.extra, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                }
                
                VStack {
                    Text("  OPERATIONS")
                        .frame(width: UIScreen.main.bounds.width, height: 60, alignment: .leading)
                        .background(Color("TableSection"))
                        .padding(10).padding(.top, -20)
                    
                    RoiAttributeRow(attribute: RoiAttribute.expenses, value: $rentalProperty.expenses, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.rent, value: $rentalProperty.rent, attrToEdit: $attrToEdit, showingEditView: $showingEditView)

                }.padding(.bottom, 60)

            }
            .navigationBarTitle("Property", displayMode: .automatic)
            .navigationBarItems(trailing: Button(action: {
                toAmortizationView = true
            }, label: {
                Text("Amortization")
            }))
            
            .sheet(isPresented: $showingEditView) {
                EditTextView(attrToEdit: $attrToEdit, showingEditView: $showingEditView)
            }
            
            
        }
    }
}

struct RentalPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        RentalPropertyView().environmentObject(RentalProperty.sharedInstance())
    }
}
