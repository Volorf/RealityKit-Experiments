//
//  RotatorSystem.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 19/04/2025.
//

import RealityKit

class RotatorSystem: System {
    private static let query = EntityQuery(where: .has(RotatorComponent.self))
    var rot = simd_quatf(angle: 0, axis: SIMD3<Float>(1,0,0))
    var angle: Float = 0.0

    required init(scene: RealityFoundation.Scene) {
        
    }
    
    func update(context: SceneUpdateContext) {
        angle += Float(context.deltaTime)
        
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let comp = entity.components[RotatorComponent.self] else { continue }
            rot = simd_quatf(angle: Float.pi * angle * comp.speed, axis: comp.axis.vector)
            entity.transform.rotation = rot
        }
    }
}


