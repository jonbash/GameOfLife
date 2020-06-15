//
//  Vector.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


struct Vector {
   var x: Int
   var y: Int
}

// MARK: - Constants

extension Vector {
   static var zero: Vector {
      Vector(x: 0, y: 0)
   }
}
