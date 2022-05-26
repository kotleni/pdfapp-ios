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
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedFile.name, ascending: true)],
        animation: .default)
    private var savedFiles: FetchedResults<SavedFile>
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.fromIRgb(r: 244, g: 244, b: 244)
                    .ignoresSafeArea()
            
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
                .onAppear {
                    updateFilesList()
                }
            }
        }
        .fileExporter(isPresented: $isExporting, document: lastItemSelected != -1 ? files[lastItemSelected].getMyPDFDocument() : nil, contentType: .pdf, defaultFilename: lastItemSelected != -1 ? "exported-\(files[lastItemSelected].name)" : "unnamed.pdf", onCompletion: { result in
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
        
        lastItemSelected = -1
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

struct FilesListView: View {
    @Binding var files: Array<File>
    var contentView: ContentView
    
    let columns = Array(repeating: GridItem(.fixed(110.0), spacing: 16), count: 3)
    
    var body: some View {
        if files.count > 0 {
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
        } else {
            VStack {
                Image(systemName: "folder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding()
                Text("You don't have any files.")
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
            PDFPreview(pdfDoc: file.pdfDocument, cgSize: CGSize(width: file.cgSize.width / 1.5, height: file.cgSize.height / 1.5))
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
