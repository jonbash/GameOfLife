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

   init(tiles: [Tile], width: Int) {
      self.tiles = tiles
      self.width = width
   }
}

extension Tilemap {
   var height: Int {
      get { tiles.count / width }
   }
   var tileCount: Int { tiles.count }

   var as2DString: String {
      var output = ""
      for y in 0..<height {
         for x in 0..<width {
            output += tile(at: Point(x: x, y: y))?.isAlive ?? false ? "O" : " "
         }
         output += "\n"
      }
      return output
   }

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

   mutating func update() {
      var newMap = self
      let adjacentVectors = Vector.allAdjacent
      tiles.enumerated().forEach { i, tile in
         let adjacentTiles = adjacentVectors.compactMap { diff -> Tile? in
            let newIndex = i + diff.x + (diff.y * height)
            guard self.contains(tileIndex: newIndex) else { return nil }
            return self.tiles[newIndex]
         }
         newMap[i] = tile.willLive(given: adjacentTiles) ? .alive : .dead
      }
      self = newMap
   }

   func tileIndex(forX x: Int, y: Int) -> Int {
      (y * width) + x
   }

   func contains(tileIndex: Int) -> Bool {
      tileIndex < tileCount && tileIndex >= 0
   }
}

// MARK: - Points

extension Tilemap {
   typealias Point = Vector

   func point(fromIndex index: Int) -> Point {
      Point(x: index % width, y: index / width)
   }

   func contains(point: Point) -> Bool {
      point.x < width
         && point.y < height
         && point.x >= 0
         && point.y >= 0
   }

   func tileIndex(for point: Point) -> Int {
      tileIndex(forX: point.x, y: point.y)
   }

   func tile(at point: Point) -> Tile? {
      guard self.contains(point: point) else { return nil }
      return self[point.x, point.y]
   }

   func nextPoint(from point: Point) -> Point {
      self.point(fromIndex: tileIndex(for: point) + 1)
   }

   func tile(from point: Point, by diff: Vector) -> Tile? {
      tile(at: point + diff)
   }
}

// MARK: - Sequence

extension Tilemap: Sequence {
   struct Iterator: IteratorProtocol {
      var index: Point
      let tilemap: Tilemap

      init(tilemap: Tilemap) {
         self.index = Point()
         self.tilemap = tilemap
      }

      mutating func next() -> Tile? {
         guard let tile = tilemap.tile(at: index) else { return nil }
         self.index = tilemap.nextPoint(from: index)
         return tile
      }
   }

   func makeIterator() -> Iterator {
      Iterator(tilemap: self)
   }
}

// MARK: - Collection

extension Tilemap: Collection {
   subscript(position: Int) -> Tile {
      get {
         tiles[position]
      }
      set {
         tiles[position] = newValue
      }
   }

   var startIndex: Int { 0 }
   var endIndex: Int { tiles.endIndex }

   subscript(_ point: Point) -> Tile {
      get { self[point.x, point.y] }
      set { self[point.x, point.y] = newValue }
   }

   func index(after i: Int) -> Int {
      i + 1
   }
}

// MARK: - Random

extension Tilemap {
   static func random<RNG: RandomNumberGenerator>(
      width: Int,
      height: Int,
      gen: inout RNG
   ) -> Tilemap {
      var map = Tilemap(width: width, height: height)
      for i in 0 ..< map.tileCount {
         let point = map.point(fromIndex: i)
         map[point] = .random(using: &gen)
      }
      return map
   }

   static func random(width: Int = 20, height: Int = 20) -> Tilemap {
      var rando = Rando()
      return random(width: width, height: height, gen: &rando)
   }
}
