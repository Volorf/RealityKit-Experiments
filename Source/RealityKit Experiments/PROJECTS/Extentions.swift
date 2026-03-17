//
//  Extentions.swift
//  vision-os-interactions
//
//  Created by Oleg Frolov on 16/01/2026.
//

import Spatial
import simd

extension Point3D {
    var convertToSimd3Float: SIMD3<Float> {
        SIMD3<Float>(Float(x), Float(y), Float(z))
    }

    var convertToSimd3Double: SIMD3<Double> {
        SIMD3<Double>(x, y, z)
    }
}

extension SIMD3 where Scalar == Float {
    var convertToCubSide: CubeSide {
        let maxAxis = Swift.max(abs(x), abs(y), abs(z))

        var side: CubeSide = .none
        
        switch maxAxis {
        case abs(x):
            side = x >= 0 ? .right : .left
        case abs(y):
            side = y >= 0 ? .top : .bottom
        default:
            side = z >= 0 ? .front : .back
        }
        
        return side
    }
}

extension CubeSide {
    var convertToNormal: SIMD3<Float> {
        switch self {
        case .left:
            return .init(-1, 0, 0)
        case .right:
            return .init(1, 0, 0)
        case .front:
            return .init(0, 0, 1)
        case .back:
            return .init(0, 0, -1)
        case .top:
            return .init(0, 1, 0)
        case .bottom:
            return .init(0, -1, 0)
        case .none:
            return .zero
        }
    }
}
