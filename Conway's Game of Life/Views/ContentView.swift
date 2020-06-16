//
//  ContentView.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI

struct ContentView: View {
   @ObservedObject var gameEngine = GameEngine()

   let framerateFormatter = configure(NumberFormatter()) {
      $0.maximumFractionDigits = 2
   }

   var body: some View {
      VStack {
         HStack(spacing: 8) {
            Slider(
               value: $gameEngine.framerate,
               in: gameEngine.framerateRange)
            Text(framerateString() + " gens/sec")
         }.padding(.horizontal, 20)

         Button(action: gameEngine.toggleRunning) {
            Text(gameEngine.isRunning ? "Stop" : "Start")
         }

         TilemapView(
            tilemap: $gameEngine.tilemap,
            isEditable: !gameEngine.isRunning
         )

         Text("Generation: \(gameEngine.generation)")
      }
   }

   private func framerateString() -> String {
      framerateFormatter
         .string(from: NSNumber(value: gameEngine.framerate))
         ?? "??"
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}
