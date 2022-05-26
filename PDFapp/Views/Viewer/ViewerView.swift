//
//  ViewerView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import SwiftUI

struct ViewerView: View {
    var file: File
    @Binding var isOpenned: Bool
    
    var body: some View {
        Button {
            isOpenned = false
        } label: {
            Text("Close")
                .padding()
        }

        PDFKitRepresentedView(pdfDoc: file.pdfDocument)
    }
}
