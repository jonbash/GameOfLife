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
   static var defaultSize: Int { 25 }
   @Published var tilemap: Tilemap
   @Published private(set) var generation: Int = 0
   @Published private(set) var isRunning: Bool = false
   @Published var framerate: Double {
      didSet { frameFrequency = newFrameFrequency() }
   }

   private var bufferMap: Tilemap
   private lazy var frameFrequency = newFrameFrequency()
   private var lastUpdateTime = CFAbsoluteTimeGetCurrent()
   private let updateThread = DispatchQueue.global()

   init(
      tilemap: Tilemap = .init(width: GameEngine.defaultSize,
                               height: GameEngine.defaultSize),
      framerate: Double = 2
   ) {
      self.tilemap = tilemap
      self.bufferMap = tilemap
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

   func resizeMap(width: Int, height: Int) {
      tilemap.resize(forNewWidth: width, newHeight: height)
      bufferMap = tilemap
   }

   private func start() {
      isRunning = true
      main()
   }

   private func main() {
      self.updateThread.async { [weak self] in
         autoreleasepool {
            while self?.isRunning == true {
               guard let self = self else { return }
               let currentTime = CFAbsoluteTimeGetCurrent()
               let deltaTime = currentTime - self.lastUpdateTime
               if deltaTime < self.frameFrequency {
                  continue
               }
               self.update()
               self.lastUpdateTime = currentTime
            }
         }
      }
   }

   private func update() {
      let changes = self.bufferMap.newGenerationChanges()
      DispatchQueue.main.sync {
         self.tilemap.apply(changes)
         self.generation += 1
      }
      bufferMap = tilemap
   }

   private func stop() {
      isRunning = false
   }

   private func newFrameFrequency() -> Double {
      return CFAbsoluteTime(exactly: 1 / Double(framerate)) ?? 1
   }
}
