//
//  ViewerView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import SwiftUI
import PDFKit

struct ViewerView: View {
    var file: File
    
    @Binding var isOpenned: Bool
    //@State var currentPage: Int = 0 // not implemented
    @State var selectedPages: [Bool] = []
    
    var body: some View {
        Capsule()
                .fill(Color.secondary)
                .opacity(0.4)
                .frame(width: 70, height: 2.5)
                .padding(10)
        
//        Button {
//            isOpenned = false
//        } label: {
//            Text("Close")
//                .padding()
//        }
        
        Spacer()
        
        HStack(spacing: 30) {
            ForEach((0...file.pdfDocument.pageCount-1), id: \.self) { pageIndex in
                if selectedPages.count != 0 {
                    PageViewerView(page: file.pdfDocument.documentRef!.page(at: pageIndex+1)!, isChecked: $selectedPages[pageIndex])
                        .frame(width: 300, height: nil)
                }
            }
        }
        .modifier(ScrollingHStackModifier(items: file.pdfDocument.pageCount, itemWidth: 300, itemSpacing: 30, currentItemChange: { index in
            // not implemented
            // currentPage = index
        }))
        .onAppear {
            if selectedPages.count == 0 {
                selectedPages = Array(repeating: false, count: file.pdfDocument.pageCount)
            }
        }
        
        Spacer()
        
        // not implemented
//        Text("\(currentPage) / \(file.pdfDocument.pageCount)")
//            .font(.system(size: 12))
    }
}

struct PageViewerView: View {
    let page: CGPDFPage
    @Binding var isChecked: Bool
    
    var body: some View {
        VStack {
            CheckBoxView(checked: $isChecked)
            PDFPageView(page: page)
                .contextMenu {
                    Text("Page number: \(page.pageNumber)")
                    Text("Page size: \(Int(page.getBoxRect(.mediaBox).width))x\(Int(page.getBoxRect(.mediaBox).height))")
                }
        }
    }
}
