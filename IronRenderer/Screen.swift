//
//  Screen.swift
//  IronRenderer
//
//  Created by Mykhailo Tymchyshyn on 27.03.2021.
//

import MetalKit

public final class Screen {
    public var width: Int
    public var height: Int
    public var aspectRatio: Double { Double(width) / Double(height) }

    let mtkView: MTKView
    let renderer: Renderer

    let windowBackground = MTLClearColor(red: 0.6, green: 0.0, blue: 0.5, alpha: 1.0)

    public init(with viewController: NSViewController, resolution: Resolution) {
        mtkView = MTKView(frame: viewController.view.frame)

        width = resolution.width
        height = resolution.height

        mtkView.enableSetNeedsDisplay = true
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = windowBackground
        mtkView.setNeedsDisplay(viewController.view.frame)

        viewController.view = mtkView

        renderer = Renderer(mtkView: mtkView, width: width, height: height)

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        renderer.screen = self
        mtkView.delegate = renderer
    }

    public func draw(color: Color, at position: Position) {
        renderer.pixels![position.x * width + position.y] = color
    }

    /// Clockwise
    public func draw(triangle: Triangle, color: Color) {
        let color = SIMD4<Float>(Float(color.x) / Float(255),
                                 Float(color.y) / Float(255),
                                 Float(color.z) / Float(255),
                                 Float(color.w) / Float(255))
        for p in triangle.p {
            let x = Float(p.x)
            let y = Float(p.y)
            let a = Vertex(SIMD2<Float>(x, y), color)
            renderer.quadVertices.append(a)
        }
    }

    public func frameReady() {
        DispatchQueue.main.async { [unowned self] in
            self.mtkView.setNeedsDisplay(self.mtkView.frame)
        }
    }

    public func clearScreen() {
        DispatchQueue.main.async { [unowned self] in
            self.renderer.quadVertices = []
            self.mtkView.setNeedsDisplay(self.mtkView.frame)
        }
    }
}

public typealias Color = SIMD4<UInt8>

public struct Position {
    let x: Int
    let y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

public struct Resolution {
    let width: Int
    let height: Int

    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
}

public struct Vec3D: CustomStringConvertible {
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var x, y, z: Double

    public var description: String {
         "{\(x), \(y), \(z)}"
    }
}

public struct Triangle {
    public init(p: [Vec3D]) {
        self.p = p
    }

    public var p: [Vec3D]
}

public struct Mesh {
    public let tris: [Triangle]

    public init(tris: [Triangle]) {
        self.tris = tris
    }

    public init(fileURL: URL) {
        let data = try! Data(contentsOf: fileURL)
        let string = String(data: data, encoding: .utf8)!
        let lines = string.components(separatedBy: "\n")

        let vertices = lines.filter{ $0.hasPrefix("v") }
                            .map{ $0.components(separatedBy: " ") }
                            .map{ str -> Vec3D in
                                  let coordinates = str.dropFirst().map{ Double($0)! }
                                  return Vec3D(x: coordinates[0], y: coordinates[1], z: coordinates[2])
                            }
        let tris = lines
            .filter{ $0.hasPrefix("f") }
            .map{ $0.components(separatedBy: " ") }
            .map{str -> Triangle in
                let vertices = str.dropFirst().map{ Int($0)! }.map{ vertices[$0 - 1] }
                return Triangle(p: vertices)
            }

        self.tris = tris
    }
}

public struct Mat4x4 {
    public init(m: [[Double]]) {
        self.m = m
    }

    public let m: [[Double]]
}
