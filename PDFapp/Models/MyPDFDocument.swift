//
//  MyPDFDocument.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import Foundation
import PDFKit
import SwiftUI
import UniformTypeIdentifiers

struct MyPDFDocument: FileDocument {
    static var readableContentTypes = [UTType.pdf]
    static var writableContentTypes = [UTType.pdf]

    var data: Data?
    
    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.data = data
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: self.data!)
    }
}
