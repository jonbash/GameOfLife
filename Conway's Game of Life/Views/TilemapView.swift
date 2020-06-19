//
//  TilemapView.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-15.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI


struct TilemapView: UIViewRepresentable {
   @Binding var tilemap: Tilemap
   var isEditable: Bool

   @Environment(\.colorScheme) var colorScheme

   private let spacing: CGFloat = 0.0

   func makeUIView(context: Context) -> UITilemapView {
      let view = UITilemapView(tilemap: $tilemap)
      view.isEditable = isEditable
      return view
   }

   func updateUIView(_ uiView: UITilemapView, context: Context) {
      uiView.isEditable = isEditable
      uiView.tilemapSize = CGSize(width: tilemap.width, height: tilemap.height)
      uiView.setNeedsDisplay()
   }
}

struct TilemapView_Previews: PreviewProvider {
   static var previews: some View {
      TilemapView(
         tilemap: Binding(get: { .random() }, set: { _ in }),
         isEditable: true)
   }
}


class UITilemapView: UIView {
   @Environment(\.colorScheme) var colorScheme

   @Binding var tilemap: Tilemap

   var isEditable: Bool = true

   lazy var tilemapSize = CGSize(width: tilemap.width, height: tilemap.height)

   init(tilemap: Binding<Tilemap>) {
      self._tilemap = tilemap
      super.init(frame: .zero)
   }

   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   override func draw(_ rect: CGRect) {
      let liveColor = UIColor.black // TODO: update from environment
      let deadColor = UIColor.white
      let tileSize = CGSize(
         width: rect.width / tilemapSize.width,
         height: rect.height / tilemapSize.height)
      print("rect size: \(rect.size)")
      print("tile size: \(tileSize)")
      for column in 0..<tilemap.width {
         for row in 0..<tilemap.height {
            guard let tile = tilemap.tile(at: Point(x: column, y: row))
               else { continue }
            let origin = CGPoint(
               x: CGFloat(column) * tileSize.width,
               y: CGFloat(row) * tileSize.height)
            if tile.isAlive {
               liveColor.set()
            } else {
               deadColor.set()
            }
            UIRectFill(CGRect(origin: origin, size: tileSize))
         }
      }
   }
}
