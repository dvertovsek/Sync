//
//  ContextDidSaveNotification.swift
//  Medicine
//
//  Created by Darijan Vertovsek on 3/09/20.
//  Copyright © 2020 Darijan Vertovsek. All rights reserved.
//

import CoreData

public struct ContextDidSaveNotification {

    fileprivate let notification: Notification

    init(note: Notification) {
        guard note.name == .NSManagedObjectContextDidSave else { fatalError() }
        notification = note
    }

    var insertedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSInsertedObjectsKey)
    }

    var updatedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSUpdatedObjectsKey)
    }

    var deletedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSDeletedObjectsKey)
    }

    var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    private func iterator(forKey key: String) -> AnyIterator<NSManagedObject> {
        guard let set = (notification as Notification).userInfo?[key] as? NSSet else {
            return AnyIterator { nil }
        }
        var innerIterator = set.makeIterator()
        return AnyIterator { return innerIterator.next() as? NSManagedObject }
    }

}


extension ContextDidSaveNotification: CustomDebugStringConvertible {
    public var debugDescription: String {
        var components = [notification.name.rawValue]
        components.append(managedObjectContext.description)
        for (name, set) in [("inserted", insertedObjects), ("updated", updatedObjects), ("deleted", deletedObjects)] {
            let all = set.map { $0.objectID.description }.joined(separator: ", ")
            components.append("\(name): {\(all)})")
        }
        return components.joined(separator: " ")
    }
}

extension NSManagedObjectContext {

    /// Adds the given block to the default `NotificationCenter`'s dispatch table for the given context's did-save notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NotificationCenter`'s `removeObserver()`.
    public func addContextDidSaveNotificationObserver(_ handler: @escaping (ContextDidSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextDidSave, object: self, queue: nil) { note in
            let wrappedNote = ContextDidSaveNotification(note: note)
            handler(wrappedNote)
        }
    }

    public func performMergeChanges(from note: ContextDidSaveNotification) {
        perform {
            self.mergeChanges(fromContextDidSave: note.notification)
        }
    }

}

