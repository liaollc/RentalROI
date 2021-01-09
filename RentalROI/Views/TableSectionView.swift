//
//  TableSectionView.swift
//  RentalROI
//
//  Created by Sean Liao on 1/8/21.
//

import SwiftUI

struct TableSectionView: View {
    var title: String = ""
    var body: some View {
        HStack {
            Text(title).font(.headline).fontWeight(.bold)
                .padding(16)
            Spacer()
        }.background(Color("TableSection"))
        .padding(.bottom, 6)
    }
}

struct TableSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TableSectionView(title: "Mortgage").environment(\.colorScheme, .dark)
            TableSectionView(title: "Mortgage")
            TableSectionView(title: "Mortgage")
        }
    }
}
