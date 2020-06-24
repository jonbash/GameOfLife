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
   @State private var showGrid = false

   private let framerateFormatter = configure(NumberFormatter()) {
      $0.maximumFractionDigits = 2
   }

   init() {
      configure(UITableView.appearance()) {
         $0.backgroundColor = .clear
         $0.tableHeaderView?.backgroundColor = .green
         $0.tableFooterView = UIView()
      }
   }

   private let topBlue = Color(UIColor(
      light: UIColor(red: 0.87, green: 0.93, blue: 1, alpha: 1),
      dark: UIColor(red: 0.08, green: 0.12, blue: 0.2, alpha: 1),
      defaultsToLight: false))
   private let bottomBlue = Color(UIColor(
      light: UIColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1),
      dark: UIColor(red: 0.25, green: 0.3, blue: 0.5, alpha: 1),
      defaultsToLight: false))
   private let themeGrayscale = Color(UIColor(
      light: .white,
      dark: .black,
      defaultsToLight: false))

   // MARK: - Body

   var body: some View {
      ZStack {
         LinearGradient(
            gradient: Gradient(colors: [
               topBlue,
               bottomBlue,
            ]),
            startPoint: .top,
            endPoint: .bottom
         )
         .edgesIgnoringSafeArea(.all)

         VStack(spacing: 16) {
            Button(action: {
               self.showingAboutView = true
            }) {
               HStack {
                  Spacer()
                  HStack {
                     Text("About Conway's Game of Life")
                     Image(systemName: "info.circle")
                  }
                  .foregroundColor(.white)
                  .padding(.horizontal)
                  .padding(.vertical, 1)
                  .background(bottomBlue)
                  .cornerRadius(10)
               }.padding(.trailing)
            }
            .shadow(color: bottomBlue.opacity(0.5), radius: 6, x: 4, y: 4)
            .shadow(color: themeGrayscale.opacity(0.8), radius: 6, x: -4, y: -4)

            TilemapView(
               tilemap: self.$gameEngine.tilemap,
               isEditable: !self.gameEngine.isRunning,
               showGrid: self.$showGrid)
               .border(Color.gray)
               .padding(.horizontal, 8)

            List {
               Section(header:
                  HStack {
                     Spacer()
                     Text("Controls".uppercased())
                        .font(.subheadline)
                     Spacer()
                  }
                  .padding(.vertical, 6)
                  .frame(alignment: .center)
                  .background(Color(UIColor(
                     light: UIColor(red: 0.99, green: 0.94, blue: 0.85, alpha: 1),
                     dark: UIColor(red: 0.4, green: 0.38, blue: 0.3, alpha: 1),
                     defaultsToLight: false)))
                  .listRowInsets(EdgeInsets(
                     top: 0,
                     leading: 0,
                     bottom: 0,
                     trailing: 0))
               ) {
                  progressionControls()
                  populationViews()
                  sizeViews()
                  framerateControls()
               }
               .listStyle(GroupedListStyle())
               .listRowBackground(Color(UIColor(
                  light: UIColor(red: 1, green: 0.97, blue: 1, alpha: 1),
                  dark: UIColor(red: 0.25, green: 0.1, blue: 0.22, alpha: 1),
                  defaultsToLight: false)))
            }
            .buttonStyle(LifeButtonStyle())
         }
         .sheet(isPresented: $showingAboutView, content: AboutView.init)
      }
   }
}

// MARK: - SubViews

extension ContentView {
   private func framerateControls() -> some View {
      Group {
         HStack(spacing: 8) {
            Slider(
               value: $gameEngine.idealFramerate,
               in: gameEngine.framerateRange)
            Text(framerateString(from: gameEngine.idealFramerate) + " gens/sec")
         }.padding(.horizontal, 20)

         if gameEngine.isRunning {
            HStack(alignment: .center) {
               Spacer()
               framerateIndicator()
               Spacer()
            }
         }
      }
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

   private func populationViews() -> some View {
      Group {
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
      }
   }

   private func sizeViews() -> some View {
      Group {
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
      }
   }

   private func indicator(for showing: Bool) -> some View {
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

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView().previewDevice(.init(stringLiteral: "iPhone XS"))
   }
}

struct DarkContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
         .previewDevice("iPhone XS")
         .transformEnvironment(\.colorScheme) { uiStyle in
            uiStyle = .dark
      }
   }
}
