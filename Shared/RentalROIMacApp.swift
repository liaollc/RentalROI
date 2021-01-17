//
//  RentalROIMacApp.swift
//  Shared
//
//  Created by Sean Liao on 1/10/21.
//

import SwiftUI

@main
struct RentalROIMacApp: App {
    init() {
        RentalProperty.sharedInstance.load()
    }

    var body: some Scene {
        WindowGroup {
            RentalPropertyView().environmentObject(RentalProperty.sharedInstance)
        }
    }
}
