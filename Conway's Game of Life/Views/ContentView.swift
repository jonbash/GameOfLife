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

   private let framerateFormatter = configure(NumberFormatter()) {
      $0.maximumFractionDigits = 2
   }
   private let widthHeightFormatter = configure(NumberFormatter()) {
      $0.minimum = 1
      $0.maximum = 100
      $0.maximumFractionDigits = 0
   }

   private var newWidth: Int? {
      widthHeightFormatter.number(from: newWidthText) as? Int
   }
   private var newHeight: Int? {
      widthHeightFormatter.number(from: newHeightText) as? Int
   }

   // MARK: - Body

   var body: some View {
      VStack(spacing: 20) {
         tilemapSizeControls()

         tilemapContentControls()

         framerateControls()

         progressionControls()

         TilemapView(
            tilemap: $gameEngine.tilemap,
            isEditable: !gameEngine.isRunning)

         Text("Generation: \(gameEngine.generation)")
            .font(.headline)
      }
   }

   // MARK: - SubViews

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
            .jbButtonStyle(background: defaultButtonBG)
      }
   }

   private func tilemapContentControls() -> some View {
      HStack(spacing: 8) {
         Button(action: {
            self.gameEngine.tilemap = Tilemap.random(
               width: self.gameEngine.tilemap.width,
               height: self.gameEngine.tilemap.height)
         }) {
            Text("Randomize")
         }.jbButtonStyle(background: defaultButtonBG)

         Button(action: {
            self.gameEngine.tilemap = Tilemap(
               width: self.gameEngine.tilemap.width,
               height: self.gameEngine.tilemap.height)
         }) {
            Text("Clear")
         }.jbButtonStyle(background: defaultButtonBG)
      }
   }

   private func framerateControls() -> some View {
      HStack(spacing: 8) {
         Slider(
            value: $gameEngine.framerate,
            in: gameEngine.framerateRange)
         Text(framerateString() + " gens/sec")
      }.padding(.horizontal, 20)
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
         }.jbButtonStyle(background:
            Color(red: 0.5,
                  green: 0.9,
                  blue: 0.8,
                  opacity: 0.5))
         Button(action: gameEngine.advanceGeneration) {
            HStack(spacing: 2) {
               Text("Advance")
               Image(systemName: "forward.end.fill")
            }.disabled(gameEngine.isRunning)
               .jbButtonStyle(background: defaultButtonBG)
         }
      }
   }

   // MARK: - Helpers

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

   private func framerateString() -> String {
      framerateFormatter.string(from:
         NSNumber(value: gameEngine.framerate)) ?? "??"
   }
}

// MARK: - Helper Types

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}

fileprivate extension View {
   func jbButtonStyle<BG: View>(
      background: BG
   ) -> some View {
      self
         .foregroundColor(.black)
         .padding(4)
         .background(background)
         .cornerRadius(8)
         .shadow(radius: 2)
   }
}
