//
//  viewModelView.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI

public class RentalPropertyViewModel: ObservableObject {
    

}


struct RentalPropertyView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State var showingEditView: Bool = false
    @State var attrToEdit: RoiAttribute = RoiAttribute.na
    @State var valueText: Double = 0.0
    
    @State var toAmortizationView: Bool = false
    @State var showProgressBar: Bool = false
    
    @State var payments: [PaymentScheduleDto] = []
    @State var useApi = false
    
    init() {
    }
    
    private func test() {
        print("\(payments)")
    }

    var body: some View {
        let downPaymentBinding = Binding(
            get: {
                (appViewModel.purchasePrice - appViewModel.loanAmt) * 100.0/appViewModel.purchasePrice
            },
            set: { newValue in
                appViewModel.loanAmt = appViewModel.purchasePrice * (1.0 - newValue/100.0)
            }
        )
        let numOfTermsBinding = Binding(
            get: { Double(appViewModel.numOfTerms)},
            set: { appViewModel.numOfTerms = Int($0) }
        )
        
        NavigationView {
            ScrollView {
                if showProgressBar {
                    LottieView(name: "loading").frame(width:100, height:100)
                }
                
                VStack {
                    TableSectionView(title: "MORTGAGE")
                    
                    let vm = RoiAttributeRowViewModel(name: RoiAttribute.purchasePrice.name, value: appViewModel.purchasePrice)
                    RoiAttributeRow2(viewModel: vm)
                    
                    
                    RoiAttributeRow(attribute: RoiAttribute.purchasePrice, value: $appViewModel.purchasePrice, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(RoiAttribute.downPayment.name).multilineTextAlignment(.leading)
                            Spacer()
                        }
                        HStack {
                            Slider(value: downPaymentBinding, in: 0...100, step: 1)
                            Spacer()
                            Text("\(appViewModel.purchasePrice - appViewModel.loanAmt, specifier: "$%.0f")").font(.caption).foregroundColor(.secondary)
                            Text("\(downPaymentBinding.wrappedValue, specifier: "%.1f")%")
                                .foregroundColor(.blue)
                                .gesture(TapGesture().onEnded({ isOk in
                                    showingEditView = true
                                    attrToEdit = RoiAttribute.downPayment
                                }))
                            Button(action: {
                                test()
                                showingEditView = true
                                attrToEdit = RoiAttribute.downPayment
                            }, label: {
                                Image(systemName: "pencil") // chevron.right
                            })
                            
                        }.padding(.top, -8)
                        Divider().frame(height:0.5).background(Color("TableSection"))
                    }
                    .padding(.top, -8).padding(.leading, 16).padding(.trailing, 16).padding(.bottom, -8)
                    
                    RoiAttributeRow(attribute: RoiAttribute.loanAmt, value: $appViewModel.loanAmt, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(prefix: "", postfix: "%%", attribute: RoiAttribute.interestRate, value: $appViewModel.interestRate, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(prefix: "", postfix: " yr.", isInt: true, attribute: RoiAttribute.numOfTerms, value: numOfTermsBinding, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.escrow, value: $appViewModel.escrow, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.extra, value: $appViewModel.extra, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                }
                
                VStack {
                    TableSectionView(title: "OPERATIONS")
                    RoiAttributeRow(attribute: RoiAttribute.expenses, value: $appViewModel.expenses, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    RoiAttributeRow(attribute: RoiAttribute.rent, value: $appViewModel.rent, attrToEdit: $attrToEdit, showingEditView: $showingEditView)
                    
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
                appViewModel.save()
                
                showProgressBar = true
                if let p = appViewModel.getSavedAmortization() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showProgressBar = false
                        payments = p
                        toAmortizationView = true
                    }
                } else {
                    let request = GetAmortizationRequest(
                        amount: appViewModel.loanAmt,
                        rate: appViewModel.interestRate,
                        terms: appViewModel.numOfTerms,
                        escrow: appViewModel.escrow,
                        extra: appViewModel.extra)
                    
                    if useApi {
                        RestHelper.getAmortization(request) { (dto, data) in
                            showProgressBar = false
                            if let p = dto {
                                payments = p
                                appViewModel.saveAmortization(p)
                                toAmortizationView = true
                            } else {
                                // error ?
                            }
                        } errorUiHandler: { (data, resp, error) in
                            showProgressBar = false
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showProgressBar = false
                            let p = MortgageCalculator.sharedInstance.calcPayments()
                            payments = p
                            appViewModel.saveAmortization(p)
                            toAmortizationView = true
                        }
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
            RentalPropertyView().environmentObject(AppViewModel()).environment(\.colorScheme, .light)
            RentalPropertyView().environmentObject(AppViewModel()).environment(\.colorScheme, .dark)
        }
    }
}
