//
//  ChangeProcessor.swift
//  Medicine
//
//  Created by Darijan Vertovsek on 1/09/20.
//  Copyright © 2020 Darijan Vertovsek. All rights reserved.
//

import CoreData

public protocol ElementChangeProcessor: ChangeProcessor {

    associatedtype Element: NSManagedObject

    /// Any objects matching the predicate.
    func processChangedLocalElements(_ elements: [Element], in context: ChangeProcessorContext)
}

public protocol ChangeProcessor {
    /// Called at startup to give the processor a chance to configure itself.
//    func setup(for context: ChangeProcessorContext)
//
//    /// Respond to changes of locally inserted or updated objects.
    func processChangedLocalObjects(_ objects: [NSManagedObject], in context: ChangeProcessorContext)
//
//    /// Upon launch these fetch requests are executed and the resulting objects are passed to `process(changedLocalObjects:)`.
//    /// This allows the change processor to resume pending local changes.
//    func entityAndPredicateForLocallyTrackedObjects(in context: ChangeProcessorContext) -> EntityAndPredicate<NSManagedObject>?
//
//    /// Respond to changes in remote records.
//    func processRemoteChanges<T>(_ changes: [RemoteRecordChange<T>], in context: ChangeProcessorContext, completion: () -> ())
//
//    /// Does the initial fetch from the remote.
    func fetchLatestRemoteRecords(in context: ChangeProcessorContext)
}

public protocol ChangeProcessorContext: class {

    /// The managed object context to use
    var context: NSManagedObjectContext { get }

//    /// The remote to use for syncing.
    var remote: SyncRemote { get }

    /// Wraps a block such that it is run on the right queue.
    func perform(_ block: @escaping () -> ())

//    /// Wraps a block such that it is run on the right queue.
//    func perform<A, B>(_ block: @escaping (A, B) -> ()) -> (A, B) -> ()
//
//    /// Wraps a block such that it is run on the right queue.
//    func perform<A, B, C>(_ block: @escaping (A, B, C) -> ()) -> (A, B, C) -> ()

    /// Eventually saves the context. May batch multiple calls into a single call to `saveOrRollback()`.
    func delayedSaveOrRollback()
}
