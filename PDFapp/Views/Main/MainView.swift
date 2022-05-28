//
//  MainView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import SwiftUI
import PDFKit

struct MainView: View {
    @State private var files: Array<File> = []
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var isExportingPng = false
    @State private var lastItemSelected = -1
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedFile.name, ascending: true)],
        animation: .default)
    private var savedFiles: FetchedResults<SavedFile>
    
    var body: some View {
        VStack {
            FilesListView(files: $files, mainView: self)
                .navigationTitle("PDFapp")
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
        }
        .padding()
        .onAppear {
            updateFilesList()
        }
        .fileExporter(isPresented: $isExporting, document: lastItemSelected != -1 ? files[lastItemSelected].getMyPDFDocument() : nil, contentType: .pdf, defaultFilename: lastItemSelected != -1 ? "exported-\(files[lastItemSelected].name)" : "unnamed.pdf", onCompletion: { result in
            lastItemSelected = -1
isExporting = false
        })
        .fileExporter(isPresented: $isExportingPng, document: lastItemSelected != -1 ? ImageDocument(image: PDFPreview.getPageImage(page: files[lastItemSelected].pdfDocument.documentRef!.page(at: 1)!)) : nil, contentType: .png, defaultFilename: lastItemSelected != -1 ? "exported-\(files[lastItemSelected].name).png" : "unnamed.pdf", onCompletion: { result in
            lastItemSelected = -1
isExporting = false
        })
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.pdf, .png, .jpeg]) { result in
            isImporting = false
            
            do {
                let fileUrl = try result.get()
                if !fileUrl.startAccessingSecurityScopedResource() {
                    fatalError("You don't have permissions for this resource.")
                }
                
                let data = try Data(contentsOf: fileUrl)
                let newItem = SavedFile(context: viewContext)
                newItem.name = fileUrl.lastPathComponent
                newItem.data = data
                
                fileUrl.stopAccessingSecurityScopedResource()
                try viewContext.save()
            } catch {
                print(error)
                return
            }
            
            updateFilesList()
        }
    }
    
    private func addItem() {
        isImporting = true
    }
    
    func updateFilesList() {
        files.removeAll()
        
        savedFiles.forEach { savedFile in
            if let document = PDFDocument(data: savedFile.data!) {
                let size = document.documentRef!.page(at: 1)?.getBoxRect(.mediaBox).size
                let doc = File(name: savedFile.name!, savedFile: savedFile, pdfDocument: document, cgSize: size!)
                
                files.append(doc)
            } else {
                fatalError("document = nil")
            }
        }
    }
    
    func exportFile(index: Int) {
        lastItemSelected = index
        isExporting = true
    }
    
    func exportPng(index: Int) {
        lastItemSelected = index
        isExportingPng = true
    }
    
    func removeFile(index: Int) {
        viewContext.delete(savedFiles[index])
        do {
            try viewContext.save()
        } catch {}
        
        updateFilesList()
        
        lastItemSelected = -1
    }
}
