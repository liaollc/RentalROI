//
//  AmortizationView.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI

struct AmortizationView: View {
    @EnvironmentObject var rentalProperty: RentalProperty

    var body: some View {
        Text("AmortizationView")
            .navigationTitle("AmortizationView")
    }
}

struct AmortizationView_Previews: PreviewProvider {
    static var previews: some View {
        AmortizationView()
    }
}
