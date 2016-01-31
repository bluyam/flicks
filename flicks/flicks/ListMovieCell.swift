//
//  ListMovieCell.swift
//  flicks
//
//  Created by Kyle Wilson on 1/30/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit

class ListMovieCell: UITableViewCell {

    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
