//
//  RotatorAxis.swift
//  RealityKit Experiments
//
//  Created by Oleg Frolov on 19/04/2025.
//

enum RotatorAxis {
    case y
    case z
    case x
    
    var vector: SIMD3<Float> {
        switch self {
        case .y:
            return SIMD3<Float>(0, 1, 0)
        case .z:
            return SIMD3<Float>(0, 0, 1)
        case .x:
            return SIMD3<Float>(1, 0, 0)
        }
    }
}
