//
//  ContentView.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI

struct ContentView: View {
   @ObservedObject private var gameEngine = GameEngine()

   @State private var showingPopulationSetup = false
   @State private var showingAboutView = false
   @State private var showingMapSetup = false
   @State private var showGrid = true

   private let framerateFormatter = configure(NumberFormatter()) {
      $0.maximumFractionDigits = 2
   }

   // MARK: - Body

   var body: some View {
      NavigationView {
         VStack(spacing: 16) {

            TilemapView(
               tilemap: self.$gameEngine.tilemap,
               isEditable: !self.gameEngine.isRunning,
               showGrid: self.$showGrid)
               .border(Color.gray)
               .padding(.horizontal)

            Group {
               Form {
                  progressionControls()//.frame(alignment: .center)

                  Button(action: { self.showingPopulationSetup.toggle() }) {
                     HStack(alignment: .center) {
                        Spacer()
                        Text("Population:")
                           .font(.caption)
                        Text(String(gameEngine.tilemap.population))
                           .font(.headline)

                        Spacer()
                        Divider()
                        Spacer()

                        Text("Generation:")
                           .font(.caption)
                        Text(String(gameEngine.generation))
                           .font(.headline)

                        Spacer()

                        indicator(for: showingPopulationSetup)
                     }
                  }.buttonStyle(PlainButtonStyle())

                  if showingPopulationSetup {
                     PopulationControls(gameEngine: gameEngine)
                  }

                  Button(action: { self.showingMapSetup.toggle() }) {
                     HStack(alignment: .center) {
                        Spacer()
                        Text("Current size:")
                        Text("\(gameEngine.tilemap.width)x\(gameEngine.tilemap.height)")
                           .fontWeight(.bold)
                        Spacer()
                        indicator(for: showingMapSetup)
                     }
                  }.buttonStyle(PlainButtonStyle())

                  if showingMapSetup {
                     SizeSetupView(gameEngine: gameEngine, showGrid: $showGrid)
                  }

                  framerateControls()
                  if gameEngine.isRunning {
                     HStack(alignment: .center) {
                        Spacer()
                        framerateIndicator()
                        Spacer()
                     }
                  }
               }
            }.buttonStyle(LifeButtonStyle())
               .navigationBarItems(trailing:
                  NavigationLink(destination: AboutView()) {
                     Text("About Conway's Game of Life")
                  }
            )
         }
      }
   }
}

// MARK: - SubViews

extension ContentView {
   private func framerateControls() -> some View {
      HStack(spacing: 8) {
         Slider(
            value: $gameEngine.idealFramerate,
            in: gameEngine.framerateRange)
         Text(framerateString(from: gameEngine.idealFramerate) + " gens/sec")
      }.padding(.horizontal, 20)
   }
   private func framerateIndicator() -> some View {
      Group {
         if gameEngine.isRunning {
            Text(framerateString(from: gameEngine.actualFrameRate) + "gens/sec")
         }
      }
   }

   private func progressionControls() -> some View {
      HStack(alignment: .center, spacing: 20) {
         Spacer()
         Button(action: gameEngine.toggleRunning) {
            HStack(spacing: 4) {
               if gameEngine.isRunning {
                  Text("Pause Simulation")
                  Image(systemName: "pause.fill")
               } else {
                  Text("Start Simulation")
                  Image(systemName: "forward.fill")
               }
            }
         }
         Button(action: gameEngine.advanceGeneration) {
            HStack(spacing: 2) {
               Text("Advance")
               Image(systemName: "forward.end.fill")
            }.disabled(gameEngine.isRunning)
         }
         Spacer()
      }
   }

   func indicator(for showing: Bool) -> some View {
      Group {
         if showing {
            Image(systemName: "chevron.up")
         } else {
            Image(systemName: "chevron.down")
         }
      }.foregroundColor(.secondary)
   }
}

// MARK: - Helpers

extension ContentView {
   private var defaultButtonBG: Color {
      Color(red: 0.5,
            green: 0.9,
            blue: 0.8,
            opacity: 0.5)
   }

   private func framerateString(from value: Double) -> String {
      framerateFormatter.string(from:
         NSNumber(value: value)) ?? "??"
   }
}

// MARK: - Setup Views

struct SizeSetupView: View {
   @Environment(\.presentationMode) var presentationMode

   @ObservedObject private var gameEngine: GameEngine
   @State private var newWidth: Double
   @State private var newHeight: Double
   @Binding private var showGrid: Bool

   private let widthHeightFormatter = configure(NumberFormatter()) {
      $0.minimum = 1
      $0.maximum = NSNumber(value: Tilemap.maxSize)
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
         slider(for: .width)
         slider(for: .height)

         Button(action: {
            self.gameEngine.resizeMap(
               width: Int(self.newWidth),
               height: Int(self.newHeight))
            self.presentationMode.wrappedValue.dismiss()
         }) {
            Text("Resize")
         }.buttonStyle(LifeButtonStyle())
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
         Slider(value: binding, in: 1...Double(Tilemap.maxSize))
         Text(widthHeightFormatter
            .string(from: NSNumber(value: binding.wrappedValue))!)
      }
   }

   private enum SliderType: String { case width, height }
}


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

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView().previewDevice(.init(stringLiteral: "iPhone XS"))
   }
}

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
