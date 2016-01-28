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

class MovieViewController: UIViewController {
    
    let HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Dark)
    
    var movie: NSDictionary!
    
    var videos: [NSDictionary!] = []
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let baseImageURL = "http://image.tmdb.org/t/p/w500"
    
    var trailerID: String?
    
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var overviewTextView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var playButton: UIButton!
    
    @IBAction func onTouchPlay(sender: AnyObject) {
        // will show XCDYouTubeKit fullscreen view
        if let trailerID = trailerID {
            print(trailerID)
            playVideo(trailerID)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: 668) // will fit to content later
        
        HUD.textLabel.text = "Loading"
        HUD.frame.origin.y = HUD.frame.origin.y-49
        HUD.showInView(self.view)
        
        loadVideoData()
        
        let title = movie!["title"] as! String
        let overview = movie!["overview"] as! String
        let date = numToWordDate(movie!["release_date"] as! String)
        let rating = movie!["vote_average"] as! NSNumber
        let voteCount = movie!["vote_count"] as! NSNumber
        
        safeSetImageWithURL(self.backdropImageView, key: "backdrop_path")
        safeSetImageWithURL(self.posterImageView, key: "poster_path")
        
        titleLabel.text = title
        dateLabel.text = date
        overviewTextView.text = overview
        
        let ratingDouble = rating.doubleValue
        ratingLabel.text = String(format: "%.1f", ratingDouble)
        voteCountLabel.text = "\(voteCount) Voters"
    }
    
    func safeSetImageWithURL(imageView: UIImageView, key: String) {
        if let imagePath = movie![key] as? String {
            let imageURL = NSURL(string: baseImageURL + imagePath)
            imageView.setImageWithURLRequest(NSURLRequest(URL: imageURL!), placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
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
    }
    
    func loadVideoData() {
        let movie_id = movie!["id"] as! NSNumber
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(movie_id)/videos?api_key=\(apiKey)")
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
                            self.videos = (responseDictionary["results"] as? [NSDictionary])!
                            self.trailerID = self.videos[0]["key"] as? String
                            UIView.animateWithDuration(0.25, animations: { () -> Void in
                                self.playButton.alpha = 0.5
                            })
                            self.HUD.dismiss()
                    }
                }
                else {
                    print ("A networking error occurred.")
                }
        });
        task.resume()
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
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numToWordDate(numDate:String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let orignalDate: NSDate = dateFormatter.dateFromString(numDate)!
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.stringFromDate(orignalDate)
    }
}
