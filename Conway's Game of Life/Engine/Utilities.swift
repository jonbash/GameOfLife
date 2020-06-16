//
//  Utilities.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


@discardableResult
func configure<T>(
   _ value: T,
   with changes: (inout T) throws -> Void
) rethrows -> T {
   var value = value
   try changes(&value)
   return value
}


extension Optional where Wrapped: Comparable {
   static func < (lhs: Self, rhs: Self) -> Bool {
      guard let lhs = lhs, let rhs = rhs
         else { return false }
      return lhs < rhs
   }
}


extension BinaryFloatingPoint {
   func clamped(to clamp: Self) -> Self {
      (self > clamp) ? clamp : self
   }
}
