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

   @State private var newWidthText: String = ""
   @State private var newHeightText: String = ""
   @State private var showingAboutView = false

   private let framerateFormatter = configure(NumberFormatter()) {
      $0.maximumFractionDigits = 2
   }
   private let widthHeightFormatter = configure(NumberFormatter()) {
      $0.minimum = 1
      $0.maximum = 100
      $0.maximumFractionDigits = 0
   }

   // MARK: - Body

   var body: some View {
      VStack(spacing: 16) {
         Button(action: { self.showingAboutView = true }) {
            Text("About Conway's Game of Life")
         }

         Spacer()

         HStack {
            framerateIndicator()
            Spacer()
            populationCount()
         }.padding()

         TilemapView(
            tilemap: self.$gameEngine.tilemap,
            isEditable: !self.gameEngine.isRunning)
            .border(Color.gray)

         Group {
            mapInfo()

            Divider()

            tilemapSizeControls()
            tilemapContentControls()

            framerateControls()
            progressionControls()
         }.buttonStyle(LifeButtonStyle())
      }.sheet(isPresented: $showingAboutView) {
         AboutView()
      }
   }
}

// MARK: - SubViews

extension ContentView {
   private func tilemapSizeControls() -> some View {
      HStack(spacing: 12) {
         HStack(spacing: 8) {
            labeledTextField("W:",
                             placeholderText: "New Width",
                             binding: $newWidthText)
            labeledTextField("H:",
                             placeholderText: "New Height",
                             binding: $newHeightText)
         }
         Button(action: prepareToResizeTilemap) {
            Text("Resize")
         }.disabled(newWidth == nil || newHeight == nil)
      }
   }
   private func tilemapContentControls() -> some View {
      HStack(spacing: 8) {
         Button(action: gameEngine.randomize) {
            Text("Randomize")
         }

         Button(action: gameEngine.clear) {
            Text("Clear")
         }
      }
   }
   private func framerateControls() -> some View {
      HStack(spacing: 8) {
         Slider(
            value: $gameEngine.framerate,
            in: gameEngine.framerateRange)
         Text(framerateString(from: gameEngine.framerate) + " gens/sec")
      }.padding(.horizontal, 20)
   }
   private func framerateIndicator() -> some View {
      Group {
         if gameEngine.isRunning {
            Text(framerateString(from: gameEngine.actualFrameRate) + "gens/sec")
         } else {
            EmptyView()
         }
      }
   }
   private func populationCount() -> some View {
      Text("Population: \(gameEngine.tilemap.population)")
   }
   private func progressionControls() -> some View {
      HStack(spacing: 20) {
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
      }
   }
   private func mapInfo() -> some View {
      HStack {
         HStack {
            Text("Current size:")
            Text("\(gameEngine.tilemap.width)x\(gameEngine.tilemap.height)")
               .fontWeight(.bold)
         }.font(.caption)

         Spacer()
         Divider().frame(height: 20, alignment: .center)
         Spacer()

         Text("Generation: \(gameEngine.generation)")
            .font(.headline)
      }.padding(.horizontal, 20)
   }
}

// MARK: - Helpers

extension ContentView {
   private var newWidth: Int? {
      widthHeightFormatter.number(from: newWidthText) as? Int
   }
   private var newHeight: Int? {
      widthHeightFormatter.number(from: newHeightText) as? Int
   }

   private var defaultButtonBG: Color {
      Color(red: 0.5,
            green: 0.9,
            blue: 0.8,
            opacity: 0.5)
   }
   private func prepareToResizeTilemap() {
      guard
         let newWidth = newWidth,
         let newHeight = newHeight
         else { return }
      UIApplication.shared.windows.forEach { window in
         window.endEditing(false)
      }
      gameEngine.resizeMap(width: newWidth, height: newHeight)
   }
   private func labeledTextField(
      _ labelTitle: String,
      placeholderText: String,
      binding: Binding<String>
   ) -> some View {
      HStack(spacing: 4) {
         Text(labelTitle)
         TextField(
            placeholderText,
            text: binding)
            .keyboardType(.numberPad)
            .frame(maxWidth: 100)
      }
   }
   private func framerateString(from value: Double) -> String {
      framerateFormatter.string(from:
         NSNumber(value: value)) ?? "??"
   }
}

// MARK: - Helper Types

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}
