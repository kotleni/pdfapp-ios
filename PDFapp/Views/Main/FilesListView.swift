//
//  FilesListView.swift
//  PDFapp
//
//  Created by Victor Varenik on 26.05.2022.
//

import SwiftUI

struct FilesListView: View {
    @Binding var files: Array<File>
    var mainView: MainView
    
    let columns = Array(repeating: GridItem(.fixed(110.0), spacing: 16), count: 3)
    
    var body: some View {
        if files.count > 0 {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center) {
                    if files.count > 0 {
                        ForEach((1...files.count), id: \.self) { index in
                            let file = files[index-1]
                            let _index = index-1
                            
                            FilesListCellView(mainView: mainView, file: file, index: _index)
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
