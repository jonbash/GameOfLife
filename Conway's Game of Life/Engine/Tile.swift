//
//  Tile.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


enum Tile: UInt8, CaseIterable {
   case dead
   case alive

   init<I: BinaryInteger>(safe rawValue: I) {
      if let tile = Tile(rawValue: UInt8(rawValue)) {
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
      self = (self == .alive) ? .dead : .alive
   }

   func toggled() -> Tile {
      return (self == .alive) ? .dead : .alive
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
