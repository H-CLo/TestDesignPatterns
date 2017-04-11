//
//  Album.swift
//  BlueLibrarySwift
//
//  Created by Hung Chang Lo on 11/04/2017.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import Foundation

public class Album {
    var title: String!
    var artist: String!
    var genre: String!
    var coverUrl: String!
    var year: String!
    
    init(title: String, artist: String, genre: String, coverUrl: String, year: String) {
        self.title = title
        self.artist = artist
        self.genre = genre
        self.coverUrl = coverUrl
        self.year = year
    }
    
    var description: String {
        return "title = \(title)" +
               "artist = \(artist)" +
               "genre = \(genre)" +
               "coverUrl = \(coverUrl)" +
               "year = \(year)"
    }
}
