//
//  PDFPageView.swift
//  PDFapp
//
//  Created by Victor Varenik on 29.05.2022.
//

import SwiftUI
import PDFKit

struct PDFPageView: View {
    let page: CGPDFPage
    // let cgSize: CGSize

    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        VStack {
            if uiImage != nil {
                Image(uiImage: uiImage!)
                    .resizable()
                    //.frame(width: cgSize.width, height: cgSize.height)
                    .scaledToFit()
                    .clipped()
                    .padding(3)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.fromIRgb(r: 210, g: 210, b: 210))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }.onAppear {
            loadPreview()
        }
    }
    
    // load preview from pdfdocument
    private func loadPreview() {
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
