//
//  color.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import SwiftUI

extension Color {
    // get color from int rgba
    static func fromIRgb(r: Int, g: Int, b: Int, a: Int = 255) -> Color {
        return Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
