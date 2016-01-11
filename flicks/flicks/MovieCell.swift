//
//  MovieCell.swift
//  flicks
//
//  Created by Kyle Wilson on 1/10/16.
//  Copyright © 2016 Bluyam Inc. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    
    @IBOutlet var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
