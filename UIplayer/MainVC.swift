//
//  ViewController.swift
//  UIplayer
//
//  Created by Neven on 14/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, ListTableViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backBtnItem: UIBarButtonItem!
    @IBOutlet var searchBtnItem: UIBarButtonItem!
    @IBOutlet weak var noMatchWarning: UIView!
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var footer: UIImageView!
    
    var networkOperation: NetworkOperation!
    var controller: NSFetchedResultsController<Item>!
    var searchController: SearchController!
    var searchBar: SearchBar!
    var refreshController: UIRefreshControl!
    var mainStoryboard:UIStoryboard!
    var listTableVC: ListTableVC!
    var context: NSManagedObjectContext!
    let ad = UIApplication.shared.delegate as! AppDelegate
    
    let plistPath:String? = Bundle.main.path(forResource: "JsonPlist", ofType: "plist")!
    var _jsonUpdateTime: String!
    
    private var _itemsDic: [[String: AnyObject]]!
    private var _newIndex: Int!
    private var _baseURL = URL(string: "http://upick.ml/")
    private var _jsonPath: String = "app/data.json"
    let firstDownloadTimes: Int = 5
    var searching = false
    var isDownloading = false
    var recreate = false
    private var _isNetworkConneting: Bool = false

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
                var newItemIndex = newValue + firstDownloadTimes
                newItemIndex -= 1
                if newItemIndex < itemsDic.count {
                    
                    
                    self.createItem(itemDic: itemsDic[newItemIndex],reCreate: recreate)
                    
                    print("newItemIndex",newItemIndex)
                    
                }
            }
        }
    }
    
    var jsonUpdateTime: String {
        get {
            if _jsonUpdateTime != nil {
                return _jsonUpdateTime
            } else {
                return "-1"
            }
        }
        
        set {
            _jsonUpdateTime = newValue
        }
    }
    
    var isNetworkConneting: Bool {
        get {
            return _isNetworkConneting
        }
        
        set {
            if newValue {
                networkError.isHidden = true
                _isNetworkConneting = newValue
            } else {
                networkError.isHidden = false
                _isNetworkConneting = newValue
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = ad.persistentContainer.viewContext

        tableView.delegate = self
        tableView.dataSource = self
        
        if let path = plistPath,
            let plist = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
            let time = plist["updated"] as? String {
            self.jsonUpdateTime = time
        }
        
        noMatchWarning.isHidden = true
        footer.isHidden = true
        searching = false
        isDownloading = false
        navigationItem.leftBarButtonItem = nil
        
        networkOperation = NetworkOperation(url: jsonURL)
        
        initListView()
        initSearchController()
        
        //set up Refresh Controller
        refreshController = UIRefreshControl()
        refreshController.tintColor = UIColor.white
        refreshController.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.addSubview(refreshController)
        
        retriveJson()
        fetchItem(predicate: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.layer.isHidden = false
        navigationController?.navigationBar.layer.opacity = 0
        searchBar.barTintColor = UIColor(red: 41/255, green: 21/255, blue: 74/255, alpha: 1)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.navigationController?.navigationBar.layer.opacity = 1
        }) { (finished) in
        }
    }
    
    func initListView() {
        //Instantiate ListTableView
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        listTableVC = mainStoryboard.instantiateViewController(withIdentifier: "ListTableVC") as? ListTableVC
        listTableVC.delegate = self
        listTableVC.tableView.frame.offsetBy(dx: 0, dy: 0)
        listTableVC.tableView.sizeToFit()
    }
    
    func initSearchController() {
        // Instantiate SearchController and SearchBar
        searchController = SearchController(searchResultsController: self, frame: (navigationController?.navigationBar.frame)!)
        searchBar = searchController.costomSearchBar
        searchController.delegate = self
        searchController.costomSearchBar.delegate = self
        searchBar.sizeToFit()
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
            
            if section.numberOfObjects == 0 && searching {
                
                if let searchText = searchBar.text, searchText.characters.count > 0 {
                    noMatchWarning.isHidden = false
                } else {
                    noMatchWarning.isHidden = true
                }
                
            }  else {
                noMatchWarning.isHidden = true
                return section.numberOfObjects
            }
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
            searchBar.endEditing(true)
            performSegue(withIdentifier: "DetailVC", sender: item)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailVC" {
            if let detialVC = segue.destination as? DetailVC, let item = sender as? Item  {
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
    
    func retriveJson() {
        if !isDownloading {
            isDownloading = true
            
            isNetworkConneting = networkOperation.checkNetworkConnection()
            
            if isNetworkConneting {
                networkOperation.downloadJSON { (data) in
                    
                    if let jsonData = data {
                        self.json2CreateItem(data: jsonData)
                    }
                    
                    self.isDownloading = false
                }
            } else {

                if let jsonData = self.readJsonPlist() {
                    self.json2CreateItem(data: jsonData)
                }
                self.isDownloading = false
            }
            
            if self.refreshController.isRefreshing {
                self.refreshController.endRefreshing()
            }
        }
    }
    
    func json2CreateItem(data: Data) {
        if let jsonDic = self.jsonSerialization(data: data) {
            self.itemsDic = jsonDic["items"] as! [[String : AnyObject]]
            let updatedTime = jsonDic["updated"] as! String
            
            if updatedTime != self.jsonUpdateTime {
                self.recreate = true
                self.jsonUpdateTime = updatedTime
                self.updateJsonPlist(newData: data as Data, updateTime: jsonUpdateTime)
                
                for itemDic in self.itemsDic.prefix(upTo: self.firstDownloadTimes)
                {
                    self.createItem(itemDic: itemDic, reCreate: recreate)
                }
            } else {
                self.recreate = false
                
                for itemDic in self.itemsDic.prefix(upTo: self.firstDownloadTimes)
                {
                    self.createItem(itemDic: itemDic, reCreate: recreate)
                }
            }
        }
    }
    
    func updateJsonPlist(newData: Data, updateTime: String) {
        if let path = plistPath {
            let plist = NSMutableDictionary(contentsOfFile: path)
            plist?["json"] = newData
            plist?["updated"] = self.jsonUpdateTime
            plist?.write(toFile: path, atomically: true)
            print("update plist successfully")
        } else {
            print("update plist error")
        }
    }
    
    func readJsonPlist() -> Data? {
        if let path = plistPath,
            let plist = NSDictionary(contentsOfFile: path) {
            print("read plist successfully")
            return plist["json"] as! Data?
        } else {
            print("read plist error")
            return nil
        }
    }
    
    func jsonSerialization(data: Data?) -> [String:AnyObject]? {
        do{
            if let dataDic = data {
                let jsonDic = try JSONSerialization.jsonObject(with: dataDic, options: .allowFragments)
                return jsonDic as? [String:AnyObject]
            }
            return nil
        }
        catch{
            print("Error reading plist: \(error)")
            return nil
        }
    }
    
    func refresh() {
        if !searching {
            refreshController.beginRefreshing()
            self.retriveJson()
            self.fetchItem(predicate: nil)
        } else {
            refreshController.beginRefreshing()
            refreshController.endRefreshing()
            return
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
                        return
                    }
                    
                    if item.cover == nil || item.thumbnail == nil {
                        self.configItem(item: item, itemDic: itemDic)
                        return
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
        
        context.perform {
        
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
                        let result = try self.context.fetch(fetchRequest)
                        if let tagEntity = result.first {
                            item.addToTags(tagEntity)
                        } else {
                            let newTag = Tag(context: self.context)
                            newTag.name = tag
                            item.addToTags(newTag)
                        }
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
                }
            }
        }
    }
    
    func configImg(item: Item,itemProperty: String, url: URL) {
        do {
            let data =  try Data(contentsOf: url)
            
            switch itemProperty {
            case "thumbnail":
                item.thumbnail = UIImage(data: data)
                
            case "cover":
                item.cover = UIImage(data: data)
                
            default:
                return
            }
            
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    @IBAction func tappedTryAgainBtn(_ sender: UIButton) {
        refresh()
    }
    
    @IBAction func tappedCancelBtn(_ sender: UIButton) {
        networkError.isHidden = true
    }
    
    @IBAction func tappedSearchBtn(_ sender: UIBarButtonItem) {
        if networkError.isHidden {
            searching = true
            navigationItem.titleView = searchBar
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = backBtnItem
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchBar.becomeFirstResponder()
            showList()
            refreshController.tintColor = UIColor.clear
        }
    }
    
    func hideKeyboard() {
        searchBar.endEditing(true)
    }
    
    func viewDidScroll() {
        hideKeyboard()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeyboard()
        
        let yOffset = scrollView.contentOffset.y
        let height = scrollView.bounds.size.height
        let size = scrollView.contentSize.height
        
        if yOffset + height >= size && size >= height {
            footer.isHidden = false
        } else {
            footer.isHidden = true
        }
    }
    
    func didSelectListRow(listString: String) {
        searchBar.text = listString
        searchBar.delegate?.searchBar!(searchBar, textDidChange: listString)
        searchBar.endEditing(true)
    }
    
    func cancelSearch() {
        //Remove searchBar text
        searchBar.text = ""
        
        //Restore Search BarItem and ReFetch Item
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = searchBtnItem
        navigationItem.leftBarButtonItem = nil
        fetchItem(predicate: nil)
        tableView.reloadData()
        removeList()
        self.searching = false
        refreshController.tintColor = UIColor.white
    }
    
    @IBAction func tappedBackArrowBtn(_ sender: UIBarButtonItem) {
        cancelSearch()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        resetSearchController()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Create Item which Title and Catagory include SearchText
        //Change Predicate and ReFetch Item
        if searchText.characters.count > 0 {
            removeViewController(viewController: listTableVC)
            
            for itemDic in itemsDic {
                if let title = itemDic["title"] as? String, title.range(of:searchText, options: .caseInsensitive) != nil
                {
                    self.createItem(itemDic: itemDic,reCreate: recreate)
                }
                if let catagory = itemDic["category"] as? String, catagory.range(of:searchText, options: .caseInsensitive) != nil
                {
                    self.createItem(itemDic: itemDic,reCreate: recreate)
                }
            }
            let predicate = NSPredicate(format: "(title contains [cd] %@) || (ANY tags.name contains[cd] %@) || (category contains [cd] %@)", searchText, searchText,searchText)
            fetchItem(predicate: predicate)
            tableView.reloadData()
        } else {
            resetSearchController()
        }
    }
    
    func resetSearchController() {
        searchBar.text = ""
        noMatchWarning.isHidden = true
        addViewController(viewController: listTableVC)
    }
    
    
    func addViewController(viewController: UIViewController) {
        viewController.willMove(toParentViewController: self)
        tableView.addSubview(viewController.view)
        viewController.view.alpha = 0
        viewController.didMove(toParentViewController: self)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            viewController.view.alpha = 1
        }) { (finished) in
            viewController.didMove(toParentViewController: self)
            self.tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
            self.tableView.isScrollEnabled = false

            }
        }
    
    func removeViewController(viewController: UIViewController) {
        tableView.willRemoveSubview(viewController.view)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { 
            viewController.view.alpha = 0
        }) { (finished) in
            viewController.view.removeFromSuperview()
            self.tableView.isScrollEnabled = true
        }
    }
    
    
    func showList() {
        //Add list
        listTableVC.willMove(toParentViewController: self)
        listTableVC.view.frame.size.height = tableView.frame.height
        tableView.addSubview(listTableVC.view)
        tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
        tableView.isScrollEnabled = false
        
        //Animate
        listTableVC.view.transform = CGAffineTransform(translationX: tableView.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.listTableVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { (finished) in
            self.listTableVC.didMove(toParentViewController: self)
        })
    }
    
    func removeList() {
        tableView.willRemoveSubview(listTableVC.view)
        //Animate list
        listTableVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { 
            self.listTableVC.view.transform = CGAffineTransform(translationX: self.tableView.frame.size.width, y: 0)
        }) { (finished) in
            self.listTableVC.view.removeFromSuperview()
            self.tableView.isScrollEnabled = true
        }
    }
    
        
}

