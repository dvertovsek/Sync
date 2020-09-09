//
//  SyncCoordinator.swift
//  Medicine
//
//  Created by Darijan Vertovsek on 1/09/20.
//  Copyright © 2020 Darijan Vertovsek. All rights reserved.
//

import CoreData

public final class SyncCoordinator {

    public let viewContext: NSManagedObjectContext
    public let syncContext: NSManagedObjectContext

    public let remote: SyncRemote

    let syncGroup = DispatchGroup()

    let changeProcessors: [ChangeProcessor]

    var observerTokens: [NSObjectProtocol] = []

    public init(container: NSPersistentContainer, changeProcessors: [ChangeProcessor], remote: SyncRemote) {
        viewContext = container.viewContext
        syncContext = container.newBackgroundContext()
        syncContext.name = "SyncCoordinator"
//        syncContext.mergePolicy = MoodyMergePolicy(mode: .remote)
        self.changeProcessors = changeProcessors
        self.remote = remote

        setup()
    }

    // MARK: Private

    private func setup() {
        self.perform {
            self.setupContexts()
            self.setupApplicationActiveNotifications()
        }
    }

    private func fetchRemoteDataForApplicationDidBecomeActive() {
        perform {
            for changeProcessor in self.changeProcessors {
                changeProcessor.fetchLatestRemoteRecords(in: self)
                self.delayedSaveOrRollback()
            }
        }
    }

}

extension SyncCoordinator: ApplicationActiveStateObserving {

    func addObserverToken(_ token: NSObjectProtocol) {
        observerTokens.append(token)
    }

    func applicationDidBecomeActive() {
        fetchLocallyTrackedObjects()
        fetchRemoteDataForApplicationDidBecomeActive()
    }

    func applicationDidEnterBackground() {

    }

//    func applicationDidEnterBackground() {
//        syncContext.refreshAllObjects()
//    }
//
    fileprivate func fetchLocallyTrackedObjects() {
        self.perform {
            // TODO: Could optimize this to only execute a single fetch request per entity.
            var objects: Set<NSManagedObject> = []
            for cp in self.changeProcessors {
                guard let entityAndPredicate = cp.entityAndPredicateForLocallyTrackedObjects(in: self) else { continue }
                let request = entityAndPredicate.fetchRequest
                request.returnsObjectsAsFaults = false
                let result = try! self.syncContext.fetch(request)
                objects.formUnion(result)
            }
            self.processChangedLocalObjects(Array(objects))
        }
    }

}

extension SyncCoordinator: ChangeProcessorContext {

    public var context: NSManagedObjectContext {
        return syncContext
    }

    /// This switches onto the sync context's queue. If we're already on it, it will simply run the block.
    public func perform(_ block: @escaping () -> ()) {
        syncContext.perform(group: syncGroup, block: block)
    }

    public func delayedSaveOrRollback() {
        context.delayedSaveOrRollback(group: syncGroup)
    }

}

extension SyncCoordinator: ContextOwner {
    func processChangedLocalObjects(_ objects: [NSManagedObject]) {
        for cp in changeProcessors {
            cp.processChangedLocalObjects(objects, in: self)
        }
    }
}


