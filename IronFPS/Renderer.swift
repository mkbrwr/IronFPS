//
//  Renderer.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 08.02.2021.
//

import MetalKit
import simd


class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    var viewportSize: (UInt32, UInt32) = (0, 0)
    var pipelineState: MTLRenderPipelineState!

    var triangleVertices: (Float32,Float32, Float32, Float32, Float32, Float32,Float32,Float32,Float32,Float32, Float32, Float32, Float32, Float32,Float32,Float32,  Float32,Float32, Float32, Float32, Float32, Float32,Float32,Float32, Float32, Float32, Float32, Float32, Float32,Float32,Float32,Float32, Float32,Float32, Float32, Float32, Float32, Float32,Float32,Float32, Float32, Float32, Float32, Float32, Float32,Float32,Float32,Float32) = (
//        Float32(0.0), Float32(0.0),
//        Float32(1.0), Float32(1.0),
//        Float32(1), Float32(1), Float32(0), Float32(1),

//        Float32(0.0), Float32(100.0),
//        Float32(1.0), Float32(1.0),
//        Float32(1.0), Float32(0.0), Float32(1.0), Float32(1.0),

        Float32(0.0), Float32(0.0),
        Float32(1.0), Float32(1.0),
        Float32(1), Float32(1), Float32(0), Float32(1),

        Float32(110.0), Float32(200.0),
        Float32(1.0), Float32(1.0),
        Float32(1.0), Float32(0.0), Float32(1.0), Float32(1.0),

        Float32(0.0), Float32(0.0),
        Float32(1.0), Float32(1.0),
        Float32(1), Float32(1), Float32(0), Float32(1),

        Float32(-110.0), Float32(100.0),
        Float32(1.0), Float32(1.0),
        Float32(1.0), Float32(0.0), Float32(1.0), Float32(1.0),

        Float32(0.0), Float32(0.0),
        Float32(1.0), Float32(1.0),
        Float32(1.0), Float32(0.0), Float32(1.0), Float32(1.0),

        Float32(-110.0), Float32(-500.0),
        Float32(1.0), Float32(1.0),
        Float32(1), Float32(1), Float32(0), Float32(1)
    )

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


//         Pass in the paramter data.
        let buffer = device.makeBuffer(bytes: &triangleVertices,
                                       length: 32 * 6,
                                       options: .storageModeShared)

        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&triangleVertices,
                                     length: 32 * 8,
                                     index: 0)

        let buffer2 = device.makeBuffer(bytes: &viewportSize, length: 16, options: .storageModeShared)
        renderEncoder.setVertexBuffer(buffer2, offset: 0, index: 1)

//        // Draw the triangle.
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: 8)
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
