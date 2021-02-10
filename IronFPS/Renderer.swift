//
//  Renderer.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 08.02.2021.
//

import MetalKit
import simd
import Algorithms

typealias Color = SIMD4<Float32>
typealias Point = SIMD2<Float32>

struct Vertex {
    let position: Point
    private let padding =  (Float32(0.0), Float32(0.0))
    let color: Color

    static var lenght: Int { 32 }
}

func triangle(_ a: Point, _ b: Point, _ c: Point, color: Color) -> [Vertex] {
    return [Vertex(position: a, color: color),
            Vertex(position: b, color: color),
            Vertex(position: c, color: color)]
}

/// origin bottom left
func square(origin: Point, size: Float32, color: Color) -> Square {
    let a = Point(origin.x, origin.y)
    let b = Point(origin.x, origin.y + size)
    let c = Point(origin.x + size, origin.y)
    let d = Point(origin.x + size, origin.y + size)

    let square: [Vertex] = triangle(a, b, c, color: color) + triangle(b, c, d, color: color)
    return Square(vertices: square)
}

struct Square {
    let vertices: [Vertex]
}

let pixelSize: Float32 = 10

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    var viewportSize: (UInt32, UInt32) = (0, 0)
    var pipelineState: MTLRenderPipelineState!

    init?(metalKitView: MTKView) {
        device = metalKitView.device!

        // Load all the shader files with a .metal file extension in the project.
        let library = device.makeDefaultLibrary()!

        let vertexFunction = library.makeFunction(name: "vertexShader")!
        let fragmentFunction = library.makeFunction(name: "fragmentShader")!

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "InronFPS Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()!
        super.init()
    }

    func draw(in view: MTKView) {
//        debugPrint("\(#function)")
        var squares: [Square] = []
        let offset = (x: Float32(-640), y: Float32(-288))
        for w in 0..<screenWidth {
            for h in 0..<screenHeight {
                squares.append(square(origin: offset.x + Point(Float32(w) * pixelSize, offset.y + Float32(h) * pixelSize),
                                      size: pixelSize, color: screen[w+h*screenHeight]))
            }
        }

        // Create a new command buffer for each render pass to the current drawable.
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.label = "IronFPSCommandBuffer"

        // Obtain a renderPassDescriptor generated from the view's drawable textures.
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        //
        // Create a render command encoder.
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.label = "MyRenderEncoder"

        // Set the region of the drawable to draw into.
        renderEncoder.setViewport(MTLViewport(originX: 0.0,
                                              originY: 0.0,
                                              width: Double(viewportSize.0),
                                              height: Double(viewportSize.1),
                                              znear: 0.0,
                                              zfar: 1.0))

        renderEncoder.setRenderPipelineState(pipelineState)


        for square in squares {
        var triangles = square.vertices
        // Pass in the paramter data.
        renderEncoder.setVertexBytes(&triangles,
                                     length: Vertex.lenght * triangles.count,
                                     index: 0)
        renderEncoder.setVertexBytes(&viewportSize, length: 16, index: 1)

        // Draw the triangle.
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: triangles.count)
        }
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        debugPrint("\(#function) new size: \(size)")
        viewportSize.0 = UInt32(size.width)
        viewportSize.1 = UInt32(size.height)
    }
}
