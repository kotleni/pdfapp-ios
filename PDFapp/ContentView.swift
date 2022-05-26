//
//  ContentView.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    @State private var files: Array<File> = []
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var lastItemSelected = -1
    
    var body: some View {
        NavigationView {
            FilesListView(files: $files, contentView: self)
                .navigationTitle("PDFapp")
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Text("Import")
                        }
                    }
                }
                .background(Color.fromIRgb(r: 244, g: 244, b: 244))
                .onAppear {
                    updateFilesList()
                }
        }
        .fileExporter(isPresented: $isExporting, document: lastItemSelected != -1 ? files[lastItemSelected].getMyPDFDocument() : nil, contentType: .pdf, defaultFilename: lastItemSelected != -1 ? "exported-\(files[lastItemSelected].name)" : "unnamed.pdf", onCompletion: { result in
isExporting = false
        })
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.pdf, .png, .jpeg]) { result in
            isImporting = false
            
            var fileUrl: URL? = nil
            let appDirPath = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)[0].path
            
            do {
                fileUrl = try result.get()
            } catch {
                print(error.localizedDescription)
                return
            }
            
            fileUrl?.startAccessingSecurityScopedResource()
            
            do {
                try FileManager.default.createDirectory(atPath: "\(appDirPath)/documents/", withIntermediateDirectories: false, attributes: [:])
            } catch { print(error.localizedDescription) }
            
            do {
                try FileManager.default.copyItem(atPath: fileUrl!.path, toPath: "\(appDirPath)/documents/\(fileUrl!.lastPathComponent)")
            } catch { print(error.localizedDescription) }
            
            updateFilesList()
            fileUrl?.stopAccessingSecurityScopedResource()
        }
        
    }
    
    private func addItem() {
        isImporting = true
    }
    
    func updateFilesList() {
        do {
            let appDirPath = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)[0].path
            let _files = try FileManager.default.contentsOfDirectory(atPath: "\(appDirPath)/documents/")
            
            // clear list
            files.removeAll()
            
            // load all files
            _files.forEach { fileName in
                if let document = PDFDocument(url: URL.init(fileURLWithPath: "\(appDirPath)/documents/\(fileName)")) {
                    let doc = File(name: fileName, pdfDocument: document)
                    files.append(doc)
                }
            }
            
        } catch { print(error.localizedDescription) }
    }
    
    func exportFile(index: Int) {
        lastItemSelected = index
        isExporting = true
    }
    
    func removeFile(index: Int) {
        do {
            let appDirPath = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)[0].path
            try FileManager.default.removeItem(atPath: "\(appDirPath)/documents/\(files[index].name)")
        } catch { print(error.localizedDescription) }
        
        updateFilesList()
    }
}

struct FilesListView: View {
    @Binding var files: Array<File>
    var contentView: ContentView
    
    let appDirPath = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)[0].path
    let columns = Array(repeating: GridItem(.fixed(110.0), spacing: 16), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center) {
                if files.count > 0 {
                    ForEach((1...files.count), id: \.self) { index in
                        let file = files[index-1]
                        let _index = index-1
                        
                        FilesListCellView(contentView: contentView, file: file, index: _index)
                    }
                }
            }
        }
    }
}

struct FilesListCellView: View {
    var contentView: ContentView
    var file: File
    var index: Int
    
    var body: some View {
        VStack(spacing: 0) {
            PDFPreview(pdfDoc: file.pdfDocument)
            
            Text("\(file.name)\n ")
                .font(.system(size: 16.0))
                .lineLimit(2)
                .padding()
        }
        .background(Color.fromIRgb(r: 244, g: 244, b: 244))
        .contentShape(RoundedRectangle(cornerRadius: 8.0))
        .contextMenu {
            Button {
            } label: {
                Label("Convert to PDF", systemImage: "book.closed")
            }

            Button {
            } label: {
                Label("Merge", systemImage: "arrow.triangle.merge")
            }

            Button {
            } label: {
                Label("Split", systemImage: "square.split.2x1")
            }
            
            Button {
                contentView.exportFile(index: index)
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }

            Button(role: .destructive) {
                contentView.removeFile(index: index)
            } label: {
                Label("Remove", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
