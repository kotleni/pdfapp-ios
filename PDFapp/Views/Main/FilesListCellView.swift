//
//  FilesListCellView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import SwiftUI

struct FilesListCellView: View {
    @ObservedObject var viewModel: ViewModel
    var file: File
    var index: Int
    
    @State private var isOpenned = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                isOpenned = true
            } label: {
                VStack {
                    PDFPreview(pdfDoc: file.pdfDocument, cgSize: CGSize(width: 80.0, height: 100.0))
                    
                    Text("\(file.name)")
                        .font(.system(size: 16.0))
                        .lineLimit(2)
                        .padding()
                        .foregroundColor(.black)
                }
            }

        }
        .contentShape(RoundedRectangle(cornerRadius: 8.0))
        .previewContextMenu(preview: Group {
            PDFPreview(pdfDoc: file.pdfDocument, cgSize: CGSize(width: file.cgSize.width / 1.5, height: file.cgSize.height / 1.5))
        }, preferredContentSize: .constant(file.cgSize), isActive: .constant(true), presentAsSheet: false, actions: [
            UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down"), handler: { action in
                viewModel.exportFile(index: index)
            }),
            
            UIAction(title: "Remove", image: UIImage(systemName: "trash"), handler: { action in
                viewModel.removeFile(index: index)
            }),
        ])
        .sheet(isPresented: $isOpenned) {
            ViewerView(file: file, isOpenned: $isOpenned)
        }
    }
}
