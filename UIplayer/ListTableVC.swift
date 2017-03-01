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
}

class ListTableVC: UITableViewController {
    var listArray = ["Home","Calendar","Lists","Maps","Search","Settings","Home","Calendar","Lists","Maps","Search","Settings","Home","Calendar","Lists","Maps","Search","Settings"]
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,NSUnderlineColorAttributeName: UIColor(white: 1, alpha: 0.5) ] as [String : Any]
        let underlineAttributedString = NSAttributedString(string: listArray[indexPath.row], attributes: underlineAttribute)
        cell.textLabel?.attributedText = underlineAttributedString
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listString = listArray[indexPath.row]
        delegate.didSelectListRow(listString: listString)
    }

}
