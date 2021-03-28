//
//  ViewController.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 08.02.2021.
//

import Cocoa
import IronRenderer

var screenWidth = 320
var screenHeight = 288

var playerX = 8.0
var playerY = 8.0
var playerA = 0.0

var mapHeigth = 32
var mapWidth = 32

var FOV = Double.pi / 6.0
var depth = 16.0
var stepSize = 0.05

struct Object {
    let x: Double
    let y: Double
    let sprite: Sprite
}

var objects = [Object(x:  8.5, y: 8.5, sprite: .barrel),
               Object(x:  7.5, y: 7.5, sprite: .barrel),
               Object(x: 10.5, y: 3.5, sprite: .barrel)]

var depthBuffer = Array<Double>(repeating: 0.0, count: screenWidth)

// TODO: Show a small map on the side, and also display rays that are being cast into the world.
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
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
    "#",".",".",".",".",".",".",".",".",".",".",".",".",".",".","#","#",".",".","#","#",".",".",".",".",".",".",".",".",".",".","#",
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

class ViewController: NSViewController {
    var ironScreen: Screen!

    var moveCommands = Set<Move>()
    var keyDown: Any?
    var keyUp: Any?

    let worldQueue = DispatchQueue(label: "IronFPS_Word_Queue",
                                   qos: .userInteractive)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeypressEventMonitors()
        ironScreen = .init(with: self)

