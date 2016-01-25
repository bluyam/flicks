//
//  MovieViewController.swift
//  flicks
//
//  Created by Kyle Wilson on 1/24/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet var posterImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var ratingLabel: UILabel!

    @IBOutlet var voteCountLabel: UILabel!

    @IBOutlet var overviewTextView: UITextView!
    
    @IBOutlet var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
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
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        let movieData = defaults.objectForKey("currentMovie") as! NSData
        let movie = NSKeyedUnarchiver.unarchiveObjectWithData(movieData) as? NSDictionary
        
        let title = movie!["title"] as! String
        let overview = movie!["overview"] as! String
        let posterPath = movie!["poster_path"] as! String
        let date = numToWordDate(movie!["release_date"] as! String)
        let rating = movie!["vote_average"] as! NSNumber
        let voteCount = movie!["vote_count"] as! NSNumber
        let baseImageURL = "http://image.tmdb.org/t/p/w500"
        let imageURL = NSURL(string: baseImageURL + posterPath)
        
        titleLabel.text = title
        dateLabel.text = date
        overviewTextView.text = overview
        posterImageView.setImageWithURL(imageURL!)
        ratingLabel.text = "\(rating)"
        voteCountLabel.text = "\(voteCount) Voters"
        
    }

}
