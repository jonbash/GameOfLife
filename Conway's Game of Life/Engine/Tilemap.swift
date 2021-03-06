//
//  Tilemap.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


typealias Point = Vector


struct Tilemap {
   private var tiles = [Point: Tile]()
   private(set) var width: Int = 1
   private(set) var height: Int = 1

   private(set) var population: Int = 0

   var gridWraps = true

   init(width: Int = 1, height: Int = 1) {
      self.width = width
      self.height = height
      self.forEach { tiles[$0] = .dead }
   }
}

extension Tilemap {
   static var maxDensity: Double { 0.9 }
   static var defaultSize: Int { 32 }
   static var minSize: Int { 8 }
   static var maxSize: Int { 128 }
}

// MARK: - Subscripts

extension Tilemap {
   subscript(_ point: Point) -> Tile {
      get { tiles[wrapPoint(point), default: .dead] }
      set { tiles[wrapPoint(point)] = newValue }
   }

   subscript(_ x: Int, _ y: Int) -> Tile? {
      get { tiles[Point(x: x, y: y)] }
   }
}

// MARK: - Update

extension Tilemap {
   func newGenerationChanges() -> Set<Point> {
      self.compactMapToSet { point in
         let tileIsAlive = self[point].isAlive
         var count = 0
         var tileWillLive: Bool = false
         for neighbor in point.neighbors {
            if self[neighbor].isAlive == true {
               count += 1
            } else { continue }

            if count == 3 || (tileIsAlive && count == 2) {
               tileWillLive = true
            } else if count >= 4 || (tileIsAlive && count >= 3) {
               tileWillLive = false
               break
            }
         }
         return tileIsAlive != tileWillLive ? point : nil
      }
   }

   mutating func apply(_ changes: Set<Point>) {
      changes.forEach { point in
         let tile = self[point]
         population += tile.isDead ? 1 : -1
         tiles[point] = tile.toggled()
      }
   }

   mutating func resize(forNewWidth newWidth: Int, newHeight: Int) {
      guard newWidth != width || newHeight != height
         else { return }
      width = newWidth
      height = newHeight
      population = 0
      self.forEach { point in
         guard self.contains(point: point) else {
            self.tiles[point] = nil
            return
         }
         let tile = tiles[point] ?? .dead
         tiles[point] = tile
         if tile.isAlive {
            population += 1
         }
      }
   }
}

// MARK: - Tiles / Points

extension Tilemap {
   func contains(point: Point) -> Bool {
      (0..<width).contains(point.x) && (0..<height).contains(point.y)
   }

   func tile(at point: Point) -> Tile? {
      guard self.contains(point: wrapPoint(point)) else { return nil }
      return tiles[point]
   }

   mutating func toggleTile(at point: Point) {
      let p = wrapPoint(point)
      guard self.contains(point: p) else {
         tiles[point] = nil
         return
      }
      self[p] = self[p].toggled()
      if self[p].isAlive {
         population += 1
      } else {
         population -= 1
      }
   }

   mutating func setTile(_ tile: Tile, for point: Point) {
      let p = wrapPoint(point)
      guard self.contains(point: p) else {
         tiles[p] = nil
         return
      }
      let oldTile = self[point]
      self[point] = tile
      guard oldTile != tile else { return }
      population += tile.isAlive ? 1 : -1
   }

   func wrapPoint(_ point: Point) -> Point {
      guard gridWraps else { return point }
      var p = point

      while p.x < 0 {
         p.x += width
      }
      while p.y < 0 {
         p.y += height
      }
      while p.x >= width {
         p.x -= width
      }
      while p.y >= height {
         p.y -= height
      }
      
      return p
   }
}

// MARK: - Functional

extension Tilemap {
   func forEach(_ body: (Point) throws -> Void) rethrows {
      for column in 0..<width {
         for row in 0..<height {
            try body(Point(x: column, y: row))
         }
      }
   }

   func mapToSet<T: Hashable>(
      _ transform: (Point) throws -> T
   ) rethrows -> Set<T> {
      var set = Set<T>()
      try self.forEach { point in
         set.insert(try transform(point))
      }
      return set
   }

   func compactMapToSet<T: Hashable>(
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
      width: Int = defaultSize,
      height: Int = defaultSize,
      density: Double = 0.5,
      gen: inout RNG
   ) -> Tilemap {
      let density = density > maxDensity ? maxDensity : density

      let totalTiles = Double(width * height)
      let populatedTiles = Int(density * totalTiles)
      var map = Tilemap(width: width, height: height)

      func newPoint() -> Point {
         return Point(
            x: Int.random(in: 0..<width, using: &gen),
            y: Int.random(in: 0..<height, using: &gen))
      }

      for _ in 0..<populatedTiles {
         var point = newPoint()
         while map.tile(at: point) == .alive {
            point = newPoint()
         }
         map.setTile(.alive, for: point)
      }

      return map
   }

   static func random(
      width: Int = defaultSize,
      height: Int = defaultSize,
      density: Double = 0.5,
      seed: UInt64? = nil
   ) -> Tilemap {
      var rando: Rando
      if let seed = seed {
         rando = Rando(seed: seed)
      } else {
         rando = Rando()
      }
      return random(width: width, height: height, density: density, gen: &rando)
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
            output += (tile(at: Point(x: x, y: y))?.isAlive == true) ? "O" : " "
         }
         output += "\n"
      }
      return output
   }
}
