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
// aspect 16/9

var playerX = 8.0
var playerY = 8.0
var fPlayerA = 0.0

var mapHeight = 16
var mapWidht = 16

var fFOV = Double.pi / 4.0
var depth = 16.0

let map = [
    "#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#",
    "#","#","#","#","#","#","#","#","#","#","#","#","#","#","#","#"
]

var screen = [
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
    " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "
]

let windowBackground = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

class ViewController: NSViewController {
    var renderer: Renderer!
    var mtkView: MTKView!

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
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [unowned self] in
            debugPrint("Render new frame")
            self.runLoop()
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

//            for y in 0..<screenHeight {
//                if y < ceiling {
//                    screen[y * screenWidth + x] = " "
//                } else if y > ceiling && y <= floor {
//                    screen[y * screenWidth + x] = "#"
//                } else {
//                    screen[y * screenWidth + x] = "."
//                }
//            }

        }
    }


//    override var representedObject: Any? {
//        didSet {
//        // Update the view, if already loaded.
//        }
//    }
}
