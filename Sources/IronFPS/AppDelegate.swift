import AppKit
import MetalKit

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
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

        window.delegate = self

        metalView = MTKView(frame: window.contentView!.bounds, device: device)
        metalView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        metalView.autoresizingMask = [.width, .height]

        window.contentView = metalView
        window.title = "IronFPS"
        window.center()
        window.makeKeyAndOrderFront(nil)
        renderer = Renderer.init(metalKitView: metalView)
        metalView.delegate = renderer
    }

    func windowWillClose(_ notification: Notification) {
        exit(0)
    }
}
