//
//  ViewController.swift
//  Iron3D
//
//  Created by Mykhailo Tymchyshyn on 22.03.2021.
//

import Cocoa
import IronRenderer

let screenWidth = 720
let screenHeight = 720

// TODO: 1. Make renderer from IronFPS into a framework and import it into this project
// TODO: 2. Implement drawTrinagle function in rendrer
// TODO: 3. Add elapsedTime variable on renderer to get time interval between subsequent frames.

enum Side: Int {
    case south = 0
    case east = 2
    case north = 4
    case west = 6
    case top = 8
    case bottom = 10
}

class ViewController: NSViewController {

    let meshCube = Mesh(tris: [
        // South
        Triangle(p: [Vec3D(x: 0, y: 0, z: 0), Vec3D(x: 0, y: 1, z: 0), Vec3D(x: 1, y: 1, z: 0)]),
        Triangle(p: [Vec3D(x: 0, y: 0, z: 0), Vec3D(x: 1, y: 1, z: 0), Vec3D(x: 1, y: 0, z: 0)]),

        // East
        Triangle(p: [Vec3D(x: 1, y: 0, z: 0), Vec3D(x: 1, y: 1, z: 0), Vec3D(x: 1, y: 1, z: 1)]),
        Triangle(p: [Vec3D(x: 1, y: 0, z: 0), Vec3D(x: 1, y: 1, z: 1), Vec3D(x: 1, y: 0, z: 1)]),

        // North
        Triangle(p: [Vec3D(x: 1, y: 0, z: 1), Vec3D(x: 1, y: 1, z: 1), Vec3D(x: 0, y: 1, z: 1)]),
        Triangle(p: [Vec3D(x: 1, y: 0, z: 0), Vec3D(x: 0, y: 1, z: 1), Vec3D(x: 0, y: 0, z: 1)]),

        // West
        Triangle(p: [Vec3D(x: 0, y: 0, z: 1), Vec3D(x: 0, y: 1, z: 1), Vec3D(x: 0, y: 1, z: 0)]),
        Triangle(p: [Vec3D(x: 0, y: 0, z: 1), Vec3D(x: 0, y: 1, z: 0), Vec3D(x: 0, y: 0, z: 0)]),

        // Top
        Triangle(p: [Vec3D(x: 0, y: 1, z: 0), Vec3D(x: 0, y: 1, z: 1), Vec3D(x: 1, y: 1, z: 1)]),
        Triangle(p: [Vec3D(x: 0, y: 1, z: 0), Vec3D(x: 1, y: 1, z: 1), Vec3D(x: 1, y: 1, z: 0)]),

        // Bottom
        Triangle(p: [Vec3D(x: 1, y: 0, z: 1), Vec3D(x: 0, y: 0, z: 1), Vec3D(x: 0, y: 0, z: 0)]),
        Triangle(p: [Vec3D(x: 1, y: 0, z: 1), Vec3D(x: 0, y: 0, z: 0), Vec3D(x: 1, y: 0, z: 0)])
    ])

    // Projection matrix
    let near = 0.1
    let far = 1000.0
    let fov = 90.0
    var aspectRatio: Double!
    var fovRad: Double!

    var matProj: Mat4x4!

    var ironScreen: Screen!

    var moveCommands = Set<Move>()
    var keyDown: Any?
    var keyUp: Any?

    var vCameraX = 0.0
    var vCameraY = 0.0
    var vCameraZ = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        aspectRatio = Double(screenWidth) / Double(screenHeight)
        fovRad = 1.0 / Double(tanf(90.0 * 0.5 / 180.0 * .pi))
        ironScreen = Screen(with: self, resolution: Resolution(screenWidth, screenHeight))

        let renderNextFrame = DispatchWorkItem { self.renderFrame() }
        DispatchQueue.main.async(execute: renderNextFrame)
        setupKeypressEventMonitors()
//        tris = ArraySlice(meshCube.tris)
        let objFile = Bundle.main.url(forResource: "teapot", withExtension: "obj")!
        let mesh = Mesh(fileURL: objFile)
//        debugPrint(mesh)
//        tris = ArraySlice<Triangle>(meshCube.tris)
        tris = ArraySlice<Triangle>(mesh.tris)
    }

    func setupKeypressEventMonitors() {
        keyDown = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [unowned self] event in
            if let move = Move(keyCode: event.keyCode) {
                moveCommands.insert(move)
            }
            return nil
        })

