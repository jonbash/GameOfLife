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

   var body: some View {
      VStack {
         Button(action: gameEngine.toggleRunning) {
            Text(gameEngine.isRunning ? "Stop" : "Start")
         }
         TilemapView(
            tilemap: $gameEngine.tilemap,
            isEditable: !gameEngine.isRunning)
      }
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}
