//
//  Sprite.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 16.02.2021.
//

import Foundation

enum Sprite {
    case wall
    case barrel

    func sampleAt(x: Double, y: Double) -> Color {
        switch self {
        case .wall:
            return Wall.texture.sampleAt(x, y)
        case .barrel:
            return Barrel.texture.sampleAt(x, y)
        }
    }
}

class Wall {
    static let texture = Wall()

    var data = UnsafeMutablePointer<UInt8>.allocate(capacity: 512 * 512 * 3)
    let width = 512
    let height = 512

    init() {
        let bitmap = Bundle.main.url(forResource: "Brick_512", withExtension: "data")!
        let imageData = try! Data(contentsOf: bitmap)
        data.initialize(repeating: 0, count: width * height)
        imageData.copyBytes(to: data, count: imageData.count)
    }

    func sampleAt(_ x: Double, _ y: Double) -> Color {
        let textureX = Int(Double(width - 1)  * x)
        let textureY = Int(Double(height - 1) * y)
        let textureIdx = (textureX + textureY * width) * 3
        let R = data[textureIdx+0]
        let G = data[textureIdx+1]
        let B = data[textureIdx+2]
        return Color(B, G, R, UInt8.max)
    }
}

class Barrel {
    static let texture = Barrel()

    let data: Data!
    let width = 222
    let height = 351

    init() {
        let bitmap = Bundle.main.url(forResource: "Barrel_222x351", withExtension: "data")!
        data = try! Data(contentsOf: bitmap)
    }

    func sampleAt(_ x: Double, _ y: Double) -> Color {
        let textureX = Int(Double(width - 1)  * x)
        let textureY = Int(Double(height - 1) * y)
        let textureIdx = (textureX + textureY * width) * 4
        let R = data[textureIdx+0]
        let G = data[textureIdx+1]
        let B = data[textureIdx+2]
        let A = data[textureIdx+3]
        return Color(B, G, R, A)
    }
}

