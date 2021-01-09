//
//  RightDetailCellView.swift
//  RentalROI
//
//  Created by Sean Liao on 1/8/21.
//

import SwiftUI

struct RightDetailCellView: View {
    var text: String = ""
    var detailText: String = ""

    var body: some View {
        VStack {
            HStack {
                Text(text)
                Spacer()
                Text(detailText).fontWeight(.semibold)
            }
            Divider().frame(height:0.5).background(Color("TableSection"))
        }.padding(8).padding(.leading, 8).padding(.trailing, 8)

    }
}

struct RightDetailCellView_Previews: PreviewProvider {
    static var previews: some View {
        RightDetailCellView(text: "No. 2", detailText: "$874.50")
    }
}
