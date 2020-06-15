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

   var body: some View {
      Button(action: tileTapped) {
         Color(white: tile.isAlive ? 1 : 0)
      }.disabled(!isEditable)
   }

   func tileTapped() {
      tile.toggle()
   }
}

struct TileView_Previews: PreviewProvider {
   static var previews: some View {
      TileView(
         tile: Binding(get: { .dead }, set: { _ in }),
         isEditable: true)
   }
}
