//
//  ViewController.swift
//  Iron3D
//
//  Created by Mykhailo Tymchyshyn on 22.03.2021.
//

import Cocoa
import IronRenderer
import simd

let screenWidth = 720
let screenHeight = 720

class ViewController: NSViewController {
    // Projection matrix
    let near = 0.1
    let far = 1000.0
    let fov = 90.0
    var aspectRatio: Double!
    var fovRad: Double!

    lazy var matProjMat4x4 = Mat4x4(m: [[aspectRatio * fovRad,       0, 0, 0],
                                              [0,                     fovRad, 0, 0],
                                              [0, 0,         far / (far - near), 1],
                                              [0, 0, (-far * near)/(far - near), 0]])

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

        setupKeypressEventMonitors()
        let objFile = Bundle.main.url(forResource: "teapot", withExtension: "obj")!
        let mesh = Mesh(fileURL: objFile)
        tris = ArraySlice<Triangle>(mesh.tris)

        let renderNextFrame = DispatchWorkItem { self.renderFrame() }
        DispatchQueue.main.async(execute: renderNextFrame)
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

    var tris: ArraySlice<Triangle>! {
        didSet {
            debugPrint("Triangles to render :", String(describing: tris))
        }
    }

    func renderFrame() {
        ironScreen.clearScreen()
        let projectionRow0 = simd_float4(Float(aspectRatio * fovRad), 0, 0, 0)
        let projectionRow1 = simd_float4(0, Float(fovRad), 0, 0)
        let projectionRow2 = simd_float4(0, 0,  Float(far / (far - near)), 1)
        let projectionRow3 = simd_float4(0, 0, Float((-far * near) / (far - near)), 0)

        let projection = simd_float4x4(rows: [projectionRow0,
                                              projectionRow1,
                                              projectionRow2,
                                              projectionRow3])

        /// Matrices describing rotation along Z and X axes.
        var matRotZMat4x4, matRotXMat4x4: Mat4x4!

        // TODO: Do rotation matrices usign following functions from simd:
        //       simd_quatf(angle: <#T##Float#>, axis: <#T##SIMD3<Float>#>)
        //       simd_act(<#T##q: simd_quatf##simd_quatf#>, <#T##v: simd_float3##simd_float3#>)
        
        // Rotation Z
        matRotZMat4x4 = Mat4x4(m: [[ cos(theta), sin(theta), 0, 0],
                                   [-sin(theta), cos(theta), 0, 0],
                                   [0,        0,          1,    0],
                                   [0,        0,          0,    1]])

        // Rotation X
        matRotXMat4x4 = Mat4x4(m: [[1,                 0,                0, 0],
                                   [0,  cos(theta * 0.5), sin(theta * 0.5), 0],
                                   [0, -sin(theta * 0.5), cos(theta * 0.5), 0],
                                   [0,                 0,                0, 1]])


        var triangles: [(Triangle, Float)] = []


        for (n, tri) in tris.enumerated() {
            let v1rOx = multiplyMatrixVector(in: tri.p[0], m: matRotXMat4x4)
            let v2rOx = multiplyMatrixVector(in: tri.p[1], m: matRotXMat4x4)
            let v3rOx = multiplyMatrixVector(in: tri.p[2], m: matRotXMat4x4)

            let v1rOxz = multiplyMatrixVector(in: v1rOx, m: matRotZMat4x4)
            let v2rOxz = multiplyMatrixVector(in: v2rOx, m: matRotZMat4x4)
            let v3rOxz = multiplyMatrixVector(in: v3rOx, m: matRotZMat4x4)

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

                // - Illumination
                var lightDirectionVec3D = Vec3D(x: 0.0, y: 0.0, z: -1.0)

                let l = sqrt(lightDirectionVec3D.x * lightDirectionVec3D.x +
                             lightDirectionVec3D.y * lightDirectionVec3D.y +
                             lightDirectionVec3D.z * lightDirectionVec3D.z)
                lightDirectionVec3D.x /= l
                lightDirectionVec3D.y /= l
                lightDirectionVec3D.z /= l

                let lightDirection = simd_float3(Float(lightDirectionVec3D.x),
                                                 Float(lightDirectionVec3D.y),
                                                 Float(lightDirectionVec3D.z))

                let surfaceNormal = simd_float3(Float(normalx), Float(normaly), Float(normalz))

                // Mesure of how much light is reflected by tirangle
                let luminance = simd_dot(surfaceNormal, lightDirection)


                // - Projection to the screen
                // Project triangles from 3D --> 2D

                // TODO: Replace with matrix by vector multiplication operation from simd library.
                let v1 = multiplyMatrixVector(in: triTranslated.p[0], m: matProjMat4x4)
                let v2 = multiplyMatrixVector(in: triTranslated.p[1], m: matProjMat4x4)
                let v3 = multiplyMatrixVector(in: triTranslated.p[2], m: matProjMat4x4)

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

                triangles.append((triProjected, luminance))
            }
          }
        }

        // Sort triangles back to front based on calculated midpoint value for z.
        triangles.sort { (arg0, arg1) -> Bool in
            let (t1, _) = arg0
            let (t2, _) = arg1
            let z1 = (t1.p[0].z + t1.p[1].z + t1.p[2].z) / 3.0
            let z2 = (t2.p[0].z + t2.p[1].z + t2.p[2].z) / 3.0
            return z1 > z2
        }

        for (triProjected, dotProduct) in triangles {
        ironScreen.draw(triangle: triProjected, color: Color(UInt8(255 * dotProduct),
                                                             UInt8(255 * dotProduct),
                                                             UInt8(255 * dotProduct),
                                                             UInt8(255)))
        }

        ironScreen.frameReady()
//        let timeNow = DispatchTime.now().uptimeNanoseconds
//        debugPrint("Frame prepared in ", Double(timeNow - lastFrameTime), "ns")
//        lastFrameTime = timeNow
        if !moveCommands.isEmpty {
            theta += 0.1
            moveCommands.removeAll()
        }

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
