import AppKit
import MetalKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var metalView: MTKView!
    var renderer: Renderer!

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 512 / 0.95, height: 512 / 0.95),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        metalView = MTKView(frame: window.contentView!.bounds, device: device)
        metalView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        metalView.autoresizingMask = [.width, .height]

        window.contentView = metalView
        window.title = "IronFPS"
        window.center()
        window.makeKeyAndOrderFront(nil)
        renderer = Renderer.init(metalKitView: metalView)
        metalView.delegate = renderer

        renderer.clearTextureBuffer(color: (1.0, 1.0, 1.0, 1.0))

        createCube()
    }

    @MainActor
    func createCube() {
        let min: Float = -1.0
        let max: Float = 1.0
        let step: Float = (max - min) / 8.0

        for i in 0..<9 {
            let x = min + Float(i) * step
            for j in 0..<9 {
                let y = min + Float(j) * step
                for k in 0..<9 {
                    let z = min + Float(k) * step

                    let point = Vec3D(x, y, z)

                    renderer.render(points: [point], color: (1.0, 0.0, 0.0, 1.0))
                }
            }
        }
    }
}
