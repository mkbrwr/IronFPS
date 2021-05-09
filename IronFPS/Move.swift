//
//  Move.swift
//  IronFPS
//
//  Created by Mykhailo Tymchyshyn on 28.03.2021.
//

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
