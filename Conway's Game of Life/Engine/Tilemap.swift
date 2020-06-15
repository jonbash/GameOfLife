//
//  Tilemap.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


struct Tilemap {
   private(set) var tiles: [Tile]
   var width: Int

   init(width: Int, height: Int) {
      self.tiles = Array(repeating: .dead, count: width * height)
      self.width = width
   }
}

extension Tilemap {
   typealias Point = Vector
   
   var height: Int { tiles.count / width }
   var tileCount: Int { tiles.count }

   subscript(_ x: Int, _ y: Int) -> Tile {
      get {
         let index = tileIndex(forX: x, y: y)
         assert(self.contains(tileIndex: index),
                "Index for tilemap out of range; \(#function) in \(#file)")
         return tiles[index]
      }
      set {
         let index = tileIndex(forX: x, y: y)
         assert(self.contains(tileIndex: index),
                "Index for tilemap out of range; \(#function) in \(#file)")
         tiles[index] = newValue
      }
   }

   func tileIndex(forX x: Int, y: Int) -> Int {
      (y * width) + x
   }

   func contains(tileIndex: Int) -> Bool {
      tileIndex < tileCount
   }
}

// MARK: - Vectors

extension Tilemap {
   func contains(point: Point) -> Bool {
      point.x < width && point.y < height
   }

   func tileIndex(for point: Point) -> Int {
      tileIndex(forX: point.x, y: point.y)
   }

   func point(fromIndex index: Int) -> Point {
      Point(x: index % width, y: index / width)
   }
   
   func tile(at point: Point) -> Tile? {
      guard self.contains(point: point) else { return nil }
      return self[point.x, point.y]
   }

   func nextPoint(from point: Point) -> Point? {
      var index = tileIndex(for: point)
      index += 1
      guard self.contains(tileIndex: index) else { return nil }
      return self.point(fromIndex: index)
   }
}

// MARK: - Sequence / Collection

extension Tilemap: Sequence {
   struct Iterator: IteratorProtocol {
      typealias Element = Tile
      var tilemap: Tilemap
      var index: Point = .zero

      mutating func next() -> Tile? {
         guard
            let tile = tilemap.tile(at: index),
            let index = tilemap.nextPoint(from: index)
            else { return nil }
         self.index = index
         return tile
      }
   }

   __consuming func makeIterator() -> Iterator {
      Iterator(tilemap: self)
   }
}
