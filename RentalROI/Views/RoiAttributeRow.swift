//
//  PropertyAttribute.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI
import Combine

class RoiAttributeRowViewModel: ObservableObject {
//    private var prefix = "$"
//    private var postfix = ""
//    private var isInt = false
//    private var attribute: RoiAttribute

    private var isInt: Bool = false

    @Published var name: String
    @Published var value: String
    
    init(name: String, value: Double) {
        self.name = name
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        self.value = numberFormatter.string(from: value as NSNumber) ?? ""
    }
    init(name: String, value: Int) {
        self.name = name
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.maximumFractionDigits = 2
        self.value = numberFormatter.string(from: value as NSNumber) ?? ""
    }
}

struct RoiAttributeRow2: View {
    
    @ObservedObject var viewModel: RoiAttributeRowViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.name)
                Spacer()
                Text(viewModel.value).foregroundColor(.blue)
                    .gesture(TapGesture().onEnded({ isOk in
//                        viewModel.attrToEdit = attribute
//                        viewModel.showingEditView = true
                    }))
                Button(action: {
//                    self.attrToEdit = attribute
//                    self.showingEditView = true
                }, label: {
                    Image(systemName: "pencil") // chevron.right
                })
            }
            Divider().frame(height:0.5).background(Color("TableSection"))
        }.padding(8).padding(.leading, 8).padding(.trailing, 8)
    }
}

struct RoiAttributeRow: View {
    
    var prefix = "$"
    var postfix = ""
    var isInt = false
    var attribute: RoiAttribute

    @Binding var value: Double
    @Binding var attrToEdit: RoiAttribute
    @Binding var showingEditView: Bool
    
    var body: some View {
        let specifier = prefix + (isInt ? "%.0f" : "%.2f") + postfix
        VStack {
            HStack {
                Text(attribute.name)
                Spacer()
                Text("\(value, specifier: specifier)").foregroundColor(.blue)
                    .gesture(TapGesture().onEnded({ isOk in
                        self.attrToEdit = attribute
                        self.showingEditView = true
                    }))
                Button(action: {
                    self.attrToEdit = attribute
                    self.showingEditView = true
                }, label: {
                    Image(systemName: "pencil") // chevron.right
                })
            }
            Divider().frame(height:0.5).background(Color("TableSection"))
        }.padding(8).padding(.leading, 8).padding(.trailing, 8)
    }
}

struct PropertyAttribute_Previews: PreviewProvider {
    @State static var attrToEdit: RoiAttribute = RoiAttribute.purchasePrice
    @State static var showingEditView = false
    @State static var valueText = ""
    
    static var previews: some View {
        RoiAttributeRow(
            prefix: "", postfix: "%%",
            isInt: false,
            attribute: RoiAttribute.purchasePrice,
            value: .constant(120000.0),
            attrToEdit: $attrToEdit,
            showingEditView: $showingEditView
        )
        
        RoiAttributeRow2(
            viewModel: RoiAttributeRowViewModel(
                name: RoiAttribute.purchasePrice.name,
                value: 120000)
        )

    }
}
