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

    func sampleAt(x: Float32, y: Float32) -> Color {
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

    let data: Data!
    let width = 512
    let height = 512

    init() {
        let bitmap = Bundle.main.url(forResource: "Brick_512", withExtension: "data")!
        data = try! Data(contentsOf: bitmap)
    }

    func sampleAt(_ x: Float32, _ y: Float32) -> Color {
        let textureX = Int(Float(width - 1)  * x)
        let textureY = Int(Float(height - 1) * y)
        let textureIdx = (textureX + textureY * width) * 3
        let R = data[textureIdx+0]
        let G = data[textureIdx+1]
        let B = data[textureIdx+2]
        return Color(Float32(R)/255.0, Float32(G)/255.0, Float32(B)/255.0, 1.0)
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

    func sampleAt(_ x: Float32, _ y: Float32) -> Color {
        let textureX = Int(Float(width - 1)  * x)
        let textureY = Int(Float(height - 1) * y)
        let textureIdx = (textureX + textureY * width) * 4
        let R = data[textureIdx+0]
        let G = data[textureIdx+0]
        let B = data[textureIdx+1]
        let A = data[textureIdx+3]
        return Color(Float32(R)/255.0, Float32(G)/255.0, Float32(B)/255.0, Float32(A)/255.0)
    }
}

