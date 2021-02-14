//
//  Renderer.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 08.02.2021.
//

import MetalKit

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

struct Square {
    let vertices: [Vertex]

    // Origin bottom left
    init(origin: Point, size: Float32, color: Color) {
        let a = Point(origin.x, origin.y)
        let b = Point(origin.x, origin.y + size)
        let c = Point(origin.x + size, origin.y)
        let d = Point(origin.x + size, origin.y + size)
        vertices = triangle(a, b, c, color: color) + triangle(b, c, d, color: color)
    }
}

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
        var squares: [Square] = []
        squares.reserveCapacity(screenWidth * screenHeight)
        let offset = (x: Float32(-640), y: Float32(-288))
        for w in 0..<screenWidth {
            for h in 0..<screenHeight {
                let origin = offset.x + Point(Float32(w) * pixelSize, offset.y + Float32(h) * pixelSize)
                let color = screen[h*screenWidth+w]
                squares.append(Square(origin: origin,
                                      size: pixelSize,
                                      color: color))
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

enum Sprite {
    case wall

    func sampleAt(x: Float32, y: Float32) -> Color {
        SpriteStorage.single.sampleAt(x, y)
    }
}

class SpriteStorage {
    static let single = SpriteStorage()

    let data: Data!
    let width = 64
    let height = 64

    init() {
        let bitmap = Bundle.main.url(forResource: "Brick_64", withExtension: "data")!
        data = try! Data(contentsOf: bitmap)
    }

    func sampleAt(_ x: Float32, _ y: Float32) -> Color {
        let textureX = Int(Float(width - 1)  * x)
        let textureY = Int(Float(height - 1) * y)
        let textureIdx = (textureX + textureY * width) * 4
        let R = data[textureIdx+0]
        let G = data[textureIdx+1]
        let B = data[textureIdx+2]
        let A = data[textureIdx+3]
        return Color(Float32(R)/255.0, Float32(G)/255.0, Float32(B)/255.0, 1.0)
    }
}
