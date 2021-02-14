//
//  ViewController.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 08.02.2021.
//

import Cocoa
import MetalKit

var screenWidth = 320
var screenHeight = 288
let pixelSize: Float = 4

var playerX = 8.0
var playerY = 8.0
var fPlayerA = 0.0

var mapHeight = 32
var mapWidht = 32

var fFOV = Double.pi / 6.0
var depth = 16.0

let map = [
    "#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#","#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#",
    "#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#","#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#","#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#","#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#","#","#","#","#","#","#","#","#",".",".","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#",".","#","#","#",
    "#","#","#","#","#","#","#","#","#","#","#",".",".","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#",".","#","#","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#","#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#",
    "#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#","#",".",".","#","#",".",".","#","#","#","#",".",".",".",".","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#","#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#","#","#","#",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#",
]

enum Move {
    case foreward, backward, turnLeft, turnRight, strafeLeft, strafeRight

    init?(keyCode: UInt16) {
        switch keyCode {
        case 13, 126: self = .foreward
        case  1, 125: self = .backward
        case  0, 123: self = .turnLeft
        case  2, 124: self = .turnRight
        case 12: self = .strafeLeft
        case 14: self = .strafeRight
        default: return nil
        }
    }
}

var screen = Array<Color>.init(repeating: .black, count: screenWidth * screenHeight)

let windowBackground = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

class ViewController: NSViewController {
    var renderer: Renderer!
    var mtkView: MTKView!

    var keyDown = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event in
        switch Move(keyCode: event.keyCode) {
        case .turnLeft:
            fPlayerA -= 0.1
        case .turnRight:
            fPlayerA += 0.1
        case .foreward:
            playerX += sin(fPlayerA) * 0.5
            playerY += cos(fPlayerA) * 0.5
        case .backward:
            playerX -= sin(fPlayerA) * 0.5
            playerY -= cos(fPlayerA) * 0.5
            // TODO: - Fix strafing
//        case .strafeLeft:
//            playerX += sin(fPlayerA) * 0.5
//            playerY -= cos(fPlayerA) * 0.5
//        case .strafeRight:
//            playerX -= sin(fPlayerA) * 0.5
//            playerY += cos(fPlayerA) * 0.5
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
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(33)) { [unowned self] in
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

            var sampleX = 0.0 // How far across the texture the point should be sampled.

            while !hitWall && distanceToWall < depth {
                distanceToWall += 0.1

                let testX = Int(playerX + eyeX * distanceToWall)
                let testY = Int(playerY + eyeY * distanceToWall)

                // Test if ray is out of bounds
                if (testX < 0 || testX >= mapWidht || testY < 0 || testY >= mapHeight) {
                    hitWall = true
                    distanceToWall = depth
                } else {
                    // Ray is inbounds so test to see if the ray cell is a wall block
                    if map[testY * mapWidht + testX] == "#" {
                        hitWall = true

                        // Determine where ray has hit wall. Break Block boundary
                        // int 4 line segmants
                        let blockMidX = Double(testX) + 0.5
                        let blockMidY = Double(testY) + 0.5

                        // Point where ray collided with wall
                        let testPointX = playerX + eyeX * distanceToWall
                        let testPointY = playerY + eyeY * distanceToWall

                        let testAngle = atan2(testPointY - blockMidY, testPointX - blockMidX)

                        if testAngle >= .pi * 0.25 && testAngle < .pi * 0.25 {
                            sampleX = testPointY - Double(testY)
                        }
                        if testAngle >= .pi * 0.25 && testAngle < .pi * 0.75 {
                            sampleX = testPointY - Double(testY)
                        }
                        if testAngle < -.pi * 0.25 && testAngle >= -.pi * 0.75 {
                            sampleX = testPointY - Double(testY)
                        }
                        if testAngle >= .pi * 0.75 || testAngle < -.pi * 0.75 {
                            sampleX = testPointY - Double(testY)
                        }
                    }
                }
            }
            // Calculate distance to ceiling and floor
            let ceiling = Int(Double(screenHeight) / 2.0 - Double(screenHeight) / Double(distanceToWall))
            let floor = screenHeight - ceiling

            let shade = Float32( depth / distanceToWall - 1 )
            for y in 0..<screenHeight {
                if y <= ceiling { // Floor
                    let b = 1.0 - (Float32(y) - Float32(screenHeight) / 2.0) / ( Float32(screenHeight) / 2.0 )
                    screen[y * screenWidth + x] = .darkGreen(shade: b - 1.0 )
                } else if y > ceiling && y <= floor { // Wall
                    let sampleY = (Float32(y) - Float32(ceiling)) / (Float32(floor) - Float32(ceiling))
                    let color = Sprite.wall.sampleAt(x: Float32(sampleX), y: sampleY).shaded(shade)
                    screen[y * screenWidth + x] = color
                } else { // Sky
                    screen[y * screenWidth + x] = .sky
                }
            }
        }
    }
}

extension Color {
    static let sky = Color(0.1, 0.0, 0.5, 1.0)
    static let lightGray = Color(0.5, 0.5, 0.5, 1.0)
    static let gray = Color(0.5, 0.5, 0.5, 1.0)
    static let darkGray = Color(0.2, 0.2, 0.2, 1.0)
    static let darkGreen = Color(0.0, 0.2, 0.0, 1.0)
    static let black =  Color(0, 0, 0, 1)
    static let white = Color(1, 1, 1, 1)
    static func white(shade: Float32) -> Color { Color(shade, shade, shade, 1) }
    static func darkGreen(shade: Float32) -> Color { Color(0.0, 0.2*shade, 0.0, 1.0) }

    func shaded(_ shade: Float32) -> Color {
        let shade = Swift.min(shade, 1)
        return Color(x*shade, y*shade, z*shade, w)
    }
}
