//
//  Item+CoreDataProperties.swift
//  UIplayer
//
//  Created by Neven on 14/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var id: Int16
    @NSManaged public var title: String?
    @NSManaged public var category: String?
    @NSManaged public var info: String?
    @NSManaged public var url: String?
    @NSManaged public var thumbnail: NSObject?
    @NSManaged public var cover: NSObject?
    @NSManaged public var duration: Int16
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Item {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