//        keyUp = NSEvent.addLocalMonitorForEvents(matching: .keyUp, handler: { event in
//            if let move = Move(keyCode: event.keyCode) {
//                self.moveCommands.remove(move)
//            }
//            return nil
//        })
    }

    var lastFrameTime = DispatchTime.now().uptimeNanoseconds

    var theta = 0.0

    var side = 0
    var tris: ArraySlice<Triangle>! {
        didSet {
            debugPrint("Triangles to render :", String(describing: tris))
        }
    }

    func renderFrame() {
        ironScreen.clearScreen()
        matProj = Mat4x4(m: [[aspectRatio * fovRad,       0, 0, 0],
                             [0,                     fovRad, 0, 0],
                             [0, 0,         far / (far - near), 1],
                             [0, 0, (-far * near)/(far - near), 0]])

        /// Matrices describing rotation along Z and X axes.
        var matRotZ, matRotX: Mat4x4!

        // Rotation Z
        matRotZ = Mat4x4(m: [[ cos(theta), sin(theta), 0, 0],
                             [-sin(theta), cos(theta), 0, 0],
                             [0, 0, 1, 0],
                             [0, 0, 0, 1]])

        // Rotation X
        matRotX = Mat4x4(m: [[1, 0, 0, 0],
                             [0,  cos(theta * 0.5), sin(theta * 0.5), 0],
                             [0, -sin(theta * 0.5), cos(theta * 0.5), 0],
                             [0, 0, 0, 1]])

        for (n, tri) in tris.enumerated() {
            let v1rOx = multiplyMatrixVector(in: tri.p[0], m: matRotX)
            let v2rOx = multiplyMatrixVector(in: tri.p[1], m: matRotX)
            let v3rOx = multiplyMatrixVector(in: tri.p[2], m: matRotX)

            let v1rOxz = multiplyMatrixVector(in: v1rOx, m: matRotZ)
            let v2rOxz = multiplyMatrixVector(in: v2rOx, m: matRotZ)
            let v3rOxz = multiplyMatrixVector(in: v3rOx, m: matRotZ)

            var triTranslated = Triangle(p: [v1rOxz, v2rOxz, v3rOxz])
            triTranslated.p[0].z = v1rOxz.z + 9.0
            triTranslated.p[1].z = v2rOxz.z + 9.0
            triTranslated.p[2].z = v3rOxz.z + 9.0

            // - Calculate triangle normal for clocwise winding using vector cross product.
            // Triangle vector A.
            let line1x = triTranslated.p[1].x - triTranslated.p[0].x
            let line1y = triTranslated.p[1].y - triTranslated.p[0].y
            let line1z = triTranslated.p[1].z - triTranslated.p[0].z

            // Triangle vector B.
            let line2x = triTranslated.p[2].x - triTranslated.p[0].x
            let line2y = triTranslated.p[2].y - triTranslated.p[0].y
            let line2z = triTranslated.p[2].z - triTranslated.p[0].z

            // Calculate normal for xyz using cross product of A and B.
            var normalx = line1y * line2z - line1z * line2y
            var normaly = line1z * line2x - line1x * line2z
            var normalz = line1x * line2y - line1y * line2x

            // Normalize normal vector.
            let normalLength = sqrt(normalx * normalx + normaly * normaly + normalz * normalz)
            normalx /= normalLength
            normaly /= normalLength
            normalz /= normalLength

          if normalz < 0 {
            if (normalx * (triTranslated.p[0].x - vCameraX) +
                normaly * (triTranslated.p[0].y - vCameraY) +
                normalz * (triTranslated.p[0].z - vCameraZ) < 0.0) {

                // Illumination
                var lightDirection = Vec3D(x: 0.0, y: 0.0, z: -1.0)
                let l = sqrt(lightDirection.x * lightDirection.x +
                             lightDirection.y * lightDirection.y +
                             lightDirection.z * lightDirection.z)
                lightDirection.x /= l
                lightDirection.y /= l
                lightDirection.z /= l

                // Normal is an imaginary vector that is perpendicular to plane defined by the triangle.
                // TODO: fix luminance calculation for mesh loaded from file
                let dotProduct = normalx * lightDirection.x + normaly * lightDirection.y + normalz * lightDirection.z

                // Project triangles from 3D --> 2D
                let v1 = multiplyMatrixVector(in: triTranslated.p[0], m: matProj)
                let v2 = multiplyMatrixVector(in: triTranslated.p[1], m: matProj)
                let v3 = multiplyMatrixVector(in: triTranslated.p[2], m: matProj)

                var triProjected = Triangle(p: [v1, v2, v3])

                // Scale into view
                //            triProjected.p[0].x += 1.0; triProjected.p[0].y += 1.0
                //            triProjected.p[1].x += 1.0; triProjected.p[1].y += 1.0
                //            triProjected.p[2].x += 1.0; triProjected.p[2].y += 1.0

                triProjected.p[0].x *= 300.0 // 0.5 * Double(screenWidth)
                triProjected.p[0].y *= 300.0 // 0.5 * Double(screenHeight)
                triProjected.p[1].x *= 300.0 // 0.5 * Double(screenWidth)
                triProjected.p[1].y *= 300.0 // 0.5 * Double(screenHeight)
                triProjected.p[2].x *= 300.0 // 0.5 * Double(screenWidth)
                triProjected.p[2].y *= 300.0 // 0.5 * Double(screenHeight)

                ironScreen.draw(triangle: triProjected, color: Color(UInt8(255 * dotProduct),
                                                                     UInt8(255 * dotProduct),
                                                                     UInt8(255 * dotProduct),
                                                                     UInt8(255)))
            }
          }
        }
        ironScreen.frameReady()
//        let timeNow = DispatchTime.now().uptimeNanoseconds
//        debugPrint("Frame prepared in ", Double(timeNow - lastFrameTime), "ns")
//        lastFrameTime = timeNow
        theta += 0.01
        let renderNextFrame = DispatchWorkItem { self.renderFrame() }
        DispatchQueue.main.async(execute: renderNextFrame)
    }
}

func multiplyMatrixVector(in i: Vec3D, m: Mat4x4) -> Vec3D {
    let outX = i.x * m.m[0][0] + i.y * m.m[1][0] + i.z * m.m[2][0] + m.m[3][0]
    let outY = i.x * m.m[0][1] + i.y * m.m[1][1] + i.z * m.m[2][1] + m.m[3][1]
    let outZ = i.x * m.m[0][2] + i.y * m.m[1][2] + i.z * m.m[2][2] + m.m[3][2]
    let    w = i.x * m.m[0][3] + i.y * m.m[1][3] + i.z * m.m[2][3] + m.m[3][3]

    if w != 0.0 {
        return Vec3D(x: outX / w, y: outY / w, z: outZ / w)
    } else {
        return Vec3D(x: outX, y: outY, z: outZ)
    }
}
