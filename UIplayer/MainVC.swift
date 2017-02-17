//
//  ViewController.swift
//  UIplayer
//
//  Created by Neven on 14/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var controller: NSFetchedResultsController<Item>!
    private var _jsonPath: String = "/UIplayer/UIplayer.json"
    
    var jsonPath : String {
        get {
            return _jsonPath
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        generateItem()
        fetchItem()
    }
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = controller.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sectionInfo = controller.sections {
            let section = sectionInfo[section]
            return section.numberOfObjects
        }
        
        return 12
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
        configCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func configCell(cell: ItemCell , indexPath: IndexPath) {
        let item = controller.object(at: indexPath)
        cell.updateCell(item: item)
    }
    
    
    func fetchItem() {
        
        let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
        let idSort: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [idSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        self.controller = controller
        
        do {
            try controller.performFetch()
            
        } catch let error as NSError {
            print("\(error.debugDescription)")
        }

    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            
        case .update:
            if let indexPath = indexPath {
                // Update Cell
                let cell = tableView.cellForRow(at: indexPath) as! ItemCell
                configCell(cell: cell, indexPath: indexPath)
            }
            
        }
    }
    
    func generateItem() {
        
        let item = Item(context: context)
        item.id = 1
        item.category = "home"
        item.title = "Test01"
        item.info = "Have fun"
        item.url = "http://media6000.dropshots.com/photos/1345834/20170213/095405.mov"
        
        let cover = "http://79.170.44.135/nevenhsu.com/UIplayer/Section_1.png"
        DispatchQueue.global().async {
            let url = URL(string: cover)
            do {
                let data =  try Data(contentsOf: url!)
                DispatchQueue.global().sync {
                    item.cover = UIImage(data: data)
                }
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
        
        item.duration = 10
        
    }
    
    //func downloadJson(path: String) ->  {
        
    //}
    

}

