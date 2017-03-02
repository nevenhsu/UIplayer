//
//  ViewController.swift
//  UIplayer
//
//  Created by Neven on 14/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, ListTableViewControllerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBtnItem: UIBarButtonItem!
    var controller: NSFetchedResultsController<Item>!
    var searchController: SearchController!
    var mainStoryboard:UIStoryboard!
    var listTableVC: ListTableVC!
    private var _itemsDic: [[String: AnyObject]]!
    private var _newIndex: Int!
    private var _baseURL = URL(string: "http://79.170.44.135/nevenhsu.com/")
    private var _jsonPath: String = "UIplayer/UIplayer.json"
    let firstDownloadTimes = 4

    var jsonURL : URL {
        get {
            return URL(string: _jsonPath, relativeTo: _baseURL)!
        }
    }
    
    var itemsDic: [[String: AnyObject]] {
        get {
            if _itemsDic != nil {
                return _itemsDic
            } else {
                return []
            }
        }
        set {
            _itemsDic = newValue
        }
    }
    
    var newIndex: Int {
        get {
            if (_newIndex != nil) {
                return _newIndex
            } else {
                return 0
            }
        }
        set {
            if newValue > newIndex {
                _newIndex = newValue
                let newItemIndex = newValue + firstDownloadTimes
                if newItemIndex < itemsDic.count {
                    self.createItem(itemDic: itemsDic[newItemIndex],reCreate: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        retriveJson(url: jsonURL)
        fetchItem(predicate: nil)
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
        configCell(cell: cell, indexPath: indexPath)
        newIndex = indexPath.row
        return cell
    }
    
    func configCell(cell: ItemCell , indexPath: IndexPath) {
        let item = controller.object(at: indexPath)
        cell.updateCell(item: item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objs = controller.fetchedObjects, objs.count > 0
        {
            let item = objs[indexPath.row]
            performSegue(withIdentifier: "DetailVC", sender: item)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailVC" {
            if let detialVC = segue.destination as? DetailVC,
                let item = sender as? Item
            {
                detialVC.item = item
            }
        }
    }
    
    func fetchItem(predicate: NSPredicate?) {
        let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
        let idSort: NSSortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [idSort]
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        } else {
            fetchRequest.predicate = nil
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        self.controller = controller
        
        self._newIndex = 0
        
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
        case.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            
        case.update:
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
            if let itemsDic = jsonDic["items"] as? [[String: AnyObject]]
            {
                self.itemsDic = itemsDic
                for itemDic in itemsDic.prefix(upTo: self.firstDownloadTimes)
                {
                    self.createItem(itemDic: itemDic, reCreate: true)
                }
            }
        }
    }
    
    func createItem(itemDic: [String: AnyObject], reCreate: Bool) {
        let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
        if let id = itemDic["id"]
        {
            let idPredicate = NSPredicate(format: "id == %@", id as! CVarArg)
            fetchRequest.predicate = idPredicate
            
            do {
                let result = try context.fetch(fetchRequest)
                if let item = result.first
                {
                    if reCreate
                    {
                       self.configItem(item: item, itemDic: itemDic)
                    }
                } else {
                    let newItem = Item(context: context)
                    self.configItem(item: newItem, itemDic: itemDic)
                }
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }
    }
    
    func configItem(item: Item, itemDic: [String: AnyObject]) {
        if let id = itemDic["id"] as? Int16{
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
            DispatchQueue.global().async
            {
                let url = URL(string: thumbnail)!
                self.configImg(item: item, itemProperty: "thumbnail", url: url)
            }
        }
        
        if let cover = itemDic["cover"] as? String {
            DispatchQueue.global().async
            {
                let url = URL(string: cover)!
                self.configImg(item: item, itemProperty: "cover", url: url)
            }
        }
        
        if let tags = itemDic["tags"] as? [String] {
            let fetchRequest: NSFetchRequest<Tag> = NSFetchRequest(entityName: "Tag")
            
            for tag in tags {
                let tagPredicate = NSPredicate(format: "name == %@", tag)
                fetchRequest.predicate = tagPredicate
                do {
                    let result = try context.fetch(fetchRequest)
                    if let tagEntity = result.first {
                        item.addToTags(tagEntity)
                    } else {
                        let newTag = Tag(context: context)
                        newTag.name = tag
                        item.addToTags(newTag)
                    }
                } catch let err as NSError {
                    print(err.debugDescription)
                }
            }
        }
    }
    
    func configImg(item: Item,itemProperty: String, url: URL) {
        do {
            let data =  try Data(contentsOf: url)
            
            DispatchQueue.main.async
                {
                switch itemProperty {
                case "thumbnail":
                    item.thumbnail = UIImage(data: data)
                case "cover":
                    item.cover = UIImage(data: data)
                default:
                    return
                }
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    @IBAction func tappedSearchBtn(_ sender: UIBarButtonItem) {
        // Instantiate SearchController and SearchBar
        searchController = SearchController(searchResultsController: self, frame: (navigationController?.navigationBar.frame)!)
        searchController.delegate = self
        searchController.costomSearchBar.delegate = self
        navigationItem.titleView = searchController.costomSearchBar
        navigationItem.rightBarButtonItem = nil
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        
        //Instantiate ListTableView
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        listTableVC = mainStoryboard.instantiateViewController(withIdentifier: "ListTableVC") as? ListTableVC
        listTableVC.delegate = self
        listTableVC.tableView.sizeToFit()
        addViewController(viewController: listTableVC)
    }
    
    func didSelectListRow(listString: String) {
        let searchBar = searchController.costomSearchBar!
        searchBar.text = listString
        searchBar.delegate?.searchBar!(searchBar, textDidChange: listString)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Restore Search BarItem and ReFetch Item
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = searchBtnItem
        fetchItem(predicate: nil)
        tableView.reloadData()
        removeViewController(viewController: listTableVC)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchController.costomSearchBar.showCancelBtn()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Create Item which Title and Catagory include SearchText
        //Change Predicate and ReFetch Item
        if searchText.characters.count > 0 {
            removeViewController(viewController: listTableVC)
            
            for itemDic in itemsDic {
                if let title = itemDic["title"] as? String, title.range(of:searchText, options: .caseInsensitive) != nil
                {
                    self.createItem(itemDic: itemDic,reCreate: false)
                }
                if let catagory = itemDic["category"] as? String, catagory.range(of:searchText, options: .caseInsensitive) != nil
                {
                    self.createItem(itemDic: itemDic,reCreate: false)
                }
            }
            let predicate = NSPredicate(format: "(title contains [cd] %@) || (category contains[cd] %@)", searchText, searchText)
            fetchItem(predicate: predicate)
            tableView.reloadData()
        } else {
            addViewController(viewController: listTableVC)
        }
    }
    
    func addViewController(viewController: UIViewController) {
        listTableVC.willMove(toParentViewController: self)
        tableView.addSubview(listTableVC.tableView)
        listTableVC.didMove(toParentViewController: self)
        tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
        tableView.isScrollEnabled = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 70/255, green: 55/255, blue: 95/255, alpha: 0.8)
    }
    
    func removeViewController(viewController: UIViewController) {
        tableView.willRemoveSubview(viewController.view)
        viewController.view.removeFromSuperview()
        tableView.isScrollEnabled = true
        navigationController?.navigationBar.barTintColor = UIColor(red: 58/255, green: 170/255, blue: 210/255, alpha: 0.8)
    }
    
}

