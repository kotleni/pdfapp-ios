//
//  SavedFile.swift
//  PDFapp
//
//  Created by Victor Varenik on 28.05.2022.
//

import SwiftUI

extension FetchedResults {
    func toArray() -> [SavedFile] {
        var array: [SavedFile] = []
        self.forEach { savedFile in
            array.append(savedFile as! SavedFile)
        }
        return array
    }
}
