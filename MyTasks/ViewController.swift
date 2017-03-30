//
//  ViewController.swift
//  MyTasks
//
//  Created by Filipe Martins on 21/03/2017.
//  Copyright © 2017 Runtime Revolution. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController
{
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addTask(_ sender: Any)
    {
        // Check if the view controller managed object context is not nil.
        // Since we are note cleaning this instance, on our case,
        // the guard will always return a valid context.
        // But despite that, let's have the correct way to use a optional variable.
        guard let _context = managedObjectContext else { return }
        
        // Using the Managed Object Context, lets create a new entry into entity "Task"
        let object = NSEntityDescription.insertNewObject(forEntityName: "Task", into: self.managedObjectContext!) as! Task
        
        // Now lets set his attributes. Since we didn't create a user interface to input
        // text, lets use the current date description as name, and by default set all
        // created tasks by default uncompleted.
        object.name = Date().description
        object.completed = false
        
        do {
            // Then we try to persist the new entry.
            // And if everything went successfull the fetched results controller
            // will react and from the delegate methods it will call the reload
            // of the Table View.
            try _context.save()
        } catch {
            
        }
    }
    
    // MARK: - Fetched results controller
    // The fetched results controller instance variable with the
    // pretended entity type we want to fetch from the Core Data.
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    // The proxy variable to serve as a lazy getter to our
    // fetched results controller.
    var fetchedResultsController: NSFetchedResultsController<Task>
    {
        // If the variable is already initialized we return that instance.
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        // If not lets build the required elements for the fetched
        // results controller.
        
        // First we need to create a fetch request with the pretended type.
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Set the batch size to a suitable number (optional).
        fetchRequest.fetchBatchSize = 20
        
        // Create at least one sort order attribute and type (ascending\descending)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        // Set the sort objects to the fetch request.
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Optionally, let's create a filter\predicate.
        // The goal of this predicate is to fetch Tasks that are not yet completed.
        let predicate = NSPredicate(format: "completed == FALSE")
        
        // Set the created predicate to our fetch request.
        fetchRequest.predicate = predicate
        
        // Create the fetched results controller instance with the defined attributes.
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set the delegate of the fetched results controller to the view controller.
        // with this we will get notified whenever occours changes on the data.
        aFetchedResultsController.delegate = self
        
        // Setting the created instance to the view controller instance.
        _fetchedResultsController = aFetchedResultsController
        
        do {
            // Perform the initial fetch to Core Data.
            // After this step, the fetched results controller
            // will only retrieve more records if necessary.
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
}

extension ViewController : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Whenever a change occours on our data, we refresh the table view.
        self.tableView.reloadData()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource
{
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        // We will use the proxy variable to our fetched results
        // controller and from that we try to get the sections
        // from it. If not available we will ignore and return none (0).
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // We will use the proxy variable to our fetcehed results
        // controller and from that we try to get from that section
        // index access to the number of objects available.
        // If not possible, we will ignore and return 0 objects.
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // First we get a cell from the table view with the identifier "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Then we get the object at the current index from the fetched results controller
        let task = self.fetchedResultsController.object(at: indexPath)
        
        // And update the cell label with the task name
        cell.textLabel!.text = task.name
        
        // Finally we return the updated cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Whenever a user swipes a cell, we will show two options.
        // A option to mark a task completed.
        let completeAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Complete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.markCompletedTaskIn(indexPath)
        })
        
        // And a option to delete a task.
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.deleteTaskIn(indexPath)
        })
        
        return [deleteAction, completeAction]
    }
    
    func markCompletedTaskIn(_ indexPath : IndexPath)
    {
        // To mark a task completed we retrieve the corresponding
        // object from the cell index.
        let task = self.fetchedResultsController.object(at: indexPath)
        
        // Update the attribute
        task.completed = true
        
        do {
            // And try to persist the change. If successfull
            // the fetched results controller will react and call the method
            // to reload the table view.
            try self.managedObjectContext?.save()
        } catch {}
    }
    
    func deleteTaskIn(_ indexPath : IndexPath)
    {
        // To delete a task we retrieve the corresponding
        // object from the cell index.
        let task = self.fetchedResultsController.object(at: indexPath)
        
        // Then we use the managed object context and delete that object.
        self.managedObjectContext?.delete(task)
        
        do {
            // And try to persist the change. If successfull
            // the fetched results controller will react and call the method
            // to reload the table view.
            try self.managedObjectContext?.save()
        } catch {}
    }
}
