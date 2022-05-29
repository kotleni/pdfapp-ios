//
//  ContentView.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel: ViewModel = ViewModel()
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \SavedFile.name, ascending: true)],
//        animation: .default)
//    private var savedFiles: FetchedResults<SavedFile>
    
    var body: some View {
        NavigationView {
            MainView(viewModel: viewModel)
        }
    }
}
