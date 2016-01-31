//
//  MyFlicksViewController.swift
//  flicks
//
//  Created by Kyle Wilson on 1/30/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit

class MyFlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var movies: [NSDictionary] = []
    
    var genres: [String!] = [] 

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movies = defaults.objectForKey("myFlicks") as! [NSDictionary]
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("MovieViewController") as! MovieViewController
        let movie = self.movies[indexPath.row]
        next.movie = movie.mutableCopy() as! NSMutableDictionary
        next.genre = genres[indexPath.row]
        self.navigationController!.pushViewController(next, animated:true)
    }
    
    // displays all movies the user has added
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movies.count > 0 {
            return movies.count
        }
        else {
            // this cell contains the message notifying the user that no movies have been added
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListMovieCell", forIndexPath: indexPath) as! ListMovieCell
        if movies.count > 0 {
            cell.messageLabel.alpha = 0
            
            let movie = movies[indexPath.row]
            let title = movie["title"] as! String
            let date = numToWordDate(movie["release_date"] as! String)
            let genre = movie["genre_word"] as! String // must add this when you open the detail view
            let rating = movie["vote_average"] as! NSNumber
            let ratingDouble = rating.doubleValue
            let voteCount = movie["vote_count"] as! NSNumber
        
            safeSetImageWithURL(movie, imageView: cell.posterImageView, key: "poster_path")
            genres.append(genre)
            
            cell.titleLabel.text = title
            cell.dateLabel.text = date
            cell.genreLabel.text = genre
            cell.ratingLabel.text = String(format: "%.1f", ratingDouble)
            cell.voteCountLabel.text = "\(voteCount) Votes"
            
            return cell
        }
        else {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                cell.messageLabel.alpha = 1
            })
            return cell
        }
    }
    
    func safeSetImageWithURL(movie: NSDictionary, imageView: UIImageView, key: String) {
        let baseImageURL = "http://image.tmdb.org/t/p/w500"
        if let imagePath = movie[key] as? String {
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
    
    func numToWordDate(numDate:String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let orignalDate: NSDate = dateFormatter.dateFromString(numDate)!
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.stringFromDate(orignalDate)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        movies = defaults.objectForKey("myFlicks") as! [NSDictionary]
        tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
