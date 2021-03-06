//
//  SetupViews.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-22.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI

// MARK: - Size Setup View

struct SizeSetupView: View {
   @Environment(\.presentationMode) var presentationMode

   @ObservedObject private var gameEngine: GameEngine
   @State private var newWidth: Double
   @State private var newHeight: Double
   @Binding private var showGrid: Bool

   private let widthHeightFormatter = configure(NumberFormatter()) {
      $0.minimum = Tilemap.minSize as NSNumber
      $0.maximum = Tilemap.maxSize as NSNumber
      $0.maximumFractionDigits = 0
   }

   init(gameEngine: GameEngine, showGrid: Binding<Bool>) {
      self.gameEngine = gameEngine
      self._newWidth = State(initialValue: Double(gameEngine.tilemap.width))
      self._newHeight = State(initialValue: Double(gameEngine.tilemap.height))
      self._showGrid = showGrid
   }

   var body: some View {
      VStack(spacing: 8) {
         HStack {
            Toggle(isOn: self.$showGrid) {
               Text("Show grid")
            }
         }
         HStack {
            Toggle(isOn: self.$gameEngine.gridWraps) {
               Text("Grid wraps")
            }
         }
         slider(for: .width)
         slider(for: .height)

//         Button(action: resizeMap) {
//            Text("Resize")
//         }.buttonStyle(LifeButtonStyle())
      }.padding()
   }

   private func slider(for type: SliderType) -> some View {
      let binding: Binding<Double> = {
         switch type {
         case .width: return $newWidth
         case .height: return $newHeight
         }
      }()
      return HStack {
         Text("\(type.rawValue.capitalized):")
         Slider(value: binding, in: Double(Tilemap.minSize)...Double(Tilemap.maxSize), step: 1) { (_) in
            self.resizeMap()
         }
         Text(widthHeightFormatter
            .string(from: NSNumber(value: binding.wrappedValue))!)
      }
   }

   func resizeMap() {
      self.gameEngine.resizeMap(
         width: Int(self.newWidth),
         height: Int(self.newHeight))
   }

   private enum SliderType: String { case width, height }
}

// MARK: - Population Controls

struct PopulationControls: View {
   @ObservedObject var gameEngine: GameEngine

   @State private var density: Double = 0.5

   init(gameEngine: GameEngine) {
      self.gameEngine = gameEngine
   }

   var body: some View {
      VStack(spacing: 16) {
         VStack(spacing: 8) {
            HStack(spacing: 8) {
               Text("Density:")
               Slider(value: $density, in: 0...Tilemap.maxDensity)
            }.padding()

            HStack {
               Button(action: {
                  self.gameEngine.randomize(density: self.density)
               }) {
                  Text("Randomize")
               }
               Button(action: gameEngine.clear) {
                  Text("Clear")
               }
            }
         }
      }.buttonStyle(LifeButtonStyle())
   }
}

// MARK: - Previews

struct SizeSetupView_Previews: PreviewProvider {
   static var previews: some View {
      SizeSetupView(
         gameEngine: GameEngine(
            tilemap: Tilemap(width: 25, height: 25)),
         showGrid: Binding(
            get: { return true },
            set: { _ in }))
         .padding()
         .previewLayout(.sizeThatFits)
   }
}

struct PopulationControls_Previews: PreviewProvider {
   static var previews: some View {
      PopulationControls(gameEngine: GameEngine())
         .padding()
         .previewLayout(.sizeThatFits)
   }
}
