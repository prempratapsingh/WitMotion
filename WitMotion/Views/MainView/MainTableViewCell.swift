//
//  MainTableViewCell.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 22/03/23.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    // MARK: Public properties
    
    static let identifier = "MainTableViewCell"
    
    // MARK: UI controls
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .blue
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .blue
        return label
    }()
    
    private lazy var rssiLevelImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "M1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.subTitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yellow
        return view
    }()
    
    // MARK: Lifecycle methods
        
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureView()
    }
    
    // MARK: Public methods
    
    func display(title: String, subTitle: String, image: UIImage?) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        
        if let levelImage = image {
            self.rssiLevelImgView.image = levelImage
        } else {
            self.rssiLevelImgView.isHidden = true
        }
    }
    
    // MARK: Private methods
        
    private func configureView() {
        self.selectionStyle = .none
        
        self.addSubview(self.bgView)
        NSLayoutConstraint.activate([
            self.bgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.bgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            self.bgView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        ])
        
        self.addSubview(self.vStackView)
        NSLayoutConstraint.activate([
            self.vStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.vStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            self.vStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            self.vStackView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
        
        self.addSubview(self.rssiLevelImgView)
        NSLayoutConstraint.activate([
            self.rssiLevelImgView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            self.rssiLevelImgView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            self.rssiLevelImgView.widthAnchor.constraint(equalToConstant: 40),
            self.rssiLevelImgView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
