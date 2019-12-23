//
//  ContactCell.swift
//  Cont
//
//  Created by Aryan Sharma on 23/12/19.
//  Copyright © 2019 Aryan Sharma. All rights reserved.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.layer.cornerRadius = imgView.frame.width/4
        imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func initWith(contact: CNContact) {
        let name = contact.givenName + " " + contact.familyName

        self.titleLabel.text = name
        self.subtitleLabel.text = contact.phoneNumbers.first?.value.stringValue ?? "No phone number"
        if let data = contact.imageData {
            imgView.image = UIImage(data: data)
        } else if let image = UIImage.getImage(from: contact.givenName, lastName: contact.familyName) {
            imgView.image = image
        }
    }
    
}
