//
//  NSMutableAttributedStrings+Additions.swift
//  Cont
//
//  Created by Aryan Sharma on 23/12/19.
//  Copyright © 2019 Aryan Sharma. All rights reserved.
//

import UIKit

extension UIImage {
    public static func getImage(from givenName: String, lastName: String?, fontSize: CGFloat = 20) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .lightGray
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        let initials = "\(givenName.first?.uppercased() ?? "J")\(lastName?.first?.uppercased() ?? "D")"
        
        nameLabel.text = initials
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
}
