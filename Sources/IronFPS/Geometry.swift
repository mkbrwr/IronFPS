struct Vec2D {
    let x: Float
    let y: Float
}

extension Vec2D {
    init(_ x: Float, _ y: Float) {
        self.init(x: x, y: y)
    }
}

struct Vec3D {
    let x: Float
    let y: Float
    let z: Float
}

extension Vec3D {
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
    }
}

struct Camera {
    let position: Vec3D
    let rotation: Vec3D
    let fovAngle: Float
}
