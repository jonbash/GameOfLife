//
//  ViewHelpers.swift
//  Conway's Game of Life
//
//  Created by Jon Bash on 2020-06-19.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import SwiftUI


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

   var uiColor: UIColor {
      self == .dark ? .black : .white
   }
}


struct LifeButtonStyle: ButtonStyle {
   private var bg: Color

   init(bg: Color? = nil) {
      self.bg = bg ?? Color(red: 0.5, green: 0.9, blue: 0.8, opacity: 0.5)
   }

   func makeBody(configuration: ButtonStyleConfiguration) -> some View {
      configuration.label
         .foregroundColor(.black)
         .padding(4)
         .background(bg)
         .cornerRadius(8)
         .shadow(radius: 2)
   }
}
