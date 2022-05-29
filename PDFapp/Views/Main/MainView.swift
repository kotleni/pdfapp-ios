//
//  MainView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import SwiftUI
import PDFKit

struct MainView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            TabView {
                FilesListView(viewModel: viewModel)
                    .padding()
                    .navigationTitle("PDFapp")
                    .tabItem {
                        Label("Files", systemImage: "folder")
                    }
                
                // ---
                
                Text("not impl")
                    .tabItem {
                        Label("Subscribe", systemImage: "heart.text.square")
                    }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.isImporting = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }

                }
            }
            
        }
        .onAppear {
            viewModel.updateFilesList()
        }
        .fileExporter(isPresented: .constant(viewModel.isExporting), document: viewModel.lastItemSelected != -1 ? viewModel.files[viewModel.lastItemSelected].getPdfDocument() : nil, contentType: .pdf, defaultFilename: viewModel.lastItemSelected != -1 ? "exported-\(viewModel.files[viewModel.lastItemSelected].name)" : "unnamed.pdf", onCompletion: { result in
            viewModel.lastItemSelected = -1
            viewModel.isExporting = false
        })
        .fileImporter(isPresented: .constant(viewModel.isImporting), allowedContentTypes: [.pdf, .png, .jpeg]) { result in
            viewModel.isImporting = false
            
            do {
                let fileUrl = try result.get()
                if !fileUrl.startAccessingSecurityScopedResource() {
                    fatalError("You don't have permissions for this resource.")
                }
                
                let data = try Data(contentsOf: fileUrl)
                viewModel.createFile(name: fileUrl.lastPathComponent, data: data)
                
                fileUrl.stopAccessingSecurityScopedResource()
            } catch {
                print(error)
                return
            }
            
            viewModel.updateFilesList()
        }
    }
    
}
