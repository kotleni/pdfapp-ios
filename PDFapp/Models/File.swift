//
//  File.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import Foundation
import PDFKit
import SwiftUI
import UniformTypeIdentifiers

struct File {
    let name: String
    let pdfDocument: PDFDocument
    let cgSize: CGSize
    
    
    
    func getMyPDFDocument() -> MyPDFDocument {
        return MyPDFDocument(pdfDoc: pdfDocument)
    }
}
