//
//  MoviesViewController.swift
//  flicks
//
//  Created by Kyle Wilson on 1/9/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit
import AFNetworking
import JGProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults();
    
    @IBOutlet var collectionView: UICollectionView!
    
    var movies : [NSDictionary]?
    
    var refreshControl : UIRefreshControl!
    
    let HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    
    let errorView = UILabel(frame: CGRect(x: 0, y: 20, width: 320, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = self.view.backgroundColor
        refreshControl.tintColor = UIColor.lightTextColor()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        collectionView.dataSource = self
        collectionView.delegate  = self
        
        // loading begin (show)
        
        HUD.textLabel.text = "Loading"
        HUD.showInView(self.view!)

        // Do any additional setup after loading the view.
        
        errorView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        errorView.textColor = UIColor.whiteColor()
        errorView.font = UIFont.systemFontOfSize(12)
        errorView.textAlignment = NSTextAlignment.Center
        loadData()

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func showNetworkErrorView(message: String) {
        errorView.text = message
        self.collectionView.layer.frame.origin.y = 60
        self.view!.addSubview(errorView)
        self.HUD.dismiss()
    }
    
    func hideNetworkErrorView() {
        if (errorView.superview == self.view!) {
            errorView.removeFromSuperview()
        }
        self.collectionView.layer.frame.origin.y = 20
        self.HUD.dismiss()
    }
    
    func loadData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 10.0)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                // print("dataOrNil \(dataOrNil)")
                // print("response \(response)")
                // print("error \(error)")
                if let actualError = error {
                    print("there was an error")
                    self.showNetworkErrorView(actualError.localizedDescription)
                    return
                }
                
                if (response is NSHTTPURLResponse) {
                    let statusCode: Int = (response as! NSHTTPURLResponse).statusCode
                    if statusCode != 200 {
                        self.showNetworkErrorView("Network Error: \(statusCode)")
                        return
                    }
                }
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
                            self.hideNetworkErrorView()
                    }
                }
        });
        task.resume()
    }
    
    func onRefresh() {
        self.loadData()
        self.refreshControl.endRefreshing()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies?[indexPath.item]
        let title = movie!["title"] as! String
        let posterPath = movie!["poster_path"] as! String
        
        let baseImageURL = "http://image.tmdb.org/t/p/w500"
        
        let imageURL = NSURL(string: baseImageURL + posterPath)
        
        cell.movieTitleLabel.text = title
        cell.posterImageView.setImageWithURL(imageURL!)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let movieAsNSData = NSKeyedArchiver.archivedDataWithRootObject(movies![indexPath.row])
        defaults.setObject(movieAsNSData, forKey: "currentMovie")
        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
