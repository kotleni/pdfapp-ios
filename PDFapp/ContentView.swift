//
//  ContentView.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            MainView(viewModel: viewModel)
        }
    }
}
