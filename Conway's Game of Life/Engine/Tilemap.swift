//
//  Tilemap.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import OrderedDictionary


typealias Point = Vector


struct Tilemap {
   private var tiles = [Point: Tile]()
   private(set) var width: Int
   private(set) var height: Int

   private var buffer = [Point: Tile]()

   init(width: Int = 1, height: Int = 1) {
      self.tiles = Tilemap.makeTiles(forWidth: width, height: height)
      self.buffer = tiles
      self.width = width
      self.height = height
   }
}

// MARK: - Subscripts

extension Tilemap {
   subscript(_ point: Point) -> Tile {
      get { tiles[point, default: .dead] }
      set { tiles[point] = newValue }
   }

   subscript(_ x: Int, _ y: Int) -> Tile? {
      get { tiles[Point(x: x, y: y)] }
   }
}

// MARK: - Update

extension Tilemap {
   mutating func newGeneration() {
      tiles.forEach { point, tile in
         evolve(at: point, tile: tile)
      }
      (tiles, buffer) = (buffer, tiles)
   }

   private mutating func evolve(at point: Point, tile: Tile) {
      let liveNeighborCount = point.neighbors
         .compactMap(tile(at:))
         .filter(\.isAlive)
         .count
      buffer[point] = tile.willLive(given: liveNeighborCount) ? .alive : .dead
   }

   mutating func toggleTile(at point: Point) {
      guard var tile = tiles[point] else { return }
      tile.toggle()
      tiles[point] = tile
   }

   mutating func resize(forNewWidth newWidth: Int, newHeight: Int) {
      guard newWidth != width || newHeight != height
         else { return }

      self.buffer = tiles
   }

   static func makeTiles(forWidth width: Int, height: Int) -> [Point: Tile] {
      var tiles = [Point: Tile]()
      for column in 0..<height {
         for row in 0..<width {
            tiles[Point(x: row, y: column)] = .dead
         }
      }
      return tiles
   }

   private mutating func forEach(_ body: (Point) throws -> Void) rethrows {
      for column in 0..<height {
         for row in 0..<width {
            try body(Point(x: row, y: column))
         }
      }
   }
}

// MARK: - Tiles / Points

extension Tilemap {
   var tileCount: Int { tiles.count }

   func contains(point: Point) -> Bool {
      (0..<width).contains(point.x) && (0..<height).contains(point.y)
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

// MARK: - Random

extension Tilemap {
   static func random<RNG: RandomNumberGenerator>(
      width: Int = 25,
      height: Int = 25,
      liveRatio: Double = 0.5,
      gen: inout RNG
   ) -> Tilemap {
      var map = Tilemap(width: width, height: height)
      for point in map.tiles.keys {
         map.tiles[point] = .random(liveChance: liveRatio, using: &gen)
      }

      return map
   }

   static func random(
      width: Int = 25,
      height: Int = 25,
      liveRatio: Double = 0.5
   ) -> Tilemap {
      var rando = Rando()
      return random(width: width, height: height, liveRatio: liveRatio, gen: &rando)
   }
}

// MARK: - String Convertible

extension Tilemap: CustomStringConvertible {
   var description: String {
      self.as2DString
   }

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
}
