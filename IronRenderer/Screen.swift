//
//  Screen.swift
//  IronRenderer
//
//  Created by Mykhailo Tymchyshyn on 27.03.2021.
//

import MetalKit

public final class Screen {
    public var width: Int
    public var height: Int
    public var aspectRatio: Double { Double(width) / Double(height) }

    let mtkView: MTKView
    let renderer: Renderer

    let windowBackground = MTLClearColor(red: 0.6, green: 0.0, blue: 0.5, alpha: 1.0)

    public init(with viewController: NSViewController, resolution: Resolution) {
        mtkView = MTKView(frame: viewController.view.frame)

        width = resolution.width
        height = resolution.height

        mtkView.enableSetNeedsDisplay = true
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = windowBackground
        mtkView.setNeedsDisplay(viewController.view.frame)

        viewController.view = mtkView

        renderer = Renderer(mtkView: mtkView, width: width, height: height)

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        renderer.screen = self
        mtkView.delegate = renderer
    }

    public func draw(color: Color, at position: Position) {
        renderer.pixels![position.x * width + position.y] = color
    }

    public func frameReady() {
        mtkView.setNeedsDisplay(mtkView.frame)
    }
}

public typealias Color = SIMD4<UInt8>

public struct Position {
    let x: Int
    let y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

public struct Resolution {
    let width: Int
    let height: Int

    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
    }
}
