//
//  CreateListAddedTrackCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 3.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListAddedTrackCell: UITableViewCell
{
    public static let CELL_IDENTIFIER = "cell"
    public static let SIZE = CGSize(width: 0, height: 48)
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var textStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented decode()")
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        // App theme setup
        setupAppTheme()

        // Cover setup
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        coverImage.heightAnchor.constraint(equalToConstant: CreateListAddedTrackCell.SIZE.height).isActive = true
        
        // Text stack setup
        textStackView.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        textStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        titleLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        descriptionLabel.textColor = AppTheme.shared.colorFor(.STANDART_SUBTEXT)
    }
}
