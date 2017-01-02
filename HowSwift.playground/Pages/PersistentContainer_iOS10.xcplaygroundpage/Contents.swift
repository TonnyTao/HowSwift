//: [Previous](@previous)

import Foundation
import CoreData

//: iOS10 CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    var errorHandler: (Error) -> Void = {err in
        debugPrint("CoreData error \(err), \(err._userInfo)")
    }
    
    lazy var container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Model")
        
        container.loadPersistentStores(completionHandler: { [weak self](storeDescription, error) in
            if let error = error {
                self?.errorHandler(error)
            }
        })
        
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.container.newBackgroundContext()
    }()
}

extension CoreDataStack {
    static func performForegroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let ctx = self.shared.viewContext
        ctx.perform { [unowned ctx] in
            block(ctx)
        }
    }
    
    static func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.shared.container.performBackgroundTask(block)
    }
}
