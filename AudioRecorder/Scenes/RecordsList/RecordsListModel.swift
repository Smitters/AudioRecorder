//
//  RecordListModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import RxSwift
import RxRelay
import CoreData

class RecordsListModel: NSObject {

    private let persistence: Persistence
    private let fetchedResultController: NSFetchedResultsController<AudioRecord>
    private let recordPLayer = RecordPlayer()

    let recordsSubject = BehaviorRelay<[AudioRecord]>(value: [])

    init(persistence: Persistence) {
        self.persistence = persistence

        fetchedResultController = NSFetchedResultsController(fetchRequest: AudioRecord.fetchRequest,
                                                             managedObjectContext: persistence.viewContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: "records_cache")

        super.init()
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        recordsSubject.accept(fetchedResultController.fetchedObjects ?? [])
    }

    func deleteItem(at index: Int) {
        let item = fetchedResultController.object(at: IndexPath(row: index, section: 0))
        persistence.viewContext.delete(item)
        persistence.saveChanges()
    }
}

extension RecordsListModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {

        recordsSubject.accept(fetchedResultController.fetchedObjects ?? [])
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        recordsSubject.accept(fetchedResultController.fetchedObjects ?? [])
    }
}
