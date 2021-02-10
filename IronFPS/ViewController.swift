//
//  ViewController.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 08.02.2021.
//

import Cocoa
import MetalKit

var screenWidth = 160
var screenHeight = 144

var playerX = 8.0
var playerY = 8.0
var fPlayerA = 0.0

var mapHeight = 16
var mapWidht = 16

var fFOV = Double.pi / 6.0
var depth = 16.0

let map = [
    "#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".","#","#","#",".",".",".",".",".","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#"
]

enum Move {
    case foreward, backward, left, right

    init?(keyCode: UInt16) {
        switch keyCode {
        case 13, 126: self = .foreward
        case  1, 125: self = .backward
        case  0, 123: self = .left
        case  2, 124: self = .right
        default: return nil
        }
    }
}

var screen = Array<Color>.init(repeating: .black, count: 160 * 144)

let windowBackground = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

class ViewController: NSViewController {
    var renderer: Renderer!
    var mtkView: MTKView!

    var keyDown = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event in
        debugPrint(event)
        switch Move(keyCode: event.keyCode) {
        case .left:
            fPlayerA -= 0.1
        case .right:
            fPlayerA += 0.1
        case .foreward:
            playerX += sin(fPlayerA) * 0.5
            playerY += cos(fPlayerA) * 0.5
        default: break
        }
        return nil
    })

//    var keyUp = NSEvent.addLocalMonitorForEvents(matching: .keyUp, handler: { event in
//        debugPrint(Move(keyCode: event.keyCode) ?? "WASD")
//        return event
//    })

    override func viewDidLoad() {
        super.viewDidLoad()
        mtkView = MTKView(frame: view.frame)
        self.view = mtkView

        mtkView.enableSetNeedsDisplay = true
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = windowBackground

        renderer = Renderer(metalKitView: mtkView)!

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
        self.runLoop()
    }

    func runLoop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) { [unowned self] in
            self.runLoop()
            mtkView.setNeedsDisplay(mtkView.frame)
        }

        for x in 0..<screenWidth {
            // For each column, calculate the projected ray angle into world space
            let rayAngle = (fPlayerA - fFOV / 2.0) + (Double(x) / Double(screenWidth)) * fFOV;

            var distanceToWall = 0.0
            var hitWall = false

            let eyeX = sin(rayAngle) // Unit vector for ray in player space
            let eyeY = cos(rayAngle)

            while !hitWall && distanceToWall < depth {
                distanceToWall += 0.1

                let testX = Int(playerX + eyeX * distanceToWall)
                let testY = Int(playerY + eyeY * distanceToWall)

                // Test if ray is out of bounds
                if (testX < 0 || testX >= mapWidht || testY < 0 || testY >= mapHeight) {
                    hitWall = true
                    distanceToWall = depth
                } else {
                    if map[testY * mapWidht + testX] == "#" {
                        hitWall = true
                    }
                }
            }
            // Calculate distance to ceiling and floor
            let ceiling = Int(Double(screenHeight) / 2.0 - Double(screenHeight) / Double(distanceToWall))
            let floor = screenHeight - ceiling

            var color: Color
            switch distanceToWall {
            case let x where x <= depth / 4:
                color = Color.white(shade: 1)
            case let x where x <= depth / 3:
                color = Color.white(shade: 0.85)
            case let x where x <= depth / 2:
                color = Color.white(shade: 0.65)
            case let x where x < depth:
                color = Color.white(shade: 0.51)
            default:
                color = .black
            }
            for y in 0..<screenHeight {
                if y <= ceiling {
                    screen[y * screenWidth + x] = .black
                } else if y > ceiling && y <= floor {
                    screen[y * screenWidth + x] = color
                } else {
                    screen[y * screenWidth + x] = .sky
                }
            }

        }
    }
}

extension Color {
    static let sky = Color(0.5, 0.0, 0.2, 1.0)
    static let lightGray = Color(0.5, 0.5, 0.5, 1.0)
    static let gray = Color(0.5, 0.5, 0.5, 1.0)
    static let darkGray = Color(0.2, 0.2, 0.2, 1.0)
    static let black =  Color(0, 0, 0, 1)
    static let white = Color(1, 1, 1, 1)
    static func white(shade: Float32) -> Color { Color(shade, shade, shade, 1) }
}
