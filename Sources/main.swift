import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)

app.run()
