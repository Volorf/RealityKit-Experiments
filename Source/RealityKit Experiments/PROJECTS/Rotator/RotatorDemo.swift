//
//  RotatorDemo.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 19/04/2025.
//

import SwiftUI
import RealityKit

struct RotatorDemo: View {
    
    let redMat = SimpleMaterial(color: .red, isMetallic: false)
    let greenMat = SimpleMaterial(color: .green, isMetallic: false)
    let blueMat = SimpleMaterial(color: .blue, isMetallic: false)
    let size: (x: Float, y: Float, z: Float) = (x: 0.2, y: 0.2, z: 0.2)
    let rotationSpeed: Float = 0.1
    
    init() {
        RotatorComponent.registerComponent()
        RotatorSystem.registerSystem()
    }
    
    var body: some View {
        RealityView { content in
            
            let cubeX = ModelEntity(mesh: .generateBox(size: .init(x: size.x, y: size.y, z: size.z)), materials: [redMat])
            let compX = RotatorComponent(speed: rotationSpeed, axis: .x)
            cubeX.components.set(compX)
            cubeX.transform.translation.x = -size.x * 1.5
            content.add(cubeX)
            
            let cubeY = ModelEntity(mesh: .generateBox(size: .init(x: size.x, y: size.y, z: size.z)), materials: [greenMat])
            let compY = RotatorComponent(speed: rotationSpeed, axis: .y)
            cubeY.components.set(compY)
            content.add(cubeY)
            
            let cubeZ = ModelEntity(mesh: .generateBox(size: .init(x: size.x, y: size.y, z: size.z)), materials: [blueMat])
            let compZ = RotatorComponent(speed: rotationSpeed, axis: .z)
            cubeZ.components.set(compZ)
            cubeZ.transform.translation.x = size.x * 1.5
            content.add(cubeZ)
        }
    }
    
}

#Preview {
    RotatorDemo()
}
