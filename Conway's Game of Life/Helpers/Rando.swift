//
//  Rando.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


fileprivate let multiplier: UInt64 = 6364136223846793005
fileprivate let increment: UInt64 = 1442695040888963407


public struct Rando: RandomNumberGenerator {
   private(set) var seed: UInt64

   public init(seed: UInt64 = .random(in: 0..<UInt64.max)) {
      self.seed = seed
   }

   public mutating func next() -> UInt64 {
      seed = seed &* multiplier &+ increment
      return seed
   }
}


public extension Collection where Index == Int {
   func randomElement<RNG: RandomNumberGenerator>(using rng: inout RNG) -> Element? {
      if isEmpty { return nil }
      return self[startIndex + Index(rng.next() % UInt64(count))]
   }
}
