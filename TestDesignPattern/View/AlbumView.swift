//
//  AlbumView.swift
//  BlueLibrarySwift
//
//  Created by Hung Chang Lo on 11/04/2017.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import Foundation
import UIKit

class AlbumView: UIView {
    private var coverImage: UIImageView!
    private var indicator: UIActivityIndicatorView!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    init(frame: CGRect, albumCover: String) {
        super.init(frame: frame)
        commonInit()
        
        /**
            Observer Patterns:
            In the Observer pattern, one object notifies other objects of any state changes. The objects involved don’t need to know about one another – thus encouraging a decoupled design. This pattern’s most often used to notify interested objects when a property has changed.
            The usual implementation requires that an observer registers interest in the state of another object. When the state changes, all the observing objects are notified of the change.
            If you want to stick to the MVC concept (hint: you do), you need to allow Model objects to communicate with View objects, but without direct references between them. And that’s where the Observer pattern comes in.
            Cocoa implements the observer pattern in two familiar ways: Notifications and Key-Value Observing (KVO).
         */
        
        /**
            This line sends a notification through the NSNotificationCenter singleton. The notification info contains the UIImageView to populate and the URL of the cover image to be downloaded. That’s all the information you need to perform the cover download task.
         */
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BLDownloadImageNotification"), object: self, userInfo: ["imageView":coverImage, "coverUrl" : albumCover])
    }
    
    func commonInit() {
        backgroundColor = UIColor.black
        coverImage = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10))
        addSubview(coverImage)
        indicator = UIActivityIndicatorView()
        indicator.center = center
        indicator.activityIndicatorViewStyle = .whiteLarge
        //indicator.startAnimating()
        addSubview(indicator)
    }
    
    func highlightAlbum(didHighlightView: Bool) {
        if didHighlightView {
            backgroundColor = UIColor.white
        } else {
            backgroundColor = UIColor.black
        }
    }
}
