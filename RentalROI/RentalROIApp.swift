//
//  RentalROIApp.swift
//  RentalROI
//
//  Created by Sean Liao on 12/12/20.
//

import SwiftUI

@main
struct RentalROIApp: App {
    var body: some Scene {
        WindowGroup {
            RentalPropertyView().environmentObject(RentalProperty.sharedInstance())
        }
    }
}
