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

   let framerateText = { Text("Framerate") }

   var body: some View {
      VStack {
         HStack {
            framerateText()
            Slider(
               value: $gameEngine.framerate,
               in: gameEngine.framerateRange,
               label: framerateText)
         }
         Button(action: gameEngine.toggleRunning) {
            Text(gameEngine.isRunning ? "Stop" : "Start")
         }
         TilemapView(
            tilemap: $gameEngine.tilemap,
            isEditable: !gameEngine.isRunning) { tile in
               
         }
      }
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}
