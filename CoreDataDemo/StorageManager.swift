//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Yevhen Shevchenko on 25.11.2020.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    
    private var tasks: [Task] = []
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() {}
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        return tasks
    }
    
}
