//
//  SharedCode.swift
//  Medicine
//
//  Created by Darijan Vertovsek on 2/09/20.
//  Copyright © 2020 Darijan Vertovsek. All rights reserved.
//

import CoreData


extension NSManagedObjectContext {

    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }

    public func insertObject<A: NSManagedObject>() -> A {
        let entityName = A.entity().name!
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? A else { fatalError("Wrong object type") }
         return obj
     }

}
