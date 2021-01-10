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
    @State var showProgressBar: Bool = false
    
    @State var payments: [PaymentScheduleDto] = []
    @State var useApi = false
    
    init() {
    }
    
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
                if showProgressBar {
                    ProgressView().padding()
                }
                
                VStack {
                    TableSectionView(title: "MORTGAGE")
                    RoiAttributeRow(attribute: RoiAttribute.purchasePrice, value: $rentalProperty.purchasePrice, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    
                    VStack(alignment: .leading) {
                        Text(RoiAttribute.downPayment.name).multilineTextAlignment(.leading) //.background(Color.pink)
                        HStack {
                            Slider(value: downPaymentBinding, in: 0...100, step: 1)
                            Spacer()
                            Text("\(downPaymentBinding.wrappedValue, specifier: "%.0f")%")
                                .foregroundColor(.blue)
                                .gesture(TapGesture().onEnded({ isOk in
                                    showingEditView = true
                                    attrToEdit = RoiAttribute.downPayment
                                }))
                            Button(action: {
                                showingEditView = true
                                attrToEdit = RoiAttribute.downPayment
                            }, label: {
                                Image(systemName: "pencil") // chevron.right
                            })
                            
                        }.padding(.top, -8)
                        Divider().frame(height:0.5).background(Color("TableSection"))
                    }
                    .padding(.top, 0).padding(.leading, 16).padding(.trailing, 16).padding(.bottom, 0)
                    
                    RoiAttributeRow(attribute: RoiAttribute.loanAmt, value: $rentalProperty.loanAmt, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(prefix: "", postfix: "%%", attribute: RoiAttribute.interestRate, value: $rentalProperty.interestRate, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(prefix: "", postfix: " yr.", isInt: true, attribute: RoiAttribute.numOfTerms, value: numOfTermsBinding, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.escrow, value: $rentalProperty.escrow, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.extra, value: $rentalProperty.extra, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                }
                
                VStack {
                    TableSectionView(title: "OPERATIONS")
                    RoiAttributeRow(attribute: RoiAttribute.expenses, value: $rentalProperty.expenses, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.rent, value: $rentalProperty.rent, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    
                }.padding(.bottom, 60)
                
                // a hidden to NavigationLink just for navigating to next screen.
                NavigationLink(
                    destination: AmortizationListView(payments: $payments),
                    isActive: $toAmortizationView,
                    label: {
                        Text("workaround")
                    }).hidden()
                
                Toggle(isOn: $useApi) {
                    Text("Server computation (internet required)").font(.footnote)
                }.padding()
            }
            .navigationBarTitle("Property", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                rentalProperty.save()
                
                if let p = rentalProperty.getSavedAmortization() {
                    payments = p
                    toAmortizationView = true
                } else {
                    let request = GetAmortizationRequest(
                        amount: rentalProperty.loanAmt,
                        rate: rentalProperty.interestRate,
                        terms: rentalProperty.numOfTerms,
                        escrow: rentalProperty.escrow,
                        extra: rentalProperty.extra)
                    
                    if useApi {
                        showProgressBar = true
                        RestHelper.getAmortization(request) { (dto, data) in
                            showProgressBar = false
                            if let p = dto {
                                payments = p
                                rentalProperty.saveAmortization(p)
                                toAmortizationView = true
                            } else {
                                // error ?
                            }
                        } errorUiHandler: { (data, resp, error) in
                            showProgressBar = false
                        }
                    } else {
                        let p = MortgageCalculator.sharedInstance.calcPayments()
                        payments = p
                        rentalProperty.saveAmortization(p)
                        toAmortizationView = true
                    }
                }
            }, label: {
                Text("Schedule")
            }))
            .sheet(isPresented: $showingEditView) {
                EditTextView(attrToEdit: $attrToEdit, showingEditView: $showingEditView)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RentalPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RentalPropertyView().environmentObject(RentalProperty.sharedInstance).environment(\.colorScheme, .light)
            RentalPropertyView().environmentObject(RentalProperty.sharedInstance).environment(\.colorScheme, .dark)
        }
    }
}
