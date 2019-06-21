//
//  Persistence.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import CoreData

protocol PersistenceType {
    func saveChanges()
}

class Persistence: PersistenceType {

    private let persistentContainer: NSPersistentContainer

    init() {
        self.persistentContainer = NSPersistentContainer(name: "AudioRecorder")
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                assertionFailure("Unresolved error \(error)")
            }
        })
    }

    func saveChanges() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                assertionFailure("Unresolved error \(error)")
            }
        }
    }
}
