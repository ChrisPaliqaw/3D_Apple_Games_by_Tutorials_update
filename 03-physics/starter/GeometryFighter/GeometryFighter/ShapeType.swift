//
//  Shape.swift
//  GeometryTree
//
//  Created by Christopher Clark on 2018/9/27.
//  Copyright © 2018 Christopher Clark. All rights reserved.
//

import Foundation
// 1
enum ShapeType: CaseIterable {
    case box, sphere, pyramid, torus, capsule, cylinder, cone, tube
    // 2
    static func random() -> ShapeType {
        return ShapeType.allCases.randomElement()!
    }
}
