//
//  CoreDataManager.swift
//  PDFapp
//
//  Created by Victor Varenik on 29.05.2022.
//

import Foundation
import CoreData
import SwiftUI

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    private var viewContext = PersistenceController.shared.container.viewContext
    
    // create new saved file
    func createSavedFile(name: String, data: Data) {
        let item = SavedFile(context: viewContext)
        item.name = name
        item.data = data
        
        try! viewContext.save()
    }
    
    
    // remove saved file by id
    func removeSavedFile(index: Int) {
        let savedFiles = getSavedFiles()
        viewContext.delete(savedFiles[index])
    }
    
    // get all saved files
    func getSavedFiles() -> [SavedFile] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedFile")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedFile.name, ascending: true)]
        return try! viewContext.fetch(request) as! Array<SavedFile>
    }
}
