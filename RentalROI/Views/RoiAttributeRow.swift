//
//  PropertyAttribute.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI
import Combine

struct RoiAttributeRow: View {
    
    var prefix = "$"
    var postfix = ""
    var isInt = false
    var attribute: RoiAttribute
    @Binding var value: Double
    @Binding var attrToEdit: RoiAttribute
    @Binding var showingEditView: Bool
    
    var body: some View {
        let label = String(format: isInt ? "%@%.0f%@" : "%@%.2f%@", prefix, value, postfix)
        VStack {
            HStack {
                Text(attribute.name)
                Spacer()
                Text(label)
                    .foregroundColor(.blue)
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
        }.padding(8).padding(.leading, 16).padding(.trailing, 16)
    }
}

struct PropertyAttribute_Previews: PreviewProvider {
    @State static var attrToEdit: RoiAttribute = RoiAttribute.purchasePrice
    @State static var showingEditView = false
    @State static var valueText = ""
    
    static var previews: some View {
        RoiAttributeRow(
            prefix: "", postfix: " yr.",
            isInt: true,
            attribute: RoiAttribute.purchasePrice,
            value: .constant(0.0),
            attrToEdit: $attrToEdit,
            showingEditView: $showingEditView
        )
    }
}
