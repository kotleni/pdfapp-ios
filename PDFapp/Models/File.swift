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
    let savedFile: SavedFile
    let pdfDocument: PDFDocument
    let cgSize: CGSize
    
    // get mypdfdocument file
    func getMyPDFDocument() -> MyPDFDocument {
        return MyPDFDocument(data: savedFile.data!)
    }
}
