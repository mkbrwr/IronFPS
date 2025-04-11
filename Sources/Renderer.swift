import MetalKit

@MainActor
class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue

    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!

    func setupPipeline() {
        let shaderSource = """
            #include <metal_stdlib>
            using namespace metal;

            vertex float4 vertexShader(uint vertexID [[vertex_id]],
                                      constant float3* vertices [[buffer(0)]]) {
                return float4(vertices[vertexID], 1.0);
            }

            fragment float4 fragmentShader() {
                return float4(1.0, 0.0, 0.0, 1.0);
            }
            """

        guard let library = try? device.makeLibrary(source: shaderSource, options: nil) else {
            fatalError("Failed to create shader library")
        }

        let vertexFunc = library.makeFunction(name: "vertexShader")
        let fragmentFunc = library.makeFunction(name: "fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }

        let vertices: [Float] = [
             0.0,  0.5, 0.0,    // top
            -0.5, -0.5, 0.0,    // bottom left
             0.5, -0.5, 0.0     // bottom right
        ]

        vertexBuffer = device.makeBuffer(bytes: vertices,
                                        length: vertices.count * MemoryLayout<Float>.size,
                                        options: [])
    }

    init(metalView: MTKView, device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!

        super.init()

        metalView.clearColor = MTLClearColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0)
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.framebufferOnly = true
        metalView.preferredFramesPerSecond = 60
        setupPipeline()
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        commandEncoder.setRenderPipelineState(pipelineState)

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle resize if needed
    }
}
