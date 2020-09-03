//
//  SyncContextOwner.swift
//  Medicine
//
//  Created by Darijan Vertovsek on 3/09/20.
//  Copyright © 2020 Darijan Vertovsek. All rights reserved.
//

import CoreData

protocol ContextOwner: ObserverTokenStore {
    var viewContext: NSManagedObjectContext { get }
    var syncContext: NSManagedObjectContext { get }
    var syncGroup: DispatchGroup { get }

    func processChangedLocalObjects(_ objects: [NSManagedObject])
}

extension ContextOwner {

    func setupContexts() {
        setupQueryGenerations()
        setupContextNotificationObserving()
    }

    fileprivate func setupQueryGenerations() {
        let token = NSQueryGenerationToken.current
        viewContext.perform {
            try! self.viewContext.setQueryGenerationFrom(token)
        }
        syncContext.perform {
            try! self.syncContext.setQueryGenerationFrom(token)
        }
    }

    fileprivate func setupContextNotificationObserving() {
        addObserverToken(
            viewContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.viewContextDidSave(note)
            }
        )
        addObserverToken(
            syncContext.addContextDidSaveNotificationObserver { [weak self] note in
                self?.syncContextDidSave(note)
            }
        )
//        addObserverToken(
//            syncContext.addObjectsDidChangeNotificationObserver { [weak self] note in
//                self?.objectsInSyncContextDidChange(note)
//        })
    }

    /// Merge changes from view -> sync context.
    fileprivate func viewContextDidSave(_ note: ContextDidSaveNotification) {
        syncContext.performMergeChanges(from: note)
        notifyAboutChangedObjects(from: note)
    }

    /// Merge changes from sync -> view context.
    fileprivate func syncContextDidSave(_ note: ContextDidSaveNotification) {
        viewContext.performMergeChanges(from: note)
        notifyAboutChangedObjects(from: note)
    }

//    fileprivate func objectsInSyncContextDidChange(_ note: ObjectsDidChangeNotification) {
//        // no-op
//    }

    fileprivate func notifyAboutChangedObjects(from notification: ContextDidSaveNotification) {
        syncContext.perform(group: syncGroup) {
            // We unpack the notification here, to make sure it's retained
            // until this point.
            let updates = notification.updatedObjects.remap(to: self.syncContext)
            let inserts = notification.insertedObjects.remap(to: self.syncContext)
            self.processChangedLocalObjects(updates + inserts)
        }
    }
}
