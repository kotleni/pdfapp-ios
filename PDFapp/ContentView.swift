//
//  ContentView.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var files: Array<String> = []
    @State private var isImporting = false
    
    var body: some View {
        NavigationView {
            FilesListView(files: $files, contentView: self)
                .navigationTitle("PDFapp")
                .toolbar {
                    ToolbarItem {
                        Button(action: addItem) {
                            Text("Import file")
                        }
                    }
                }
                .background(Color.fromIRgb(r: 244, g: 244, b: 244))
                .onAppear {
                    updateFilesList()
                }
        }
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
            files = try FileManager.default.contentsOfDirectory(atPath: "\(appDirPath)/documents/")
        } catch { print(error.localizedDescription) }
    }
    
    func removeFile(index: Int) {
        do {
            let appDirPath = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)[0].path
            try FileManager.default.removeItem(atPath: "\(appDirPath)/documents/\(files[index])")
        } catch { print(error.localizedDescription) }
        
        updateFilesList()
    }
}

struct FilesListView: View {
    @Binding var files: Array<String>
    var contentView: ContentView
    
    let appDirPath = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)[0].path
    var columns = Array(repeating: GridItem(.fixed(100.0), spacing: 16), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center) {
                if files.count > 0 {
                    ForEach((1...files.count), id: \.self) { index in
                        let fileName = files[index-1]
                        let _index = index-0
                        
                        VStack {
                            PDFThumbnailRepresented(urlDoc: URL.init(fileURLWithPath: "\(appDirPath)/documents/\(fileName)"))
                            
                            Text("\(fileName)\n ")
                                //.fontWeight(.bold)
                                .font(.system(size: 16.0))
                                .lineLimit(2)
                                .padding()
                                //.padding()
                        }
                        .frame(width: 140.0, height: 200.0)
                        //.padding()
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
                            } label: {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }

                            Button(role: .destructive) {
                                contentView.removeFile(index: _index)
                            } label: {
                                Label("Remove", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
    }
}
