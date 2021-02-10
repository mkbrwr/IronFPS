//
//  Renderer.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 08.02.2021.
//

import MetalKit
import simd

struct Vertex {
    let position: SIMD2<Float32>
    private let padding =  (Float32(0.0), Float32(0.0))
    let color: SIMD4<Float32>

    static var lenght: Int { 32 }
}


func triangle(_ a: SIMD2<Float32>, _ b: SIMD2<Float32>, _ c: SIMD2<Float32>) -> [Vertex] {
    let color = SIMD4<Float32>(0, 0, 1, 1)
    let secondColor = SIMD4<Float32>(0, 1, 1, 1)
    return [Vertex(position: a, color: color),
            Vertex(position: b, color: secondColor),
            Vertex(position: c, color: secondColor)]
}

/// origin bottom left
func square(origin: SIMD2<Float32>, size: Float32) -> [Vertex] {
    let a = SIMD2<Float32>(origin.x, origin.y)
    let b = SIMD2<Float32>(origin.x, origin.y + size)
    let c = SIMD2<Float32>(origin.x + size, origin.y)
    let d = SIMD2<Float32>(origin.x + size, origin.y + size)

    let square: [Vertex] = triangle(a, b, c) + triangle(b, c, d)
    return square
}

var screenDimensions = (width: Int(3), height: Int(7))

let pixelSize: Float32 = 24

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    var viewportSize: (UInt32, UInt32) = (0, 0)
    var pipelineState: MTLRenderPipelineState!

    var triangleVertices: [Vertex] = []

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
        debugPrint("\(#function)")
        // Worked with tuples
        var triangleVertices: [Vertex] = []
        for w in 0..<screenDimensions.width {
            for h in 0..<screenDimensions.height {
                triangleVertices += square(origin: SIMD2<Float32>(Float32(h) * pixelSize, Float32(w) * pixelSize), size: pixelSize)
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


        // Pass in the paramter data.
        let buffer = device.makeBuffer(bytes: &triangleVertices,
                                       length: 4096, // size of the buffer does not affect the result for some reason
                                       options: .storageModeShared)

        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&triangleVertices,
                                     length: Vertex.lenght * triangleVertices.count,
                                     index: 0)

        let buffer2 = device.makeBuffer(bytes: &viewportSize, length: 16, options: .storageModeShared)
        renderEncoder.setVertexBuffer(buffer2, offset: 0, index: 1)

        // Draw the triangle.
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: triangleVertices.count)
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
