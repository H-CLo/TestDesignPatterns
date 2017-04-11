//
//  HorizontalScroller.swift
//  BlueLibrarySwift
//
//  Created by Hung Chang Lo on 11/04/2017.
//  Copyright © 2017 Raywenderlich. All rights reserved.
//

import UIKit

/**
    Description:
    - An Adapter allows classes with incompatible interfaces to work together. It wraps itself around an object and exposes a standard interface to interact with that object.
    - If you’re familiar with the Adapter pattern then you’ll notice that Apple implements it in a slightly different manner – Apple uses protocols to do the job. You may be familiar with protocols like UITableViewDelegate, UIScrollViewDelegate, NSCoding and NSCopying. As an example, with the NSCopying protocol, any class can provide a standard copy method.
 */

/**
    Note: You’re including @objc before the protocol declaration so you can make use of @optional delegate methods like in Objective-C.
 */
@objc protocol HorizontalScrollerDelegate {
    // ask the delegate how many views he wants to present inside the horizontal scroller
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int

    // ask the delegate to return the view that should appear at <index>
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index:Int) -> UIView

    // inform the delegate what the view at <index> has been clicked
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index:Int)

    // ask the delegate for the index of the initial view to display. this method is optional
    // and defaults to 0 if it's not implemented by the delegate
    @objc optional func initialViewIndex(scroller: HorizontalScroller) -> Int
}

class HorizontalScroller: UIView {
    /**
        The attribute of the property you created above is defined as weak. This is necessary in order to prevent a retain cycle. If a class keeps a strong reference to its delegate and the delegate keeps a strong reference back to the conforming class, your app will leak memory since neither class will release the memory allocated to the other. All properties in swift are strong by default!
     
        The delegate is an optional, so it’s possible whoever is using this class doesn’t provide a delegate. But if they do, it will conform to HorizontalScrollerDelegate and you can be sure the protocol methods will be implemented there.
     */
    weak var horizontalScrollerDelegate: HorizontalScrollerDelegate?
    
    // 1. Define constants to make it easy to modify the layout at design time. The view’s dimensions inside the scroller will be 100 x 100 with a 10 point margin from its enclosing rectangle.
    private let VIEW_PADDING = 10
    private let VIEW_DIMENSIONS = 100
    private let VIEWS_OFFSET = 100

    // 2. Create the scroll view containing the views.
    private var scroller: UIScrollView!
    
    // 3. Create an array that holds all the album covers.
    var viewArray = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initializeScrollView()
    }
    
    func initializeScrollView() {
        // 1. Create’s a new UIScrollView instance and add it to the parent view.
        scroller = UIScrollView()
        scroller.delegate = self
        addSubview(scroller)
        
        // 2. Turn off autoresizing masks. This is so you can apply your own constraints
        scroller.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Apply constraints to the scrollview. You want the scroll view to completely fill the HorizontalScroller
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        // 4. Create a tap gesture recognizer. The tap gesture recognizer detects touches on the scroll view and checks if an album cover has been tapped. If so, it will notify the HorizontalScroller delegate.
        let tapRecognizer = UITapGestureRecognizer(target: self, action:Selector(("scrollerTapped:")))
        scroller.addGestureRecognizer(tapRecognizer)
    }
    
    /**
     Description: The gesture passed in as a parameter lets you extract the location with locationInView().
     Next, you invoke numberOfViewsForHorizontalScroller() on the delegate. The HorizontalScroller instance has no information about the delegate other than knowing it can safely send this message since the delegate must conform to the HorizontalScrollerDelegate protocol.
     For each view in the scroll view, perform a hit test using CGRectContainsPoint to find the view that was tapped. When the view is found, call the delegate method horizontalScrollerClickedViewAtIndex. Before you break out of the for loop, center the tapped view in the scroll view.
     */
    func scrollerTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        if let delegate = horizontalScrollerDelegate {
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
                let view = scroller.subviews[index] 
                if view.frame.contains(location) {
                    delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: index)
                    scroller.setContentOffset(CGPoint(x: view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, y: 0), animated:true)
                    break
                }
            }
        }
    }
    
    /**
        viewAtIndex simply returns the view at a particular index. You will be using this method later to highlight the album cover you have tapped on.
     */
    func viewAtIndex(index: Int) -> UIView {
        return viewArray[index]
    }
    
    /**
        The reload method is modeled after reloadData in UITableView; it reloads all the data used to construct the horizontal scroller.
     */
    func reload() {
        // 1 - Check if there is a delegate, if not there is nothing to load.
        if let delegate = horizontalScrollerDelegate {
            //2 - Will keep adding new album views on reload, need to reset.
            viewArray = []
            let views: NSArray = scroller.subviews as NSArray
            
            // 3 - remove all subviews
            for view in views {
                (view as AnyObject).removeFromSuperview()
            }
            
            // 4 - xValue is the starting point of the views inside the scroller
            var xValue = VIEWS_OFFSET
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
                // 5 - add a view at the right position
                xValue += VIEW_PADDING
                let view = delegate.horizontalScrollerViewAtIndex(scroller: self, index: index)
                view.frame = CGRect(x: CGFloat(xValue), y: CGFloat(VIEW_PADDING), width: CGFloat(VIEW_DIMENSIONS), height: CGFloat(VIEW_DIMENSIONS))
                scroller.addSubview(view)
                xValue += VIEW_DIMENSIONS + VIEW_PADDING
                // 6 - Store the view so we can reference it later
                viewArray.append(view)
            }
            // 7 - Once all the views are in place, set the content offset for the scroll view to allow the user to scroll through all the albums covers
            scroller.contentSize = CGSize(width: CGFloat(xValue + VIEWS_OFFSET), height: frame.size.height)
            
            // 8 - If an initial view is defined, center the scroller on it
            if let initialView = delegate.initialViewIndex?(scroller: self) {
                scroller.setContentOffset(CGPoint(x: CGFloat(initialView)*CGFloat((VIEW_DIMENSIONS + (2 * VIEW_PADDING))), y: 0), animated: true)
            }
        }
    }
    
    /**
        didMoveToSuperview is called on a view when it’s added to another view as a subview. This is the right time to reload the contents of the scroller.
     */
    override func didMoveToSuperview() {
        reload()
    }
    
    /**
        The code takes into account the current offset of the scroll view and the dimensions and the padding of the views in order to calculate the distance of the current view from the center. The last line is important: once the view is centered, you then inform the delegate that the selected view has changed.
     */
    func centerCurrentView() {
        var xFinal = Int(scroller.contentOffset.x) + (VIEWS_OFFSET/2) + VIEW_PADDING
        let viewIndex = xFinal / (VIEW_DIMENSIONS + (2*VIEW_PADDING))
        xFinal = viewIndex * (VIEW_DIMENSIONS + (2*VIEW_PADDING))
        scroller.setContentOffset(CGPoint(x: xFinal, y: 0), animated: true)
        if let delegate = horizontalScrollerDelegate {
            delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: Int(viewIndex))
        }  
    }
}

/**
    Description: To detect that the user finished dragging inside the scroll view, you’ll need to implement some UIScrollViewDelegate methods. Add the following class extension to the bottom of the file; remember, this must be added after the curly braces of the main class declaration!
 */
extension HorizontalScroller: UIScrollViewDelegate {
    //  informs the delegate when the user finishes dragging. The decelerate parameter is true if the scroll view hasn’t come to a complete stop yet. When the scroll action ends, the the system calls scrollViewDidEndDecelerating.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCurrentView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerCurrentView()
    }
}



























