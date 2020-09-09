//
//  File.swift
//  
//
//  Created by Darijan Vertovsek on 9/09/20.
//

import CoreData

public final class EntityAndPredicate<A : NSManagedObject> {
    let entity: NSEntityDescription
    let predicate: NSPredicate

    init(entity: NSEntityDescription, predicate: NSPredicate) {
        self.entity = entity
        self.predicate = predicate
    }
}


extension EntityAndPredicate {
    var fetchRequest: NSFetchRequest<A> {
        let request = NSFetchRequest<A>()
        request.entity = entity
        request.predicate = predicate
        return request
    }
}


extension Sequence where Iterator.Element: NSManagedObject {
    func filter(_ entityAndPredicate: EntityAndPredicate<Iterator.Element>) -> [Iterator.Element] {
        typealias MO = Iterator.Element
        let filtered = filter { (mo: Iterator.Element) -> Bool in
            guard mo.entity === entityAndPredicate.entity else { return false }
            return entityAndPredicate.predicate.evaluate(with: mo)
        }
        return Array(filtered)
    }
}
