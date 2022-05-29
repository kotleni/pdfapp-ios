//
//  CheckBoxView.swift
//  PDFapp
//
//  Created by Victor Varenik on 29.05.2022.
//

import SwiftUI

struct CheckBoxView: View {
    @Binding var checked: Bool

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .resizable()
            .frame(width: 22, height: 22)
            .foregroundColor(Color(UIColor.systemBlue))
            //.foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
            .onTapGesture {
                self.checked.toggle()
            }
    }
}
