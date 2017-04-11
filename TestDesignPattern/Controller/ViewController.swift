/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController {
	@IBOutlet var dataTable: UITableView!
	@IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var scroller: HorizontalScroller!
    
    fileprivate var allAlbums = [Album]()
    fileprivate var currentAlbumData: (titles: [String], values: [String])?
    fileprivate var currentAlbumIndex = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
        
        // 1. Turn off translucency on the navigation bar.
        self.navigationController?.navigationBar.isTranslucent = false
        currentAlbumIndex = 0
        
        // 2. Get a list of all the albums via the API. Remember, the plan is to use the facade of LibraryAPI rather than PersistencyManager directly!
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        
        // 3
        /** 
            The UITableView that presents album data

            This is where you setup the UITableView. You declare that the view controller is the UITableView delegate/data source; therefore, all the information required by UITableView will be provided by the view controller. Note that you can actually set the delegate and datasource in a storyboard, if your table view is created there.
         */
        dataTable.delegate = self
        dataTable.dataSource = self
        dataTable.backgroundView = nil
        view.addSubview(dataTable)
        
        self.showDataForAlbum(albumIndex: currentAlbumIndex)
        
        scroller.horizontalScrollerDelegate = self
        reloadScroller()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    /**
        Description: fetches the required album data from the array of albums. When you want to present the new data, you just need to call reloadData. This causes UITableView to ask its delegate such things as how many sections should appear in the table view, how many rows in each section, and how each cell should look.
     */
    func showDataForAlbum(albumIndex: Int) {
        // defensive code: make sure the requested index is lower than the amount of albums
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            //fetch the album
            let album = allAlbums[albumIndex]
            // save the albums data to present it later in the tableview
            currentAlbumData = album.ae_tableViewRepresentation()
        } else {
            currentAlbumData = nil
        }
        // we have the data we need, let's refresh our tableview
        dataTable!.reloadData()
    }

    
    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        scroller.reload()
        showDataForAlbum(albumIndex: currentAlbumIndex)
    }
}

/**
    You can actually add the methods to the main class declaration or to the extension; the compiler doesn’t care that the data source methods are actually inside the UITableViewDataSource extension. For humans reading the code though, this kind of organization really helps with readability.
 */
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumData = currentAlbumData {
            return albumData.titles.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        if let albumData = currentAlbumData {
            cell.textLabel?.text = albumData.titles[indexPath.row]
            cell.detailTextLabel?.text = albumData.values[indexPath.row]
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: HorizontalScrollerDelegate {
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
        // 1 - First you grab the previously selected album, and deselect the album cover
        let previousAlbumView = scroller.viewAtIndex(index: currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(didHighlightView: false)
        
        // 2 - Store the current album cover index you just clicked
        currentAlbumIndex = index

        // 3 - Grab the album cover that is currently selected and highlight the selection
        let albumView = scroller.viewAtIndex(index: index) as! AlbumView
        albumView.highlightAlbum(didHighlightView: true)
        
        // 4 - Display the data for the new album within the table view
        showDataForAlbum(albumIndex: index)
    }
    
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int {
        return allAlbums.count
    }
    
    /**
        Here you create a new AlbumView, next check to see whether or not the user has selected this album. Then you can set it as highlighted or not depending on whether the album is selected. Lastly, you pass it to the HorizontalScroller
     */
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> UIView {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.coverUrl)
        if currentAlbumIndex == index {
            albumView.highlightAlbum(didHighlightView: true)
        } else {
            albumView.highlightAlbum(didHighlightView: false)
        }
        return albumView
    }
    
    /**
        Because:
        It looks like the album data is correct, but the scroller isn’t centered on the correct album. What gives?
        This is what the optional method initialViewIndexForHorizontalScroller was meant for! Since that method’s not implemented in the delegate, ViewController in this case, the initial view is always set to the first view.
     
        Solution:
        Now the HorizontalScroller first view is set to whatever album is indicated by currentAlbumIndex. This is a great way to make sure the app experience remains personal and resumable.
     */
    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
}
