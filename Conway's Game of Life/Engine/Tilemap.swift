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

   init(width: Int = 1, height: Int = 1) {
      self.width = width
      self.height = height
      self.forEach({ point in
         tiles[point] = .dead
      })
      for _ in 1...8 {
         threadBuffer.add(DispatchQueue.global())
      }
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
   func newGenerationChanges() -> Set<Point> {
      self.compactMapToSet { point in
         let tileIsAlive = tiles[point]?.isAlive ?? false
         var count = 0
         var tileWillLive: Bool = false
         for neighbor in point.neighbors {
            if tiles[neighbor]?.isAlive == true {
               count += 1
            } else { continue }

            if count == 3 || (tileIsAlive && count == 2) {
               tileWillLive = true
            } else if count >= 4 {
               tileWillLive = false
               break
            }
         }
         return tileIsAlive != tileWillLive ? point : nil
      }
   }

   mutating func apply(_ changes: Set<Point>) {
      changes.forEach { point in
         if let tile = tiles[point] {
            tiles[point] = tile.toggled()
         } else {
            tiles[point] = .alive
         }
      }
   }

   mutating func toggleTile(at point: Point) {
      tiles[point] = (tiles[point] ?? .dead).toggled()
   }

   mutating func resize(forNewWidth newWidth: Int, newHeight: Int) {
      guard newWidth != width || newHeight != height
         else { return }
      width = newWidth
      height = newHeight
      self.forEach { point in
         tiles[point] = tiles[point] ?? .dead
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

// MARK: - Functional

extension Tilemap {
   private func forEach(_ body: (Point) throws -> Void) rethrows {
      for column in 0..<width {
         for row in 0..<height {
            try body(Point(x: column, y: row))
         }
      }
   }

   private func mapToSet<T: Hashable>(
      _ transform: (Point) throws -> T
   ) rethrows -> Set<T> {
      var set = Set<T>()
      try self.forEach { point in
         set.insert(try transform(point))
      }
      return set
   }

   private func compactMapToSet<T: Hashable>(
      _ transform: (Point) throws -> T?
   ) rethrows -> Set<T> {
      var set = Set<T>()
      try self.forEach { point in
         if let item = try transform(point) {
            set.insert(item)
         }
      }
      return set
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
