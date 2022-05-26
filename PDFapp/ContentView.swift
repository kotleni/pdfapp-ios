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
            VStack {
                FilesListView(files: $files, contentView: self)
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
                print(error)
                return
            }
            
            fileUrl?.startAccessingSecurityScopedResource()
            
            do {
                try FileManager.default.createDirectory(atPath: "\(appDirPath)/documents/", withIntermediateDirectories: true, attributes: nil)
            } catch { print(error) }
            
            do {
                let data = try Data(contentsOf: result.get())
                try FileManager.default.createFile(atPath: "\(appDirPath)/documents/\(fileUrl!.lastPathComponent)", contents: data)
            } catch { print(error) }
            
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
                    let size = document.documentRef!.page(at: 1)?.getBoxRect(.mediaBox).size
                    let doc = File(name: fileName, pdfDocument: document, cgSize: size!)
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
    
    @State private var isOpenned = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                isOpenned = true
            } label: {
                VStack {
                    PDFPreview(pdfDoc: file.pdfDocument, cgSize: CGSize(width: 80.0, height: 100.0))
                    
                    Text("\(file.name)\n ")
                        .font(.system(size: 16.0))
                        .lineLimit(2)
                        .padding()
                }
                .foregroundColor(.black)
            }

        }
        .background(Color.fromIRgb(r: 244, g: 244, b: 244))
        .contentShape(RoundedRectangle(cornerRadius: 8.0))
        .previewContextMenu(preview: Group {
            PDFPreview(pdfDoc: file.pdfDocument, cgSize: file.cgSize)
        }, preferredContentSize: .constant(file.cgSize), isActive: .constant(true), presentAsSheet: false, actions: [
            UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down"), handler: { action in
                contentView.exportFile(index: index)
            }),
            
            UIAction(title: "Remove", image: UIImage(systemName: "trash"), handler: { action in
                contentView.removeFile(index: index)
            }),
        ])
        .sheet(isPresented: $isOpenned) {
            Button {
                isOpenned = false
            } label: {
                Text("Close")
                    .padding()
            }

            PDFKitRepresentedView(pdfDoc: file.pdfDocument)
        }
    }
}
