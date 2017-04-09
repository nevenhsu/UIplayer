//
//  SearchController.swift
//  UIplayer
//
//  Created by Neven Hsu on 01/03/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class SearchController: UISearchController {
    var costomSearchBar: SearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    init(searchResultsController: UIViewController!, frame: CGRect) {
        super.init(searchResultsController: searchResultsController)
        costomSearchBar = SearchBar(frame: frame)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
  

}
