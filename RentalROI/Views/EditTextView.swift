//
//  EditTextView.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI
import Combine

struct EditTextView: View {
    @EnvironmentObject var rentalProperty: RentalProperty
    
    @Binding var attrToEdit: RoiAttribute
    @Binding var showingEditView: Bool
    private var uom: String {
        switch attrToEdit {
        case .numOfTerms:
            return "yr."
        case .interestRate, .downPayment:
            return "%"
        default:
            return "$"
        }
    }

    private var bindingVaue: Binding<Double> {
        get {
            switch attrToEdit {
            case .purchasePrice:
                return $rentalProperty.purchasePrice
            case .downPayment:
                return Binding(
                    get: {
                        (rentalProperty.purchasePrice - rentalProperty.loanAmt) * 100.0/rentalProperty.purchasePrice
                    },
                    set: { newValue in
                        rentalProperty.loanAmt = rentalProperty.purchasePrice * (1.0 - newValue/100.0)
                    }
                )

            case .loanAmt:
                return $rentalProperty.loanAmt
            case .interestRate:
                return $rentalProperty.interestRate
            case .numOfTerms:
                return Binding(
                    get: { Double(rentalProperty.numOfTerms)},
                    set: { rentalProperty.numOfTerms = Int($0) }
                )
            case .escrow:
                return $rentalProperty.escrow
            case .extra:
                return $rentalProperty.extra
            case .expenses:
                return $rentalProperty.expenses
            case .rent:
                return $rentalProperty.rent
            default:
                return .constant(0.0)
            }
        }
    }
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
//                    Text("\(attrToEdit.name) (\(uom))").padding(20)
                    TextField(attrToEdit.name, value: bindingVaue, formatter: formatter, onEditingChanged: {
                        print("\($0) \(bindingVaue.wrappedValue)")
                    }, onCommit: {
                        showingEditView = false
                    }).multilineTextAlignment(.center)
                    .grayscale(0.50)
                    .keyboardType(.numbersAndPunctuation)
                    .onAppear(perform: {
                    })
                    .textFieldStyle(PlainTextFieldStyle())
                }
                Divider().frame(height:0.5).padding(.horizontal).background(Color("TableSection"))
                
            }.padding()
            
            .navigationBarTitle("\(attrToEdit.name) (\(uom))", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showingEditView = false
            }) {
                Text("Cancel")
            })
        }
    }
}

struct EditTextView_Previews: PreviewProvider {
    @State static var attr: RoiAttribute = RoiAttribute.numOfTerms
    @State static var showingEditView = true
    static var previews: some View {
        Group {
            EditTextView(attrToEdit: $attr, showingEditView: $showingEditView).environmentObject(RentalProperty.sharedInstance()).environment(\.colorScheme, .dark)
            EditTextView(attrToEdit: $attr, showingEditView: $showingEditView).environmentObject(RentalProperty.sharedInstance())
        }
    }
}
