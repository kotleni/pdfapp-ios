//
//  String.swift
//  PDFapp
//
//  Created by Victor Varenik on 25.05.2022.
//

import Foundation

extension String {
    func sliceByLen(maxLen: Int) -> String {
        return self.prefix(maxLen).base
    }
}
