//
//  PDFPreview.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import PDFKit
import SwiftUI

// preview of pdf document
struct PDFPreview: View {
    var pdfDoc: PDFDocument // pdf document
    var cgSize: CGSize // document preview size
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
                    .resizable()
                    .frame(width: cgSize.width, height: cgSize.height)
                    .scaledToFit()
                    .clipped()
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.fromIRgb(r: 210, g: 210, b: 210))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                // if loading
                Spinner(isAnimating: true, style: .large)
                    .frame(width: cgSize.width, height: cgSize.height)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.fromIRgb(r: 234, g: 234, b: 234))
                    )
            }
        }.onAppear {
            loadPreview()
        }
    }
    
    
    // load preview from pdfdocument
    private func loadPreview() {
        let page = pdfDoc.documentRef!.page(at: 1)!
        uiImage = PDFPreview.getPageImage(page: page)
    }
    
    static func getPageImage(page: CGPDFPage) -> UIImage {
        let pageBox: CGRect? = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageBox!.size)
        
        return renderer.image { ctx in
            ctx.cgContext.translateBy(x: 0.0, y: pageBox!.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
    }
}
