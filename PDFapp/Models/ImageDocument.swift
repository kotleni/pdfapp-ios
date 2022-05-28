//
//  ImageDocument.swift
//  PDFapp
//
//  Created by Victor Varenik on 28.05.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.png] }

    var image: UIImage

    init(image: UIImage?) {
        self.image = image ?? UIImage()
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let image = UIImage(data: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.image = image
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: image.pngData()!)
    }
    
}
