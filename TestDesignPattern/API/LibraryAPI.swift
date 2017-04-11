//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by Hung Chang Lo on 11/04/2017.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import UIKit
import Foundation

/**
    The Singleton design pattern ensures that only one instance exists for a given class and that there’s a global access point to that instance. It usually uses lazy loading to create the single instance when it’s needed the first time.
 
    Note: Apple uses this approach a lot. 
    For example: NSUserDefaults.standardUserDefaults(), UIApplication.sharedApplication(), UIScreen.mainScreen(), NSFileManager.defaultManager() all return a Singleton object.
 
    ---------------------------------------------------------------------
 
    The Facade design pattern provides a single interface to a complex subsystem. Instead of exposing the user to a set of classes and their APIs, you only expose one simple unified API.

    When designing a Facade for classes in your subsystem, remember that nothing prevents the client from accessing these “hidden” classes directly. Don’t be stingy with defensive code and don’t assume that all the clients will necessarily use your classes the same way the Facade uses them.
 */
class LibraryAPI: NSObject {
    private let persistencyManager: PersistencyManager!
    private let httpClient: HTTPClient!
    private let isOnline: Bool!
    
    /**
        1. Create a class variable as a computed type property. The class variable, like class methods in Objective-C, is something you can call without having to instantiate the class LibraryAPI For more information about type properties please refer to Apple’s Swift documentation on properties
     */
    class var sharedInstance: LibraryAPI {
        /** 
            2. Nested within the class variable is a struct called Singleton.
         */
        struct Singleton {
            /** 
                3. Singleton wraps a static constant variable named instance. Declaring a property as static means this property only exists once. Also note that static properties in Swift are implicitly lazy, which means that Instance is not created until it’s needed. Also note that since this is a constant property, once this instance is created, it’s not going to create it a second time. This is the essence of the Singleton design pattern. The initializer is never called again once it has been instantiated.
             */
            static let instance = LibraryAPI()
        }
        
        /**
            4. Returns the computed type property.
         */
        return Singleton.instance
    }
    
    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        
        /**
            The HTTP client doesn’t actually work with a real server and is only here to demonstrate the usage of the facade pattern, so isOnline will always be false.
         */
        isOnline = false
        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryAPI.downloadImage), name: NSNotification.Name(rawValue: "BLDownloadImageNotification"), object: nil)
    }
    
    // When this object is deallocated, it removes itself as an observer from all notifications it had registered for.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    func addAlbum(album: Album, Index: Int) {
        persistencyManager.addAlbum(album: album,index: Index)
        if isOnline {
            _ = httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }

    func deleteAlbum(index: Int) {
        persistencyManager.removeAlbumAtIndex(index: index)
        if isOnline {
            _ = httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    func downloadImage(notification: NSNotification) {
        // 1 - downloadImage is executed via notifications and so the method receives the notification object as a parameter. The UIImageView and image URL are retrieved from the notification
        let userInfo = notification.userInfo as! [String: AnyObject]
        let imageView = userInfo["imageView"] as! UIImageView?
        let coverUrl = userInfo["coverUrl"] as! String
        
        
        // 2 - Retrieve the image from the PersistencyManager if it’s been downloaded previously
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage(filename: coverUrl)
            if imageViewUnWrapped.image == nil {

                // 3 - If the image hasn’t already been downloaded, then retrieve it using HTTPClient
                let queue = DispatchQueue(label: "tw.dev.hungclo.designPatterns", qos: DispatchQoS.default)
                queue.async {
                    () -> Void in
                    let downloadedImage = self.httpClient.downloadImage(coverUrl as String)
                    
                    // 4 - When the download is complete, display the image in the image view and use the PersistencyManager to save it locally
                    DispatchQueue.main.sync {
                        () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(image: downloadedImage, filename: coverUrl)
                    }
                }
            }
        }
    }
}
