//
//  RealityKit_ExperimentsApp.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 18/04/2025.
//

import SwiftUI

@main
struct RealityKit_ExperimentsApp: App {

    var body: some Scene {
        WindowGroup {
            RotatorDemo()
        }
        .windowStyle(.volumetric)
    }
}
