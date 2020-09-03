//
//  File.swift
//  
//
//  Created by Darijan Vertovsek on 4/09/20.
//

public protocol SyncRemote {
    func fetchDocument<Document: Encodable>(_ completion: @escaping ((Document) -> Void))
}
