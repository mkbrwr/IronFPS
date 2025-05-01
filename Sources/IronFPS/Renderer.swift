/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Implementation for a renderer class that performs Metal setup and
 per-frame rendering.
*/

import MetalKit
import Support

// The main class performing the rendering.
@MainActor
class Renderer: NSObject, MTKViewDelegate {
    // Texture to render to and then sample from.
    private var renderTargetTexture: MTLTexture!

    // Render pass descriptor to draw to the texture
    private var renderToTextureRenderPassDescriptor: MTLRenderPassDescriptor!

    // A pipeline object to render to the offscreen texture.
    private var renderToTextureRenderPipeline: MTLRenderPipelineState!

    // A pipeline object to render to the screen.
    private var drawableRenderPipeline: MTLRenderPipelineState!

    // Ratio of width to height to scale positions in the vertex shader.
    private var aspectRatio: Float = 1.0

    private var device: MTLDevice!

    private var commandQueue: MTLCommandQueue!

    /// Initializes the renderer with the MetalKit view from which you obtain the Metal device.
    init(metalKitView mtkView: MTKView) {
        super.init()

        device = mtkView.device

        mtkView.clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)

        commandQueue = device.makeCommandQueue()

        // Set up a texture for rendering to and sampling from
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.textureType = .type2D
        texDescriptor.width = 512
        texDescriptor.height = 512
        texDescriptor.pixelFormat = .rgba8Unorm
        texDescriptor.usage = [.renderTarget, .shaderRead]

        renderTargetTexture = device.makeTexture(descriptor: texDescriptor)

        // Set up a render pass descriptor for the render pass to render into
        // renderTargetTexture.

        renderToTextureRenderPassDescriptor = MTLRenderPassDescriptor()

        renderToTextureRenderPassDescriptor.colorAttachments[0].texture = renderTargetTexture

        renderToTextureRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderToTextureRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 1, green: 1, blue: 1, alpha: 1)

        renderToTextureRenderPassDescriptor.colorAttachments[0].storeAction = .store

        let defaultLibrary = ShaderCompiler(device: device)!.library

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Drawable Render Pipeline"
        pipelineStateDescriptor.sampleCount = mtkView.sampleCount
        pipelineStateDescriptor.vertexFunction = defaultLibrary.makeFunction(
            name: "textureVertexShader")
        pipelineStateDescriptor.fragmentFunction = defaultLibrary.makeFunction(
            name: "textureFragmentShader")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineStateDescriptor.vertexBuffers[0]
            .mutability =
            .immutable

        do {
            drawableRenderPipeline = try device.makeRenderPipelineState(
                descriptor: pipelineStateDescriptor)
        } catch {
            fatalError("Failed to create pipeline state to render to screen: \(error)")
        }

        // Set up pipeline for rendering to the offscreen texture. Reuse the
        // descriptor and change properties that differ.
        pipelineStateDescriptor.label = "Offscreen Render Pipeline"
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.vertexFunction = defaultLibrary.makeFunction(
            name: "simpleVertexShader")
        pipelineStateDescriptor.fragmentFunction = defaultLibrary.makeFunction(
            name: "simpleFragmentShader")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = renderTargetTexture.pixelFormat

        do {
            renderToTextureRenderPipeline = try device.makeRenderPipelineState(
                descriptor: pipelineStateDescriptor)
        } catch {
            fatalError("Failed to create pipeline state to render to texture: \(error)")
        }
    }

    // MARK: - MetalKit View Delegate

    // Handles view orientation and size changes.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspectRatio = Float(size.height) / Float(size.width)
    }

    // Handles view rendering for a new frame.
    func draw(in view: MTKView) {
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Command Buffer"

        do {
            let triVertices: [AAPLSimpleVertex] = [
                // Positions     ,  Colors
                AAPLSimpleVertex(
                    position: vector_float2(0.5, -0.5), color: vector_float4(1.0, 0.0, 0.0, 1.0)),
                AAPLSimpleVertex(
                    position: vector_float2(-0.5, -0.5), color: vector_float4(0.0, 1.0, 0.0, 1.0)),
                AAPLSimpleVertex(
                    position: vector_float2(0.0, 0.5), color: vector_float4(0.0, 0.0, 1.0, 0.0)),
            ]

            guard
                let renderEncoder = commandBuffer?.makeRenderCommandEncoder(
                    descriptor: renderToTextureRenderPassDescriptor)
            else {
                return
            }

            renderEncoder.label = "Offscreen Render Pass"
            renderEncoder.setRenderPipelineState(renderToTextureRenderPipeline)

            renderEncoder.setVertexBytes(
                triVertices,
                length: MemoryLayout<AAPLSimpleVertex>.stride * triVertices.count,
                index: 0)

            renderEncoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: 3)

            // End encoding commands for this render pass.
            renderEncoder.endEncoding()
        }

        if let drawableRenderPassDescriptor = view.currentRenderPassDescriptor {
            let quadVertices: [AAPLTextureVertex] = [
                // Positions     , Texture coordinates
                AAPLTextureVertex(
                    position: vector_float2(0.5, -0.5), texcoord: vector_float2(1.0, 1.0)),
                AAPLTextureVertex(
                    position: vector_float2(-0.5, -0.5), texcoord: vector_float2(0.0, 1.0)),
                AAPLTextureVertex(
                    position: vector_float2(-0.5, 0.5), texcoord: vector_float2(0.0, 0.0)),

                AAPLTextureVertex(
                    position: vector_float2(0.5, -0.5), texcoord: vector_float2(1.0, 1.0)),
                AAPLTextureVertex(
                    position: vector_float2(-0.5, 0.5), texcoord: vector_float2(0.0, 0.0)),
                AAPLTextureVertex(
                    position: vector_float2(0.5, 0.5), texcoord: vector_float2(1.0, 0.0)),
            ]

            guard
                let renderEncoder = commandBuffer?.makeRenderCommandEncoder(
                    descriptor: drawableRenderPassDescriptor)
            else {
                return
            }

            renderEncoder.label = "Drawable Render Pass"

            renderEncoder.setRenderPipelineState(drawableRenderPipeline)

            renderEncoder.setVertexBytes(
                quadVertices,
                length: MemoryLayout<AAPLTextureVertex>.stride * quadVertices.count,
                index: 0)

            renderEncoder.setVertexBytes(
                &aspectRatio,
                length: MemoryLayout<Float>.size,
                index: 1)

            // Set the offscreen texture as the source texture.
            renderEncoder.setFragmentTexture(
                renderTargetTexture, index: 0)

            // Draw quad with rendered texture.
            renderEncoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: 6)

            renderEncoder.endEncoding()

            if let currentDrawable = view.currentDrawable {
                commandBuffer?.present(currentDrawable)
            }
        }

        commandBuffer?.commit()
    }
}
