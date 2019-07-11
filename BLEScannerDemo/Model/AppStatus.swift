//
//  AppStatus.swift
//
//  Copyright © 2019 Matt Whitlock All rights reserved.
//

import Foundation

/// FIXME: Use DI
var appStatus = AppStatus()

/// Class to contain status information for the app.
struct AppStatus {
    var appState: AppState

    init() {
        appState = .initializing
    }
}