        let prepareFrame = DispatchWorkItem { [unowned self] in runLoop() }
        worldQueue.async(execute: prepareFrame)
    }

    func setupKeypressEventMonitors() {
        keyDown = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { event in
            if let move = Move(keyCode: event.keyCode) {
                self.moveCommands.insert(move)
            }
            return nil
        })

        keyUp = NSEvent.addLocalMonitorForEvents(matching: .keyUp, handler: { event in
            if let move = Move(keyCode: event.keyCode) {
                self.moveCommands.remove(move)
            }
            return nil
        })
    }

    func updatePlayerPosition() {
        moveCommands.forEach { move in
            switch move {
            case .turnLeft:
                playerA -= 0.1
            case .turnRight:
                playerA += 0.1
            case .foreward:
                playerX += sin(playerA) * 0.5
                playerY += cos(playerA) * 0.5
            case .backward:
                playerX -= sin(playerA) * 0.5
                playerY -= cos(playerA) * 0.5
            // FIXME: Strafing does not work for all playerA
            // case .strafeLeft:
            //     playerX += sin(playerA) * 0.5
            //     playerY -= cos(playerA) * 0.5
            // case .strafeRight:
            //     playerX -= sin(playerA) * 0.5
            //     playerY += cos(playerA) * 0.5
            default: break
            }
        }
    }

    func runLoop() {
        DispatchQueue.main.async { [unowned self] in
            ironScreen.setNeedsDisplay()
        }
        updatePlayerPosition()
        for x in 0..<screenWidth {
            // For each column, calculate the projected ray angle into world space
            let rayAngle = (playerA - FOV / 2.0) + (Double(x) / Double(screenWidth)) * FOV;

            var distanceToWall = 0.0
            var hitWall = false

            let eyeX = sin(rayAngle) // Unit vector for ray in player space
            let eyeY = cos(rayAngle)

            var sampleX = 0.0 // How far across the texture the point should be sampled.

            while !hitWall && distanceToWall < depth {
                distanceToWall += stepSize

                let testX = Int(playerX + eyeX * distanceToWall)
                let testY = Int(playerY + eyeY * distanceToWall)

                // Test if ray is out of bounds
                if (testX < 0 || testX >= mapWidth || testY < 0 || testY >= mapHeigth) {
                    hitWall = true
                    distanceToWall = depth
                } else {
                    // Ray is inbounds so test to see if the ray cell is a wall block
                    if map[testY * mapWidth + testX] == "#" {
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

            // Update Depth Buffer
            depthBuffer[x] = distanceToWall

            let shade = Float32( depth / distanceToWall - 1 )
            for y in 0..<screenHeight {
                if y <= ceiling { // Sky
                    draw(x, y, color: .sky)
                } else if y > ceiling && y <= floor { // Wall
                    let sampleY = Double((Float32(y) - Float32(ceiling)) / (Float32(floor) - Float32(ceiling)))
                    let color = Sprite.wall.sampleAt(x: sampleX, y: sampleY).shaded(shade)
                    draw(x, y, color: color)
                } else { // Floor
                    let b = (Float32(y) - Float32(screenHeight) / 2.0) / ( Float32(screenHeight) / 2.0 )
                    draw(x, y, color: .darkGreen(shade: b ))
                }
            }
        }

        // Update and Draw Objects
        for object in objects {
            // Can the object be seen by the player ?
            let vecX = object.x - playerX
            let vecY = object.y - playerY
            let distanceFromPlayer = sqrt(vecX * vecX + vecY * vecY)

            // Calculate angle between lamp and players feet, and players looking direction
            // to determine if the object is in the players field of view
            let eyeX = sin(playerA)
            let eyeY = cos(playerA)
            var objectAngle = atan2(eyeY, eyeX) - atan2(vecY, vecX)

            if objectAngle < -.pi {
                objectAngle += 2.0 * .pi
            }
            if objectAngle > .pi {
                objectAngle -= 2.0 * .pi
            }

            let inPlayerFOV = abs(objectAngle) < FOV / 2.0

            if inPlayerFOV && distanceFromPlayer >= 2 && distanceFromPlayer < depth {
                let objectCeiling = Double(screenHeight) / 2.0 - Double(screenHeight) / distanceFromPlayer
                let objectFloor = Double(screenHeight) - objectCeiling
                let objectHeight = (objectFloor - objectCeiling)
                let objectAspectRatio = 351.0/222.0
                let objectWidth = objectHeight / objectAspectRatio

                let middleOfObject = (0.5 * (objectAngle / (FOV / 2.0)) + 0.5) * Double(screenWidth)

                for lx in stride(from: 0.0, to: objectWidth, by: 1.0) {
                    for ly in stride(from: 0.0, to: objectHeight, by: 1.0) {
                        let sampleX = lx / objectWidth
                        let sampleY = ly / objectHeight

                        let color = Sprite.barrel.sampleAt(x: sampleX, y: sampleY)
                        let objectColumn = middleOfObject + lx - (objectWidth / 2.0)
                        if objectColumn >= 0 && objectColumn < Double(screenWidth) {
                            if depthBuffer[Int(objectColumn)] >= distanceFromPlayer && color.w != 0 {
                                draw(Int(objectColumn), Int(objectCeiling + ly), color: color)
                                depthBuffer[Int(objectColumn)] = distanceFromPlayer
                            }
                        }
                    }
                }
            }
        }

        let prepareFrame = DispatchWorkItem { [unowned self] in runLoop() }
        worldQueue.async(execute: prepareFrame)
    }

    func draw(_ x: Int, _ y: Int, color: Color) {
//        screen[y * screenWidth + x] = color
        ironScreen.draw(color: color, at: Position(y, x))
    }
}

extension Color {
    static let sky = Color(25, 0, 128, 255).brga()
    static let lightGray = Color(128, 128, 128, 250).brga()
    static let gray = Color(128, 128, 128, 255).brga()
    static let darkGray = Color(52, 52, 52, 255).brga()
    static let darkGreen = Color(0, 52, 255, 255).brga()
    static let black =  Color(0, 0, 0, 255).brga()
    static let white = Color(255, 255, 255, 255).brga()
    static func white(shade: Float32) -> Color { white.shaded(shade) }
    static func darkGreen(shade: Float32) -> Color { Color(0, UInt8(52 * shade), 0, 255) }

    func shaded(_ shade: Float32) -> Color {
        let shade = Swift.min(shade, 1)
        return Color(UInt8(Float(x) * shade), UInt8(Float(y) * shade), UInt8(Float(z) * shade), w)
    }

    func brga() -> SIMD4<UInt8> {
        return SIMD4<UInt8>(z, y, x, w)
    }
}
