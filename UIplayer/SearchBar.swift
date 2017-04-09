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
    let holdColor = UIColor.init(white: 1.0, alpha: 0.8)
    let fieldColor = UIColor.init(red: 41/255, green: 21/255, blue: 74/255, alpha: 1.0)
    var textField: UITextField!
    
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
            textField = subviews[0].subviews[index] as! UITextField
        
            // Set the font and text color of the search field.
            textField.font = font
            textField.textColor = textColor
            textField.tintColor = textColor
            
            // Set the background color of the search field.
            textField.backgroundColor = fieldColor
            
            // Set the font and text color of the placeholder.
            let attributes = [
                NSForegroundColorAttributeName: self.holdColor,
                NSFontAttributeName : self.font
            ] as [String : Any]
            textField.attributedPlaceholder = NSAttributedString(string: "Search for a name or a tag...", attributes:attributes)
            
            // Set Image and Button in Text Field
            let glassIconView = textField.leftView as! UIImageView
                //Magnifying glass
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = textColor
            
            // Set Clear Button
            let clearButton = textField.value(forKey: "clearButton") as! UIButton
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
            clearButton.tintColor = textColor
            }
        
        super.draw(rect)
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
