//
//  UserTableViewCell.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/02/09.
//

import UIKit
class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.image = nil

    }
}
