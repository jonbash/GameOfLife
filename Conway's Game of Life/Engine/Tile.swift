//
//  Tile.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


enum Tile: UInt, CaseIterable {
   case dead
   case alive

   init<I: BinaryInteger>(safe rawValue: I) {
      if let tile = Tile(rawValue: UInt(rawValue)) {
         self = tile
      } else {
         self = Tile(safe: abs(Int(rawValue)) % Self.allCases.count)
      }
   }
}

extension Tile {
   var isDead: Bool { self == .dead }
   var isAlive: Bool { self == .alive }

   mutating func toggle() {
      var rawValue = self.rawValue
      rawValue += 1
      self = Tile(safe: rawValue)
   }

   func willLive(given liveNeighbors: Int) -> Bool {
      (liveNeighbors == 3) || (liveNeighbors == 2 && self.isAlive)
   }
}

// MARK: - Random

extension Tile {
   static func random<RNG: RandomNumberGenerator>(
      liveChance: Double = 0.5,
      using rng: inout RNG
   ) -> Tile {
      let deadness = Double.random(in: 0...1, using: &rng)
      if deadness < liveChance {
         return .alive
      } else {
         return .dead
      }
   }

   static func random(liveChance: Double = 0.5) -> Tile {
      var rando = Rando()
      return random(liveChance: liveChance, using: &rando)
   }
}

// MARK: - Updater

extension Tile {
   var updater: Updater {
      Updater(previousTile: self)
   }

   struct Updater {
      let previousTile: Tile

      private(set) var liveCount = 0
      private(set) var hitByMainLoop = false

      var toTile: Tile? {
         guard hitByMainLoop else { return nil }
         if liveCount == 3 || (liveCount == 2 && previousTile.isAlive) {
            return .alive
         }
         return .dead
      }

      mutating func incrementLiveCount() {
         liveCount += 1
      }

      mutating func hitWithMainLoop() {
         hitByMainLoop = true
      }
   }
}

// MARK: - Other Type Extensions

extension Collection where Element == Tile {
   var liveCount: Int {
      reduce(0) { count, tile -> Int in
         tile.isAlive ? count + 1 : count
      }
   }
}
