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

   @State var newWidthText: String = ""
   @State var newHeightText: String = ""

   let framerateFormatter = configure(NumberFormatter()) {
      $0.maximumFractionDigits = 2
   }

   var body: some View {
      VStack(spacing: 20) {
         HStack(spacing: 12) {
            HStack(spacing: 8) {
               labeledTextField("W:",
                                placeholderText: "Width",
                                binding: $newWidthText)
               labeledTextField("H:",
                                placeholderText: "Height",
                                binding: $newWidthText)
            }

         }

         HStack(spacing: 8) {
            Slider(
               value: $gameEngine.framerate,
               in: gameEngine.framerateRange)
            Text(framerateString() + " gens/sec")
         }.padding(.horizontal, 20)

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
                  .jbButtonStyle(background:
                     Color(red: 0.5,
                           green: 0.9,
                           blue: 0.8,
                           opacity: 0.5))
            }
         }

         TilemapView(
            tilemap: $gameEngine.tilemap,
            isEditable: !gameEngine.isRunning
         )

         Text("Generation: \(gameEngine.generation)")
            .font(.headline)
      }
   }

   private func labeledTextField(
      _ labelTitle: String,
      placeholderText: String,
      binding: Binding<String>
   ) -> some View {
      HStack(spacing: 4) {
         Text(labelTitle)
         TextField(placeholderText, text: binding)
            .frame(idealWidth: 80, maxWidth: 80)
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
