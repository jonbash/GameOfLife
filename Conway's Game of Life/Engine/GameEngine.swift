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
   var updateInterval: TimeInterval

   private(set) lazy var timer = Timer.TimerPublisher(
      interval: updateInterval,
      runLoop: .current,
      mode: .default)
   private var updateSink: AnyCancellable?

   init(
      tilemap: Tilemap = .random(width: 20, height: 20),
      updateInterval: TimeInterval = 0.5
   ) {
      self.tilemap = tilemap
      self.updateInterval = updateInterval
   }
}

extension GameEngine {
   var isRunning: Bool { updateSink != nil }

   func toggleRunning() {
      isRunning ? stop() : start()
   }

   func start() {
      updateSink = timer
         .sink { _ in self.tilemap.update() }
   }

   func stop() {
      updateSink = nil
   }
}
