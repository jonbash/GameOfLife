//
//  TilemapView.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI

struct TilemapView: View {
   @Binding var tilemap: Tilemap
   var isEditable: Bool

   var spacing: CGFloat = 0.0
   var onTileTap: ((Tile) -> Void)?

   var body: some View {
      VStack(spacing: spacing) {
         ForEach(0 ..< tilemap.height, id: \.self) { row in
            HStack(spacing: self.spacing) {
               ForEach(0 ..< self.tilemap.width, id: \.self) { column in
                  TileView(
                     tile: self.$tilemap[row, column],
                     isEditable: self.isEditable,
                     onTap: self.onTileTap)
               }
            }
         }
      }.aspectRatio(
         CGFloat(tilemap.width) / CGFloat(tilemap.height),
         contentMode: .fit)
   }
}

struct TilemapView_Previews: PreviewProvider {
   static var previews: some View {
      TilemapView(
         tilemap: Binding(get: { .random() }, set: { _ in }),
         isEditable: true)
   }
}
