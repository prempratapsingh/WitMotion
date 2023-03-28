//
//  HeaderItemCell.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit

class HeaderItemCell: UICollectionViewCell {
    static let cellIdentifier = "HeaderItemCell"
    var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = UIColor(red: 95/255.0, green: 218/255.0, blue: 220/255.0, alpha: 0.3)
            } else {
                contentView.backgroundColor = .clear
            }
        }
    }
}
