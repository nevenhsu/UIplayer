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
    private var _baseURL = URL(string: "http://79.170.44.135/nevenhsu.com/")
    private var _jsonPath: String = "UIplayer/UIplayer.json"
    
    var jsonURL : URL {
        get {
            return URL(string: _jsonPath, relativeTo: _baseURL)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        

        retriveJson(url: jsonURL)

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
            if let indexPath = indexPath,
               let cell = tableView.cellForRow(at: indexPath) as? ItemCell
            {
                configCell(cell: cell, indexPath: indexPath)
            }
            
        }
    }
    

    
    func retriveJson(url: URL) -> Void {
        let networkOperation = NetworkOperation(url: jsonURL)
        networkOperation.downloadJSON { (jsonDic) in
            if let items = jsonDic["items"] as? [[String: AnyObject]] {
                
                let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")

                
                for itemDic in items {
                    
                    let idPredicate = NSPredicate(format: "id == %@", itemDic["id"] as! CVarArg)
                    fetchRequest.predicate = idPredicate
                    
                    do {
                        let result = try context.fetch(fetchRequest)
                        
                        if let item = result.first {
                            self.configItem(item: item, itemDic: itemDic)
                        } else {
                            let newItem = Item(context: context)
                            self.configItem(item: newItem, itemDic: itemDic)
                        }
                        
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                    
                }
                
            }
        }
    }
    
    func configItem(item: Item, itemDic: [String: AnyObject]) {
        if let id = itemDic["id"] as? Int16 {
            item.id = id
        }
        
        if let catagory = itemDic["category"] as? String {
            item.category = catagory
        }
        
        if let title = itemDic["title"] as? String {
            item.title = title
        }
        
        if let info = itemDic["info"] as? String {
            item.info = info
        }
        
        if let url = itemDic["url"] as? String {
            item.url = url
        }
        
        if let duration = itemDic["duration"] as? Int16 {
            item.duration = duration
        }
        
        if let thumbnail = itemDic["thumbnail"] as? String {
            DispatchQueue.global().async {
                let url = URL(string: thumbnail)
                do {
                    let data =  try Data(contentsOf: url!)
                    item.thumbnail = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                } catch let error as NSError {
                    print(error.debugDescription)
                }
            }
        }
    }

}

