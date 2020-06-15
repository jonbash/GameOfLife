//
//  Tile.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


enum Tile {
   case dead
   case alive
}

extension Tile {
   var isDead: Bool { self == .dead }
   var isAlive: Bool { self == .alive }
}
