//
//  PDFKitRepresentedView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import PDFKit
import SwiftUI

// pdfview for swiftui
struct PDFKitRepresentedView: UIViewRepresentable {
    typealias UIViewType = PDFView

    var pdfDoc: PDFDocument

    func makeUIView(context _: UIViewRepresentableContext<PDFKitRepresentedView>) -> UIViewType {
        let pdfView = PDFView()
        pdfView.document = pdfDoc
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: UIViewType, context _: UIViewRepresentableContext<PDFKitRepresentedView>) {
        pdfView.document = pdfDoc
    }
}
