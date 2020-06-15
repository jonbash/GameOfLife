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
   private(set) var width: Int

   init(width: Int = 1, height: Int = 1) {
      self.tiles = Array(repeating: .dead, count: width * height)
      self.width = width
   }
}

extension Tilemap {
   var height: Int {
      get { tiles.count / width }
   }
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

// MARK: - Points

extension Tilemap {
   func point(fromIndex index: Int) -> Point {
      Point(x: index % width, y: index / width, tilemap: self)
   }

   func contains(point: Point) -> Bool {
      point.x < width && point.y < height
   }

   func tileIndex(for point: Point) -> Int {
      tileIndex(forX: point.x, y: point.y)
   }

   func tile(at point: Point) -> Tile? {
      guard self.contains(point: point) else { return nil }
      return self[point.x, point.y]
   }
}

// MARK: - Sequence

extension Tilemap: Sequence {
   struct Iterator: IteratorProtocol {
      typealias Element = Tile

      var index: Point?

      init(tilemap: Tilemap) {
         self.index = Point(tilemap: tilemap)
      }

      mutating func next() -> Tile? {
         guard
            let index = index,
            let tile = index.tilemap.tile(at: index)
            else { return nil }
         self.index = index.next()
         return tile
      }
   }

   func makeIterator() -> Iterator {
      Iterator(tilemap: self)
   }
}

extension Tilemap: Collection {
   func index(after i: Point) -> Point {
      var newIndex = i
      newIndex.tilemap = self
      return newIndex.next()
   }

   typealias Element = Tile
   typealias Index = Point

   var startIndex: Point { point(fromIndex: 0) }
   var endIndex: Point { point(fromIndex: tileCount - 1) }

   subscript(_ point: Point) -> Tile {
      get { self[point.x, point.y] }
      set { self[point.x, point.y] = newValue }
   }
}
