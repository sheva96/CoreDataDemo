//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 23.11.2020.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let storage = StorageManager.shared
    private let context = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "cell"
    
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        
        tasks = storage.fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: " Add New Task", andMessage: "What do you want to do?", nil)
    }
    
    // MARK: - Alert
    private func showAlert(withTitle title: String, andMessage message: String, _ indexPath: IndexPath?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let indexPath = indexPath else {
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.save(task)
                return
            }
            
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.tasks[indexPath.row].name = task
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.storage.saveContext()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField { textField in
            guard let indexPath = indexPath, let name = self.tasks[indexPath.row].name else {
                textField.text = nil
                return
            }
            textField.text = name
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        
        task.name = taskName
        tasks.append(task)
        
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        storage.saveContext()
    }
}

// MARK: - Table view data source & Table view delegate
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    // Swipe Actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (_, _, completionHandler) in
            completionHandler(true)
            
            self.context.delete(self.tasks[indexPath.row])
            self.tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.storage.saveContext()
        }
        delete.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            completionHandler(true)
            
            self.showAlert(withTitle: "Change Task", andMessage: "Enter a new task", indexPath)
        }
        edit.backgroundColor = .systemBlue
        
        let swipes = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipes
    }
}


