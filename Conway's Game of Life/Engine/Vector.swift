//
//  Vector.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


struct Vector {
   var x: Int = 0
   var y: Int = 0
}

extension Vector: Equatable {}

// MARK: - Constants

extension Vector {
   static var zero: Vector { Vector(x: 0, y: 0) }

   static var up: Vector { Vector(x: 0, y: -1) }
   static var down: Vector { Vector(x: 0, y: 1) }
   static var left: Vector { Vector(x: -1, y: 0) }
   static var right: Vector { Vector(x: 1, y: 0) }

   static var upLeft: Vector { Vector(x: -1, y: -1) }
   static var upRight: Vector { Vector(x: 1, y: -1) }
   static var downLeft: Vector { Vector(x: -1, y: 1) }
   static var downRight: Vector { Vector(x: 1, y: 1) }

   static var allAdjacent: [Vector] {
      [.up, .upRight, .right, .downRight, .down, .downLeft, .left, .upLeft]
   }
}

// MARK: - Math

extension Vector {
   static func + (lhs: Vector, rhs: Vector) -> Vector {
      Vector(x: lhs.x + rhs.x, y: lhs.y + lhs.y)
   }

   static func - (lhs: Vector, rhs: Vector) -> Vector {
      Vector(x: lhs.x - rhs.x, y: lhs.y - lhs.y)
   }

   static func * (lhs: Vector, rhs: Vector) -> Vector {
      Vector(x: lhs.x * rhs.x, y: lhs.y * lhs.y)
   }

   static func / (lhs: Vector, rhs: Vector) -> Vector {
      Vector(x: lhs.x + rhs.x, y: lhs.y + lhs.y)
   }
}
