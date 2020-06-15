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
}


// MARK: - Random

extension Tile {
   static func random<RNG: RandomNumberGenerator>(
      using rng: inout RNG
   ) -> Tile {
      let rawValue = UInt.random(in: 0 ..< UInt(Self.allCases.count), using: &rng)
      return Tile(safe: rawValue)
   }

   static func random() -> Tile {
      var rando = Rando()
      return random(using: &rando)
   }
}
