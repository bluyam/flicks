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
//  Tab with Now Playing and Top Rated [x]
//  Customize Cell Selection Effect []
//
//  Desired:
//  Play trailer view [x]
//  Display box office price, actors, rating, runtime in collection []
//  Get tickets []
//  Add to 'my movies' [can do]
//  Display reviews (rotten tomatoes, imdb, etc) [can do]
//  Theatres tab []
//  Click on icon to view Trailer
//  Disliked and Liked Movies
//  Watch on Netflix link
//  My Movies Tab []
//  Facebook Integration (Your friends like this movie)

import UIKit
import AFNetworking
import JGProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let endpoints = NSDictionary(objects: [["movies/now_playing","tv/on_the_air"],["movies/top_rated","tv/top_rated"],["movies/upcoming","tv/airing_today"]], forKeys: ["now_playing","top_rated","upcoming"])
    let defaults = NSUserDefaults.standardUserDefaults();
    
    @IBOutlet var collectionView: UICollectionView!
    
    var movies : [NSDictionary]?
    var genres : [NSDictionary]?
    var endpoint : String!
    var refreshControl : UIRefreshControl!
    
    let HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // array of movie dictionaries
        setObjectWithPersistance([NSDictionary](), key: "myFlicks")
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = self.view.backgroundColor
        refreshControl.tintColor = UIColor.lightTextColor()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        collectionView.dataSource = self
        collectionView.delegate  = self
        
        HUD.textLabel.text = "Loading"
        HUD.showInView(self.view!)

        loadAllData()

    }
    
    func loadAllData() {
        loadMovieData()
        loadGenreData()
        self.HUD.dismiss()
        self.refreshControl.endRefreshing()
        
    }
    
    func setObjectWithPersistance(value: AnyObject?, key: String) {
        if (defaults.objectForKey(key) == nil) {
            defaults.setObject(value, forKey: key)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func loadMovieData() {
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
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.collectionView.reloadData()
                    }
                }
                else {
                    print ("A networking error occurred.")
                }
        });
        task.resume()
    }
    
    func loadGenreData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.genres = responseDictionary["genres"] as? [NSDictionary]
                    }
                }
                else {
                    print ("A networking error occurred.")
                }
        });
        task.resume()
    }
    
    func onRefresh() {
        self.HUD.textLabel.text = "Refreshing"
        self.HUD.showInView(self.view)
        self.loadAllData()
        self.HUD.dismiss()

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
        
        let year = movie!["release_date"] as! String
        let rating = movie!["vote_average"] as! NSNumber
        
        cell.yearLabel.text = year.substringWithRange(Range<String.Index>(start: year.startIndex ,end: year.startIndex.advancedBy(4)))
        let ratingDouble = rating.doubleValue
        cell.ratingLabel.text = String(format: "%.1f", ratingDouble)
        
        let baseImageURL = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie!["poster_path"] as? String {
            let imageURL = NSURL(string: baseImageURL + posterPath)
            cell.posterImageView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                if imageResponse != nil {
                    cell.posterImageView.alpha = 0
                    cell.posterImageView.image = image
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        cell.posterImageView.alpha = 1
                    })
                }
                else {
                    cell.posterImageView.image = image
                }
                }, failure: { (imageRequest, imageResponse, imageError) -> Void in
            })
        }
        return cell
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var genre: String?
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.item]
        let genreArray = movie["genre_ids"] as! NSArray
        var genreId = NSNumber(int: 9648)
        
        if genreArray.count > 0 {
            genreId = genreArray[0] as! NSNumber
        }
        
        for genreDict in genres! {
            if (genreDict["id"] as! NSNumber).integerValue == genreId.integerValue {
                genre = genreDict["name"] as? String
            }
        }
        
        let movieViewController = segue.destinationViewController as! MovieViewController
        movieViewController.movie = movie.mutableCopy() as! NSMutableDictionary
        movieViewController.genre = genre
    }

}
