//
//  GameEngine.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import Combine
import UIKit


class GameEngine: ObservableObject {
   @Published var tilemap: Tilemap
   @Published private(set) var generation: Int = 0
   @Published private(set) var isRunning: Bool = false
   @Published var framerate: Double {
      didSet { frameFrequency = newFrameFrequency() }
   }

   private var bufferTilemap: Tilemap
   private lazy var frameFrequency = newFrameFrequency()
   private var lastUpdateTime = CFAbsoluteTimeGetCurrent()
   private let updateThread = DispatchQueue.global()

   init(
      tilemap: Tilemap = .init(width: 25, height: 25),
      framerate: Double = 2
   ) {
      self.tilemap = tilemap
      self.bufferTilemap = tilemap
      self.framerate = framerate
   }
}

extension GameEngine {
   var framerateRange: ClosedRange<Double> { 1...20 }

   func toggleRunning() {
      isRunning ? stop() : start()
   }

   func advanceGeneration() {
      self.updateThread.async {
         self.update()
      }
   }

   private func start() {
      isRunning = true
      main()
   }

   private func main() {
      self.updateThread.async { [weak self] in
         autoreleasepool {
            while self?.isRunning == true {
               let currentTime = CFAbsoluteTimeGetCurrent()
               let deltaTime = currentTime - (self?.lastUpdateTime ?? currentTime)
               if deltaTime < self?.frameFrequency {
                  usleep(4000)
                  continue
               }
               self?.update()
               self?.lastUpdateTime = currentTime
            }
         }
      }
   }

   private func stop() {
      isRunning = false
   }

   private func update() {
      tilemap.newGeneration(on: &bufferTilemap)
      DispatchQueue.main.sync {
         (self.tilemap, self.bufferTilemap) = (self.bufferTilemap, self.tilemap)
         self.generation += 1
      }
   }

   private func newFrameFrequency() -> Double {
      return CFAbsoluteTime(exactly: 1 / Double(framerate)) ?? 1
   }
}
