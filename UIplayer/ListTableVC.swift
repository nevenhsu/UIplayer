//
//  ListTableVC.swift
//  UIplayer
//
//  Created by Neven on 26/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

protocol ListTableViewControllerDelegate {
    func didSelectListRow(listString: String)
    func cancelSearch()
    func viewDidScroll()
}

class ListTableVC: UITableViewController {
    
    var listArray = ["Easing","Offset & Delay","Parenting","Transformation","Value change","Masking","Overlay","Cloning","Obscuration","Parallax","Dimensionality","Dolly & Zoom"]
    var delegate: ListTableViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 96
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clear
        
        return footer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.titleLbl.text = listArray[indexPath.row]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listString = listArray[indexPath.row]
        delegate.didSelectListRow(listString: listString)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate.viewDidScroll()
    }
    
    @IBAction func swipeCancelSearch(_ sender: Any) {
        //delegate.cancelSearch()
    }



}
