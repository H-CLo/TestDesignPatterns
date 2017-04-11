//
//  AlbumExtensions.swift
//  BlueLibrarySwift
//
//  Created by Hung Chang Lo on 11/04/2017.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import Foundation

/**
    The Decorator pattern dynamically adds behaviors and responsibilities to an object without modifying its code. It’s an alternative to subclassing where you modify a class’s behavior by wrapping it with another object.

    In Swift there are two very common implementations of this pattern: Extensions and Delegation.
 */

/**
    Adding extensions is an extremely powerful mechanism that allows you to add new functionality to existing classes, structures or enumeration types without having to subclass. What’s also really awesome is you can extend code you don’t have access to, and enhance their functionality.
 
    - Note: Classes can of course override a superclass’s method, but with extensions you can’t. Methods or properties in an extension cannot have the same name as methods or properties in the original class.
 */

extension Album {
    // ae == AlbumExtenstion abbreviation
    func ae_tableViewRepresentation() -> (titles: [String], values: [String]) {
        return (["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
    }
}
