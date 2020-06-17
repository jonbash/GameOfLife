//
//  TileView.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI


struct TileView: View {
   @Binding var tile: Tile
   var isEditable: Bool

   @Environment(\.colorScheme) var colorScheme

   var body: some View {
      Button(action: tileTapped) {
         color(for: colorScheme, isAlive: tile.isAlive)
      }.disabled(!isEditable)
   }

   func tileTapped() {
      tile.toggle()
   }

   private func color(for systemMode: ColorScheme, isAlive: Bool) -> Color {
      !isAlive ? systemMode.color : systemMode.opposite.color
   }
}

//struct TileView_Previews: PreviewProvider {
//   static var previews: some View {
//      TileView(
//         tile: Binding(get: { .dead }, set: { _ in }),
//         isEditable: true)
//   }
//}


extension ColorScheme {
   var opposite: ColorScheme {
      switch self {
      case .dark: return .light
      default: return .dark
      }
   }

   var color: Color {
      self == .dark ? .black : .white
   }
}
