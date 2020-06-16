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
   var onTap: ((Tile) -> Void)?

   @Environment(\.colorScheme) var colorScheme

   var body: some View {
      Button(action: tileTapped) {
         color(for: colorScheme, isAlive: tile.isAlive)
      }.disabled(!isEditable)
   }

   func tileTapped() {
      onTap?(tile)
      tile.toggle()
   }

   func color(for systemMode: ColorScheme, isAlive: Bool) -> Color {
      !isAlive ? color(from: systemMode) : color(from: systemMode.opposite)
   }

   func color(from systemMode: ColorScheme) -> Color {
      systemMode == .dark ? .black : .white
   }
}

struct TileView_Previews: PreviewProvider {
   static var previews: some View {
      TileView(
         tile: Binding(get: { .dead }, set: { _ in }),
         isEditable: true)
   }
}


extension ColorScheme {
   var opposite: ColorScheme {
      switch self {
      case .dark: return .light
      default: return .dark
      }
   }
}
