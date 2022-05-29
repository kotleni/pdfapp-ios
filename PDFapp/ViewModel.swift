//
//  ViewModel.swift
//  PDFapp
//
//  Created by Victor Varenik on 28.05.2022.
//

import Foundation
import SwiftUI
import PDFKit
import CoreData

class ViewModel: ObservableObject {
    // stored
    @Published var files: Array<File> = []
    @Published var isImporting = false
    @Published var isExporting = false
    @Published var lastItemSelected = -1
    
    // update files list
    func updateFilesList() {
        files.removeAll()
        
        getSavedFiles().forEach { savedFile in
            if let document = PDFDocument(data: savedFile.data!) {
                let size = document.documentRef!.page(at: 1)?.getBoxRect(.mediaBox).size
                let doc = File(name: savedFile.name!, savedFile: savedFile, pdfDocument: document, cgSize: size!)
                
                files.append(doc)
            } else {
                fatalError("document = nil")
            }
        }
    }
    
    // export pdf
    func exportFile(index: Int) {
        lastItemSelected = index
        isExporting = true
    }
    
    // create saved file
    func createFile(name: String, data: Data) {
        CoreDataManager.shared.createSavedFile(name: name, data: data)
    }
    
    // remove saved file
    func removeFile(index: Int) {
        CoreDataManager.shared.removeSavedFile(index: index)
        updateFilesList()
        
        lastItemSelected = -1
    }
    
    // get saved files
    func getSavedFiles() -> [SavedFile] {
        return CoreDataManager.shared.getSavedFiles()
    }
}
