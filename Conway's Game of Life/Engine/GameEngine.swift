//
//  GameEngine.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import Combine


class GameEngine: ObservableObject {
   @Published var tilemap: Tilemap
   @Published var framerate: Double
   @Published private(set) var generation: Int = 0
   
   private(set) var timer: Timer?

   init(
      tilemap: Tilemap = .random(width: 20, height: 20),
      framerate: Double = 2
   ) {
      self.tilemap = tilemap
      self.framerate = framerate
   }
}

extension GameEngine {
   var framerateRange: ClosedRange<Double> { 1...60 }
   
   var isRunning: Bool { timer != nil }

   func toggleRunning() {
      isRunning ? stop() : start()
   }

   func start() {
      self.timer = makeTimer(with: framerate)
   }

   func stop() {
      self.timer?.invalidate()
      self.timer = nil
   }

   func makeTimer(with framerate: Double) -> Timer {
      .scheduledTimer(withTimeInterval: 1 / framerate, repeats: true, block: update(_:))
   }

   private func update(_ timer: Timer) {
      if timer.timeInterval != framerate {
         self.timer = makeTimer(with: framerate)
      }
      tilemap.update()
   }
}
