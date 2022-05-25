//
//  PDFThumbnailRepresented.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import PDFKit
import SwiftUI

struct PDFThumbnailRepresented : UIViewRepresentable {
    var pdfView = PDFView()
    var thumbnail = PDFThumbnailView()
    var urlDoc: URL
    
    func makeUIView(context: Context) -> PDFThumbnailView {
        thumbnail.pdfView = pdfView
        thumbnail.backgroundColor = .clear
        thumbnail.layoutMode = .vertical
        thumbnail.thumbnailSize = CGSize(width: 60, height: 100)
//
//        thumbnail.pdfView?
//            .cornerRadius(5)
//            .overlay(
//                RoundedRectangle(cornerRadius: 5)
//                    //.stroke(lineWidth: 1)
//                    //.frame(width: 100.0, height: 180.0)
//                    .fill()
//                    .foregroundColor(.white))
        
        return thumbnail
    }
    
    func updateUIView(_ uiView: PDFThumbnailView, context: Context) {
        if let document = PDFDocument(url: urlDoc) {
            pdfView.document = document
        }
        
        uiView.pdfView?.backgroundColor = .clear
        uiView.pdfView?.documentView?.backgroundColor = .clear
    }
}
