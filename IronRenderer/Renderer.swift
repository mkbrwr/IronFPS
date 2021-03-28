//
//  Renderer.swift
//  CreatingAndSamplingTexturesSwift
//
//  Created by Mykhailo Tymchyshyn on 04.03.2021.
//

import simd
import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {

    var device: MTLDevice!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var texture: MTLTexture!
    var vertices: MTLBuffer!
    var numVertices: Int!
    var viewportSize: vector_uint2 = .zero

    let screenWidth: Int
    let screenHeight: Int

    var screen: Screen!

    var pixels: Array<SIMD4<UInt8>>?

    func makeTextureFromScreenBytes() -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()

        // Indicate that each pixel has a blue, green, red, and alpha channel, where each channel is
        // and 8-bit unsigned normalized value (i.e. 0 maps to 0.0 and 255 maps to 1.0)
        textureDescriptor.pixelFormat = .bgra8Unorm

        // Set the pixel dimensions of the texture
        textureDescriptor.width = screenWidth
        textureDescriptor.height = screenHeight

        // Create the texutre from the device using the descriptor
        let texture = device.makeTexture(descriptor: textureDescriptor)!

        // Calculate the number of bytes per row in the image
        let bytesPerRow = 4 * screenWidth

        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                               size: MTLSize(width: screenWidth, height: screenHeight, depth: 1))


        if var p = pixels {
        // Copy the bytes from the data object into the texture
            texture.replace(region: region, mipmapLevel: 0, withBytes: &p, bytesPerRow: bytesPerRow)
        }

        return texture
    }

    init(mtkView: MTKView, width: Int, height: Int) {
        screenWidth = width
        screenHeight = height
        pixels = .init(repeating: .init(255, 0, 128, 255), count: Int(screenWidth) * Int(screenHeight))
        super.init()

        self.device = mtkView.device!

        // Set up a simple MTLBuffer with vertices which include texture coordinates
        var quadVertices: [Vertex] = [
            Vertex(vector_float2( 250, -250), vector_float2(1.0, 1.0)),
            Vertex(vector_float2(-250, -250), vector_float2(0.0, 1.0)),
            Vertex(vector_float2(-250,  250), vector_float2(0.0, 0.0)),

            Vertex(vector_float2( 250, -250), vector_float2(1.0, 1.0)),
            Vertex(vector_float2(-250,  250), vector_float2(0.0, 0.0)),
            Vertex(vector_float2( 250,  250), vector_float2(1.0, 0.0))
        ]

        // Create a vertex buffer, and initialize it with the quadVertices array
        vertices = device.makeBuffer(bytes: &quadVertices,
                                     length: MemoryLayout<Vertex>.stride * quadVertices.count,
                                     options: .storageModeShared)!
        numVertices = quadVertices.count

        /// Create the render pipeline.
        let bundle = Bundle(for: Renderer.self)
        let defaultLibrary = try! device.makeDefaultLibrary(bundle: bundle)
        let vertexFunction = defaultLibrary.makeFunction(name: "vertexShader")!
        let fragmentFunction = defaultLibrary.makeFunction(name: "samplingShader")!

        // Set up a descriptor for creating a pipeline state object
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Texturing Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        commandQueue = device.makeCommandQueue()!
    }

    /// Called whenever the view needs to render a frame.
    func draw(in view: MTKView) {
        texture = makeTextureFromScreenBytes()
        // Create a new command buffer for each render pass to the current drawable
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.label = "MyCommand"

        // Obtain a renderPassDescriptor generated from the view's drawable textures
        let renderPassDescriptor = view.currentRenderPassDescriptor!

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.label = "MyRenderEncoder"

        // Set the region of the drawable to draw into.
        renderEncoder.setViewport(MTLViewport(originX: 0, originY: 0,
                                              width: Double(viewportSize.x), height: Double(viewportSize.y),
                                              znear: -1.0, zfar: 1.0))

        renderEncoder.setRenderPipelineState(pipelineState)

        renderEncoder.setVertexBuffer(vertices,
                                      offset: 0,
                                      index: 0)

        renderEncoder.setVertexBytes(&viewportSize,
                                     length: MemoryLayout<vector_uint2>.stride,
                                     index: 1)

        renderEncoder.setFragmentTexture(texture,
                                         index: 0)

        // Draw the triangles.
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: numVertices)

        renderEncoder.endEncoding()

        // Schedule a present once the framebuffer is complete using the current drawable
        commandBuffer.present(view.currentDrawable!)

        // Finalize rendering here and push the command buffer to the GPU
        commandBuffer.commit()
    }

    /// Called whenever view changes orientation or is resized.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.height)
    }

}

/// Because of this `0: error: using bridging headers with framework targets is unsupported` had to go back to mimicking
/// C typedef layout.
// FIXME: Find out how to do this header stuff for frameworks and remove this mimicking struct.
struct Vertex {
    let position: vector_float2
    let textureCoordiante: vector_float2

    init(_ position: vector_float2, _ textureCoordinate: vector_float2) {
        self.position = position
        self.textureCoordiante = textureCoordinate
    }
}
