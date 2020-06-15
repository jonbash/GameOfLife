//
//  Point.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


extension Tilemap {
   struct Point {
      var tilemap: Tilemap
      var x: Int
      var y: Int

      init(x: Int = 0, y: Int = 0, tilemap: Tilemap = .init()) {
         self.tilemap = tilemap
         self.x = x
         self.y = y
      }
   }
}

extension Tilemap.Point {
   var tileIndex: Int { tilemap.tileIndex(for: self) }
   var tile: Tile? { tilemap.tile(at: self) }
   var isOnMap: Bool { tilemap.contains(point: self) }

   func next() -> Self {
      let index = tilemap.tileIndex(for: self) + 1
      return tilemap.point(fromIndex: index)
   }
}

// MARK: - Comparable

extension Tilemap.Point: Comparable {
   static func == (lhs: Tilemap.Point, rhs: Tilemap.Point) -> Bool {
      lhs.tilemap.width == rhs.tilemap.width
         && lhs.tilemap.height == rhs.tilemap.height
         && lhs.x == rhs.x
         && lhs.y == rhs.y
   }

   static func < (lhs: Tilemap.Point, rhs: Tilemap.Point) -> Bool {
      lhs.tileIndex < rhs.tileIndex
   }
}
