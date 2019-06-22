//
//  RecordListModel.swift
//  AudioRecorder
//
//  Created by Smetankin Dmitry on 6/20/19.
//  Copyright © 2019 Smetankin. All rights reserved.
//

import RxSwift
import CoreData

class RecordsListModel: NSObject {

    private let persistence: Persistence
    private let fetchedResultController: NSFetchedResultsController<AudioRecord>
    let recordsSubject = BehaviorSubject<[AudioRecord]>(value: [])

    init(persistence: Persistence) {
        self.persistence = persistence

        fetchedResultController = NSFetchedResultsController(fetchRequest: AudioRecord.fetchRequest,
                                                             managedObjectContext: persistence.viewContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: "records_cache")

        super.init()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
            recordsSubject.onNext(fetchedResultController.fetchedObjects ?? [])
        } catch {
            recordsSubject.onError(error)
        }
    }
}

extension RecordsListModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {

        recordsSubject.onNext(fetchedResultController.fetchedObjects ?? [])
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        recordsSubject.onNext(fetchedResultController.fetchedObjects ?? [])
    }
}
