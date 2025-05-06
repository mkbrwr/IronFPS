import MetalKit
import SwiftUI

struct MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        let metalView = MTKView()
        metalView.delegate = context.coordinator

        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        metalView.enableSetNeedsDisplay = true

        context.coordinator.setupMetal(metalView: metalView)

        return metalView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    class Coordinator: NSObject, MTKViewDelegate {
        private var renderer: Renderer?

        func setupMetal(metalView: MTKView) {
            renderer = Renderer(metalKitView: metalView)
        }

        func draw(in view: MTKView) {
            let cube = createCube()
            renderer?.render(points: cube, color: (0.0, 1.0, 1.0, 1.0))
            renderer?.draw(in: view)
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer?.mtkView(view, drawableSizeWillChange: size)
        }

        func createCube() -> [Vec3D] {
            let min: Float = -1.0
            let max: Float = 1.0
            let step: Float = (max - min) / 8.0

            var points: [Vec3D] = []
            for i in 0..<9 {
                let x = min + Float(i) * step
                for j in 0..<9 {
                    let y = min + Float(j) * step
                    for k in 0..<9 {
                        let z = min + Float(k) * step

                        points.append(Vec3D(x, y, z))
                    }
                }
            }
            return points
        }
    }
}
