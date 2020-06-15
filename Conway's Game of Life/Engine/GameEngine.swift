//
//  GameEngine.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class GameEngine: ObservableObject {
   @Published var tilemap: Tilemap

   var updateInterval: TimeInterval
   @Published private(set) var timer: Timer?

   init(
      tilemap: Tilemap = .random(width: 20, height: 20),
      updateInterval: TimeInterval = 0.5
   ) {
      self.tilemap = tilemap
      self.updateInterval = updateInterval
   }
}

extension GameEngine {
   var isRunning: Bool { timer != nil }

   func toggleRunning() {
      isRunning ? stop() : start()
   }

   func start() {
      timer = .scheduledTimer(
         withTimeInterval: updateInterval,
         repeats: true,
         block: update(_:))
      timer?.fire()
   }

   func stop() {
      self.timer?.invalidate()
      self.timer = nil
   }

   private func update(_ timer: Timer) {
      tilemap.update()
   }
}
