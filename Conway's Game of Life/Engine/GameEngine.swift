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
   var framerate: Double {
      didSet { frameFrequency = newFrameFrequency() }
   }

   @Published private(set) var actualFrameRate: Double = 0

   private var bufferMap: Tilemap
   private lazy var frameFrequency = newFrameFrequency()
   private var lastUpdateTime = CFAbsoluteTimeGetCurrent()
   private let updateThread = DispatchQueue.global()
   private var lock = NSLock()

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

   // MARK: - Public
   
   static var defaultSize: Int { 25 }

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

   func randomize() {
      tilemap = Tilemap.random(width: tilemap.width, height: tilemap.height)
      generation = 0
   }

   func clear() {
      tilemap = Tilemap(width: tilemap.width, height: tilemap.height)
      generation = 0
   }

   // MARK: - Game Loop

   private func start() {
      isRunning = true
      main()
   }

   private func main() {
      updateThread.async { [weak self] in
         while self?.isRunning == true {
            guard let self = self else { return }
            let currentTime = CFAbsoluteTimeGetCurrent()
            let deltaTime = currentTime - self.lastUpdateTime
            if deltaTime < self.frameFrequency {
               continue
            }
            self.lastUpdateTime = currentTime
            DispatchQueue.main.async {
               self.actualFrameRate = 1 / deltaTime
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
      bufferMap = tilemap
   }

   private func stop() {
      isRunning = false
   }

   private func newFrameFrequency() -> Double {
      return CFAbsoluteTime(exactly: 1 / Double(framerate)) ?? 1
   }
}
