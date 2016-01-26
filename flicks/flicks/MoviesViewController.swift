//
//  MoviesViewController.swift
//  flicks
//
//  Created by Kyle Wilson on 1/9/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//
//  TODO: Make as useful as possible
//
//  Required: 
//  Week 1 Stuff (Refresh, load image with afnetworking, Loading state when pulling data) [x]
//  View Movie Details by Tapping Single Cell [x]
//  Tab with Now Playing and Top Rated []
//  Customize Cell Selection Effect []
//
//  Desired:
//  Play trailer view
//  Display box office price, actors, rating, runtime in collection
//  Get tickets
//  Add to 'my movies'
//  Display reviews (rotten tomatoes, imdb, etc)
//  Theatres tab
//  Click on icon to view Trailer
//  Disliked and Liked Movies
//  Watch on Netflix link
//  My Movies Tab
//  Tinder style movie match
//  Facebook Integration (Your friends like this movie)

import UIKit
import AFNetworking
import JGProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults();
    
    @IBOutlet var collectionView: UICollectionView!
    
    var movies : [NSDictionary]?
    
    var endpoint : String!
    
    var refreshControl : UIRefreshControl!
    
    let HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
    
    // let errorView = UILabel(frame: CGRect(x: 0, y: 20, width: 320, height: 40))
    
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
        
        /*errorView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        errorView.textColor = UIColor.whiteColor()
        errorView.font = UIFont.systemFontOfSize(12)
        errorView.textAlignment = NSTextAlignment.Center*/
        loadData()

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func showNetworkErrorView(message: String) {
//        errorView.text = message
//        self.collectionView.layer.frame.origin.y = 60
//        self.view!.addSubview(errorView)
        self.HUD.dismiss()
    }
    
    func hideNetworkErrorView() {
//        if (errorView.superview == self.view!) {
//            errorView.removeFromSuperview()
//        }
//        self.collectionView.layer.frame.origin.y = 20
        self.HUD.dismiss()
    }
    
    func loadData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let error = error {
                    print("there was an error")
                    self.showNetworkErrorView(error.localizedDescription)
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
                            self.refreshControl.endRefreshing()
                    }
                }
                
                else {
                    print ("A networking error occurred.")
                }
        });
        task.resume()
    }
    
    func onRefresh() {
        self.loadData()

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
        cell.movieTitleLabel.text = title
        
        let baseImageURL = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie!["poster_path"] as? String {
            let imageURL = NSURL(string: baseImageURL + posterPath)
            cell.posterImageView.setImageWithURL(imageURL!)
        }
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.item]
        
        let movieViewController = segue.destinationViewController as! MovieViewController
        movieViewController.movie = movie
    }

}
