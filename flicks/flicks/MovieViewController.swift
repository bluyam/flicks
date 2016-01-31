//
//  MovieViewController.swift
//  flicks
//
//  Created by Kyle Wilson on 1/24/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit
import JGProgressHUD
import XCDYouTubeKit

class MovieViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    var movie: NSMutableDictionary!
    var similarMovies: [NSDictionary]?
    var cast: [NSDictionary]?
    var reviews: [NSDictionary]?
    var genre: String?
    var videos: [NSDictionary!] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    let baseImageURL = "http://image.tmdb.org/t/p/w500"
    var trailerID: String?
    
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var overviewTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var reviewScrollView: UITextView!
    @IBOutlet var similarMessageLabel: UILabel!
    @IBOutlet var castCollectionView: UICollectionView!
    @IBOutlet var similarCollectionView: UICollectionView!
    
    @IBAction func onAddMoviePressed(sender: UIBarButtonItem) {
        if let genre = genre {
            movie.setValue(genre, forKey: "genre_word")
        }
        else {
            movie.setValue("Unknown Genre", forKey: "genre_word")
        }
        var list = defaults.objectForKey("myFlicks") as! [NSDictionary]
        list.append(movie)
        defaults.setObject(list, forKey: "myFlicks")
        defaults.synchronize()
        saveButton.title = "Saved"
    }
    
    @IBAction func onTouchPlay(sender: AnyObject) {
        if let trailerID = trailerID {
            playVideo(trailerID) // shows YouTube Player in fullscreen view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HUD.textLabel.text = "Loading"
        HUD.frame.origin.y = HUD.frame.origin.y-49
        HUD.showInView(self.view)
        
        loadAllMovieData()
        
        // somehow there's no rating (PG-13/R/etc.) data in this API
        let title = movie!["title"] as! String
        let overview = movie!["overview"] as! String
        let date = numToWordDate(movie!["release_date"] as! String)
        let user_rating = movie!["vote_average"] as! NSNumber
        let voteCount = movie!["vote_count"] as! NSNumber
        
        castCollectionView.dataSource = self
        castCollectionView.delegate = self
        similarCollectionView.dataSource = self
        similarCollectionView.delegate = self
        
        if let genre = genre {
            genreLabel.text = genre
            genreLabel.alpha = 1
        }
        else {
            genreLabel.alpha = 0
        }
        
        if let imagePath = movie!["backdrop_path"] as? String {
            safeSetImageWithURL(self.backdropImageView, imagePath: imagePath)
        }
        if let imagePath = movie!["poster_path"] as? String {
            safeSetImageWithURL(self.posterImageView, imagePath: imagePath)
        }
        
        titleLabel.text = title
        dateLabel.text = date
        overviewTextView.text = overview
        
        let ratingDouble = user_rating.doubleValue
        ratingLabel.text = String(format: "%.1f", ratingDouble)
        voteCountLabel.text = "\(voteCount) Votes"
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: 1525)
    }
    
    func loadAllMovieData() {
        loadData("videos", innerOperation: videoDataInnerOperation)
        loadData("similar", innerOperation: similarDataInnerOperation)
        loadData("credits", innerOperation: castDataInnerOperation)
        loadData("reviews", innerOperation: reviewDataInnerOperation)
        HUD.dismiss()
    }
    
    func safeSetImageWithURL(imageView: UIImageView, imagePath: String) {
        let imageURL = NSURL(string: baseImageURL + imagePath)
        imageView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: UIImage(named: "placeholder"), success: { (imageRequest, imageResponse, image) -> Void in
            if imageResponse != nil {
                imageView.alpha = 0
                imageView.image = image
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    imageView.alpha = 1
                })
            }
            else {
                imageView.image = image
            }
            }, failure: { (imageRequest, imageResponse, imageError) -> Void in
        })
    }
    
    func videoDataInnerOperation(dictData: NSDictionary) {
        self.videos = (dictData["results"] as? [NSDictionary])!
        if self.videos.count > 0 {
            self.trailerID = self.videos[0]["key"] as? String
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.playButton.alpha = 0.5
            })
        }
    }
    
    func similarDataInnerOperation(dictData: NSDictionary) {
        self.similarMovies = (dictData["results"] as? [NSDictionary])!
        self.similarCollectionView.reloadData()
        if self.similarMovies!.count == 0 {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 1060)
            self.similarCollectionView.alpha = 0
            self.similarMessageLabel.alpha = 1
        }
    }
    
    func castDataInnerOperation(dictData: NSDictionary) {
        self.cast = (dictData["cast"] as? [NSDictionary])!
        self.castCollectionView.reloadData()
    }
    
    func reviewDataInnerOperation(dictData: NSDictionary) {
        self.reviews = (dictData["results"] as? [NSDictionary])!
        if self.reviews!.count > 0 {
            self.reviewScrollView.text = self.reviews![0]["content"] as? String
        }
        else {
            self.reviewScrollView.text = "No reviews."
        }
    }
    
    func loadData(endpoint: String, innerOperation: ((dictData: NSDictionary)->Void)) {
        let movie_id = movie!["id"] as! NSNumber
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(movie_id)/\(endpoint)?api_key=\(apiKey)")
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
                            innerOperation(dictData: responseDictionary)
                    }
                }
                else {
                    print ("A networking error occurred.")
                }
        });
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == similarCollectionView {
            let next = self.storyboard?.instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
            let selected_movie = similarMovies![indexPath.item]
            next.movie = selected_movie.mutableCopy() as! NSMutableDictionary
            next.genre = genre
            self.navigationController!.pushViewController(next, animated:true)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == similarCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
            let movie = similarMovies?[indexPath.item]
            let year = movie!["release_date"] as! String
            let rating = movie!["vote_average"] as! NSNumber
            let ratingDouble = rating.doubleValue
            
            cell.yearLabel.text = year.substringWithRange(Range<String.Index>(start: year.startIndex ,end: year.startIndex.advancedBy(4)))
            cell.ratingLabel.text = String(format: "%.1f", ratingDouble)
            
            if let imagePath = movie!["poster_path"] as? String {
                safeSetImageWithURL(cell.posterImageView, imagePath: imagePath)
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CastCell", forIndexPath: indexPath) as! CastCell
            let member = cast?[indexPath.item]
            let name = member!["name"] as! String
            let characterName = member!["character"] as! String
            
            cell.nameLabel.text = name
            cell.characterNameLabel.text = characterName
            
            if let imagePath = member!["profile_path"] as? String {
                safeSetImageWithURL(cell.portraitImageView, imagePath: imagePath)
            }
            else {
                cell.portraitImageView.image = UIImage(named: "placeholder") // only needed for cast members
            }

            return cell
        }
    }
    
    // I'm really sorry about the bracket-to-word ratio
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == similarCollectionView {
            if let similarMovies = similarMovies {
                if similarMovies.count > 4 {
                    return 4
                }
                else {
                    return similarMovies.count
                }
            }
            else {
                return 0
            }
        }
        else {
            if let cast = cast {
                return cast.count
            }
            else {
                return 0
            }
        }
    }

    func playVideo(id: String) {
        let videoPlayerViewController: XCDYouTubeVideoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: id)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: videoPlayerViewController.moviePlayer)
        self.presentMoviePlayerViewControllerAnimated(videoPlayerViewController)
    }
    
    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: notification.object)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numToWordDate(numDate:String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let orignalDate: NSDate = dateFormatter.dateFromString(numDate)!
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.stringFromDate(orignalDate)
    }
}
