//
//  UserCell.swift
//  Bestie
//
//  Created by Michael Saltzman on 2/19/16.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userPhoto: UIImageView!    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
