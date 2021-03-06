//
//  AudioRecord.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/22/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import CoreData

class AudioRecord: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var fileName: String
    @NSManaged var duration: Double

    convenience init(name: String, fileName: String, duration: Double, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.fileName = fileName
        self.duration = duration
    }
}

extension AudioRecord {
    static var fetchRequest: NSFetchRequest<AudioRecord> {
        let request = NSFetchRequest<AudioRecord>(entityName: "AudioRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        return request
    }
}
