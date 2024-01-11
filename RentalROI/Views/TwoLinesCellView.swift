//
//  RoiTwoLinesCell.swift
//  RentalROI
//
//  Created by Sean Liao on 1/17/21.
//

import SwiftUI

struct TwoLinesCellView: View {
    var text1: String = ""
    var detailText1: String = ""
    
    var text2: String = ""
    var detailText2: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text(text1)
                Spacer()
                Text(detailText1).fontWeight(.semibold)
            }
            HStack {
                Text(text2).font(.subheadline)
                Spacer()
                Text(detailText2).font(.subheadline)
            }.foregroundColor(.secondary)
            Divider().frame(height:0.5).background(Color("TableSection"))
        }.padding(8).padding(.leading, 8).padding(.trailing, 8)
    }
}

struct RoiTwoLinesCell_Previews: PreviewProvider {
    static var previews: some View {
        TwoLinesCellView(
            text1: "ROI", detailText1: "3.00% ($625.00/mo)",
            text2: "Down Pay & Extra", detailText2: "$250,000.00"
        )
    }
}
