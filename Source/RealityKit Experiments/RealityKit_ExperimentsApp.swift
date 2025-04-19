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

//        ImmersiveSpace(id: appModel.immersiveSpaceID) {
//            ImmersiveView()
//                .environment(appModel)
//                .onAppear {
//                    appModel.immersiveSpaceState = .open
//                }
//                .onDisappear {
//                    appModel.immersiveSpaceState = .closed
//                }
//        }
//        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
