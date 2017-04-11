//
//  PersistenyManager.swift
//  BlueLibrarySwift
//
//  Created by Hung Chang Lo on 11/04/2017.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import UIKit

/**
    declare a private property to hold album data. The array is mutable, so you can easily add and delete albums.
 */

class PersistencyManager: NSObject {
    private var albums = [Album]()
    
    override init() {
        let album1 = Album(title: "Best of Bowie",
                           artist: "David Bowie",
                           genre: "Pop",
                           coverUrl: "http://i.imgur.com/CU9p6Ya.jpg",
                           year: "1992")
        
        let album2 = Album(title: "It's My Life",
                           artist: "No Doubt",
                           genre: "Pop",
                           coverUrl: "http://i.imgur.com/lVOjiN0.jpg",
                           year: "2003")
        
        let album3 = Album(title: "Nothing Like The Sun",
                           artist: "Sting",
                           genre: "Pop",
                           coverUrl: "http://i.imgur.com/UVo1Tbl.jpg",
                           year: "1999")
        
        let album4 = Album(title: "Staring at the Sun",
                           artist: "U2",
                           genre: "Pop",
                           coverUrl: "http://i.imgur.com/cbx5iFx.jpg",
                           year: "2000")
        
        let album5 = Album(title: "American Pie",
                           artist: "Madonna",
                           genre: "Pop",
                           coverUrl: "http://i.imgur.com/ExShXeE.jpg",
                           year: "2000")
        
        albums = [album1, album2, album3, album4, album5]
    }
    
    func getAlbums() -> [Album] {
        return albums
    }
    
    func addAlbum(album: Album, index: Int) {
        if (albums.count >= index) {
            albums.insert(album, at: index)
        } else {
            albums.append(album)
        }
    }
    
    func removeAlbumAtIndex(index: Int) {
        albums.remove(at: index)
    }
    
    /**
        This code is pretty straightforward. The downloaded images will be saved in the Documents directory, and getImage() will return nil if a matching file is not found in the Documents directory.
     */
    func saveImage(image: UIImage, filename: String) {
        let string = NSHomeDirectory().appending("/Document/\(filename)")
        let path = URL(fileURLWithPath: string)
        let data = UIImagePNGRepresentation(image)
        do {
            try data?.write(to: path, options: Data.WritingOptions.atomicWrite)
        } catch {
            NSLog("ERROR INFO: \(error)")
        }
    }
    
    func getImage(filename: String) -> UIImage? {
        //let string = NSHomeDirectory().appending("/Documents/\(filename)")
        let path = URL(fileURLWithPath: filename)
        do {
            let data = try Data(contentsOf: path, options: .uncachedRead)
            return UIImage(data: data)
        } catch {
            NSLog("ERROR INFO: \(error)")
            return nil
        }
    }
}
