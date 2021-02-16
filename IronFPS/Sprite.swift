//
//  Sprite.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 16.02.2021.
//

import Foundation

enum Sprite {
    case wall

    func sampleAt(x: Float32, y: Float32) -> Color {
        SpriteStorage.single.sampleAt(x, y)
    }
}

class SpriteStorage {
    static let single = SpriteStorage()

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
