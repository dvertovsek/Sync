//
//  ApplicationActiveStateObserving.swift
//  Medicine
//
//  Created by Darijan Vertovsek on 2/09/20.
//  Copyright © 2020 Darijan Vertovsek. All rights reserved.
//

import UIKit

protocol ObserverTokenStore : class {
    func addObserverToken(_ token: NSObjectProtocol)
}

protocol ApplicationActiveStateObserving: ObserverTokenStore {
    func perform(_ block: @escaping () -> ())

    func applicationDidBecomeActive()
    func applicationDidEnterBackground()
}

extension ApplicationActiveStateObserving {
    func setupApplicationActiveNotifications() {
        addObserverToken(NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.perform {
                observer.applicationDidBecomeActive()
            }
        })
        DispatchQueue.main.async {
            if UIApplication.shared.applicationState == .active {
                self.applicationDidBecomeActive()
            }
        }
    }
}
