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
   @Published var tilemap: Tilemap {
      didSet { bufferMap = tilemap }
   }
   @Published private(set) var generation: Int = 0
   @Published private(set) var isRunning: Bool = false
   @Published private(set) var actualFrameRate: Double = 0
   @Published var gridWraps: Bool {
      didSet {
         tilemap.gridWraps = gridWraps
         bufferMap.gridWraps = gridWraps
      }
   }
   var requestedFramerate: Double = 2 {
      didSet { deltaTimeThreshold = newDeltaTimeThreshold() }
   }

   private var bufferMap: Tilemap
   private lazy var deltaTimeThreshold = newDeltaTimeThreshold()
   private var lastUpdateTime = CFAbsoluteTimeGetCurrent()
   private let updateThread = DispatchQueue.global()

   init(
      tilemap: Tilemap = .init(width: Tilemap.defaultSize,
                               height: Tilemap.defaultSize)
   ) {
      self.tilemap = tilemap
      self.bufferMap = tilemap
      self.gridWraps = tilemap.gridWraps
   }
}

// MARK: - Public

extension GameEngine {
   var framerateRange: ClosedRange<Double> { 1...20 }

   func toggleRunning() {
      isRunning ? stop() : start()
   }

   func advanceGeneration() {
      updateThread.async {
         self.update()
      }
   }

   func resizeMap(width: Int, height: Int) {
      tilemap.resize(forNewWidth: width, newHeight: height)
      bufferMap = tilemap
   }

   func randomize(density: Double) {
      tilemap = Tilemap.random(
         width: tilemap.width,
         height: tilemap.height,
         density: density)
      tilemap.gridWraps = gridWraps
      generation = 0
   }

   func clear() {
      tilemap = Tilemap(width: tilemap.width, height: tilemap.height)
      tilemap.gridWraps = gridWraps
      generation = 0
   }
}

// MARK: - Game Loop

extension GameEngine {
   func start() {
      guard !isRunning else { return }
      isRunning = true
      main()
   }

   private func main() {
      updateThread.async { [weak self] in
         while self?.isRunning == true {
            guard let self = self else { return }
            let currentTime = CFAbsoluteTimeGetCurrent()
            let deltaTime = currentTime - self.lastUpdateTime
            if deltaTime < self.deltaTimeThreshold {
               continue
            }
            self.lastUpdateTime = currentTime
            let computedFramerate = 1 / deltaTime
            DispatchQueue.main.async {
               self.actualFrameRate = computedFramerate
            }
            DispatchQueue.global().sync {
               self.update()
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
   }

   func stop() {
      isRunning = false
   }

   private func newDeltaTimeThreshold() -> Double {
      CFAbsoluteTime(exactly: 1 / Double(requestedFramerate)) ?? 1
   }
}
