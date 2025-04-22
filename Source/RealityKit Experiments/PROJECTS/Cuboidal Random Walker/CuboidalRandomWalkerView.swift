//
//  CuboidalRandomWalkerView.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 20/04/2025.
//

import SwiftUI
import RealityKit

struct CuboidalRandomWalkerView: View {
    @Environment(CuboidalRandomWalkerModel.self) var randomWalkerModel
    @State private var counter: Int = 0
    @State var parent: Entity = Entity()
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init() {
        RotatorComponent.registerComponent()
        RotatorSystem.registerSystem()
    }
    
    var body: some View {
        RealityView { content in
            parent.components[RotatorComponent.self] = RotatorComponent()
            content.add(parent)
        } update: { content in
            for model in randomWalkerModel.modelEntities {
                parent.addChild(model)
            }
        }
        .onReceive(timer) { time in
            if counter == randomWalkerModel.modelEntities.count {
                timer.upstream.connect().cancel()
            } else {
                randomWalkerModel.modelEntities[counter].scale = SIMD3<Float>(x: 1.0, y: 1.0, z: 1.0)
                counter += 1
            }
        }
    }
}

#Preview {
    @Previewable @State var randomWalkerModel: CuboidalRandomWalkerModel = .init()
    CuboidalRandomWalkerView()
        .environment(randomWalkerModel)
}
