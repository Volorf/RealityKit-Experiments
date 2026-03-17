import SwiftUI
import RealityKit

struct TouchableCubeView: View {
    // REFS
    @State private var cube: Entity = .init()
    @State private var cubeMaterial: PhysicallyBasedMaterial = .init()
    @State private var tapSoundResource: AudioResource? = nil
   
    // UI STATES
    @State private var isPressed: Bool = false
    @State private var currentHueOffset: Double = 0.0
    
    // CONSTS
    private let hueStep = 0.1
    private let size: Float = 0.05
    private let initialVelocityScalar: Float = 0.002
    
    init() {
        TouchableCubeComponent.registerComponent()
        TouchableCubeSystem.registerSystem()
    }
    
    private func getNextColor() -> UIColor {
        let c = Color(
            hue: CGFloat(currentHueOffset).truncatingRemainder(dividingBy: 1.0),
            saturation: 1.0,
            brightness: 1.0)
        currentHueOffset += hueStep
        return UIColor(c)
    }
    
    var body: some View {
        RealityView() { context in
            let startColor = getNextColor()
            
            let root = Entity()
            root.position = .init(x: 0, y: 1.2, z: -0.5)
            
            cubeMaterial.baseColor.tint = startColor
            cubeMaterial.roughness = 0.2
            cubeMaterial.metallic = 0.6
            
            cube = ModelEntity(
                mesh: .generateBox(size: .one * size,
                cornerRadius: size / 20),
                materials: [cubeMaterial])
            
            cube.components.set(TouchableCubeComponent(
                position: .zero,
                velocity: .zero,
                direction: .zero,
                mass: 1))
            
            cube.components.set(
                CollisionComponent(shapes: [.generateBox(size: .one * size)])
            )
            
            cube.components.set(InputTargetComponent())
            root.addChild(cube)
            context.add(root)
            
            cube.components.set(GroundingShadowComponent(castsShadow: true))
            
            Task {
                tapSoundResource = try? await AudioFileResource(
                    named: "Tab 2.m4a",
                    configuration: .init(shouldLoop: false)
                )
            }
        }
        .gesture(tap)
    }
    
    var tap: some Gesture {
        DragGesture(minimumDistance: 0)
            .targetedToEntity(cube)
            .onChanged { value in
                if (isPressed) { return }
                isPressed = true

                let entity = value.entity
                let nextColor = getNextColor()
                
                let worldPos = value.location3D
                let locPoint3D = value.convert(worldPos, from: .local, to: entity)
                let touchedSide = locPoint3D.convertToCubSide
                
                let oldComp = entity.components[TouchableCubeComponent.self]!
                
                let newComp = TouchableCubeComponent(position: oldComp.position, velocity: -touchedSide.convertToNormal * initialVelocityScalar, direction: -touchedSide.convertToNormal, mass: oldComp.mass)
                
                entity.components[TouchableCubeComponent.self] = newComp
                
                if let model = entity as? ModelEntity {
                    cubeMaterial.baseColor.tint = nextColor
                    model.model?.materials[0] = cubeMaterial
                }
                
                guard let tapSoundResource else { return }
                entity.playAudio(tapSoundResource)
            }
            .onEnded { value in
                isPressed = false
            }
    }
}

#Preview(immersionStyle: .mixed) {
    TouchableCubeView()
}

struct TouchableCubeComponent: Component {
    let position: SIMD3<Float>
    let velocity: SIMD3<Float>
    let direction: SIMD3<Float>
    let mass: Float
    
    func copy(direction: SIMD3<Float>) -> TouchableCubeComponent {
        TouchableCubeComponent(
            position: self.position,
            velocity: self.velocity,
            direction: direction,
            mass: self.mass
        )
    }
}

class TouchableCubeSystem: System {
    private static let query = EntityQuery(where: .has(TouchableCubeComponent.self))
    private let airResistance: Float = 0.001
    
    required init(scene: RealityFoundation.Scene) {
    }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query, updatingSystemWhen: .rendering) {
            guard let comp = entity.components[TouchableCubeComponent.self] else { continue }
            
            let airForce = -comp.direction * Float(context.deltaTime) * airResistance
            let newVel = comp.velocity + airForce
            let newPos = comp.position + newVel;
            
            if (simd_length(newVel) <= 0.00001) {
                return
            }
            
            let newComp = TouchableCubeComponent(position: newPos, velocity: newVel, direction: comp.direction, mass: comp.mass)
            
            entity.components[TouchableCubeComponent.self] = newComp
            entity.position = newComp.position
        }
    }
}
