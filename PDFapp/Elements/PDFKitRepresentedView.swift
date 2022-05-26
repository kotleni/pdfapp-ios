//
//  PDFKitRepresentedView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import PDFKit
import SwiftUI

struct PDFKitRepresentedView: UIViewRepresentable {
    typealias UIViewType = PDFView

    var pdfDoc: PDFDocument
    //let data: Data
    //let singlePage: Bool

    func makeUIView(context _: UIViewRepresentableContext<PDFKitRepresentedView>) -> UIViewType {
        // Create a `PDFView` and set its `PDFDocument`.
        let pdfView = PDFView()
        pdfView.document = pdfDoc
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: UIViewType, context _: UIViewRepresentableContext<PDFKitRepresentedView>) {
        pdfView.document = pdfDoc
    }
}
