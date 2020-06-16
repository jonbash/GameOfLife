//
//  Tilemap.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import OrderedDictionary


struct Tilemap {
   private(set) var tiles = OrderedDictionary<Point, Tile>()
   private(set) var width: Int

   init(width: Int = 1, height: Int = 1) {
      self.tiles = OrderedDictionary(
         (0..<height).flatMap { column in
            (0..<width).map { row in
               (key: Point(x: row, y: column), value: Tile.dead)
            }
         }
      )
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
         let point = Point(x: x, y: y)
         return self[point]
      }
      set {
         let point = Point(x: x, y: y)
         self[point] = newValue
      }
   }

   subscript(_ point: Point) -> Tile {
      get {
         assert(tiles[point] != nil, "Index in tilemap out of range")
         return tiles[point]!
      }
      set {
         assert(tiles[point] != nil, "Index in tilemap out of range")
         tiles[point] = newValue
      }
   }

   subscript(_ position: Int) -> Tile {
      get {
         tiles[position].value
      }
      set {
         let key = tiles[position].key
         tiles[key] = newValue
      }
   }

   func newGeneration(on buffer: inout Tilemap) {
      buffer.tiles.transform { pair in
         let liveNeighborCount = pair.key.neighbors
            .compactMap(tile(at:))
            .reduce(into: 0) { count, tile in
               if tile.isAlive { count += 1 }
         }
         pair.value = self[pair.key].willLive(given: liveNeighborCount) ? .alive : .dead
      }
   }

   func tileIndex(forX x: Int, y: Int) -> Int {
      (y * width) + x
   }

   func contains(tileIndex: Int) -> Bool {
      tileIndex < tileCount && tileIndex >= 0
   }
}

// MARK: - Update

extension Tilemap {
   mutating func resize(forNewWidth newWidth: Int, newHeight: Int) {
      guard newWidth != width || newHeight != height
         else { return }
      let oldTiles = self.tiles
      self = Tilemap(width: newWidth, height: newHeight)
      for (point, tile) in oldTiles {
         guard self.contains(point: point) else { continue }
         self.tiles[point] = tile
      }
   }
}

// MARK: - Points

extension Tilemap {
   typealias Point = Vector

   func point(fromIndex index: Int) -> Point {
      Point(x: index % width, y: index / width)
   }

   func contains(point: Point) -> Bool {
      tiles.keyValuePairs[point] != nil
   }

   func tileIndex(for point: Point) -> Int {
      tileIndex(forX: point.x, y: point.y)
   }

   func tile(at point: Point) -> Tile? {
      guard self.contains(point: point) else { return nil }
      return tiles[point]
   }

   func nextPoint(from point: Point) -> Point {
      var newPoint = point
      newPoint.x += 1
      if newPoint.x >= width {
         newPoint.y += newPoint.x / width
         newPoint.x = newPoint.x % width
      }
      return newPoint
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
   var startIndex: Int { 0 }
   var endIndex: Int { tiles.endIndex }

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
