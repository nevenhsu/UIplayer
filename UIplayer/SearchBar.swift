//
//  SearchBar.swift
//  UIplayer
//
//  Created by Neven Hsu on 01/03/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class SearchBar: UISearchBar {

    let font = UIFont(name: "HelveticaNeue-Light", size: 14.0)!
    let textColor = UIColor.white
    let fieldColor = UIColor.clear
    var textField: UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        isTranslucent = true
        searchBarStyle = .prominent
        showsCancelButton = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        // Find the index of the search field in the search bar subviews.
        if let index = indexOfSearchFieldInSubview() {
            // Access the search field
            let searchField: UITextField = subviews[0].subviews[index] as! UITextField
            textField = searchField
            
            // Set the font and text color of the search field.
            searchField.font = font
            searchField.textColor = textColor
            searchField.tintColor = textColor
            
            // Set the background color of the search field.
            searchField.backgroundColor = fieldColor
            
            // Set the font and text color of the placeholder.
            let attributes = [
                NSForegroundColorAttributeName: self.textColor,
                NSFontAttributeName : self.font
            ] as [String : Any]
            searchField.attributedPlaceholder = NSAttributedString(string: "Search for a name or a tag...", attributes:attributes)
            
            // Set Image and Button in Text Field
            let glassIconView = searchField.leftView as! UIImageView
                //Magnifying glass
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = textColor
            
            // Set Clear Button
            let clearButton = searchField.value(forKey: "clearButton") as! UIButton
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
            clearButton.tintColor = textColor
        }
        super.draw(rect)
    }
    
    func showCancelBtn() {
        self.showsCancelButton = true
        if let cancelButton = self.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle("Cancel", for: UIControlState())
            cancelButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        }
    }
    
    func indexOfSearchFieldInSubview() -> Int! {
        var index: Int!
        let searchBarView = subviews[0]
        
        for i in 0 ..< searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self) {
                index = i
                break
            }
        }
        return index
    }

}
