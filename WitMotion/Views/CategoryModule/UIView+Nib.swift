//
//  UIView+Nib.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit

extension UIView {

    class var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle.main)
    }

    class func nib(withName name: String) -> UINib {
        return UINib(nibName: name, bundle: Bundle.main)
    }

    class func loadFromNib<T: UIView>() -> T {
        return loadFromNib(nibName: String(describing: self))
    }

    class func loadFromNib<T: UIView>(nibName: String) -> T {
        return nib(withName: nibName).instantiate(withOwner: nil, options: nil).first as! T
    }

    class func loadFromNib<T: UIView>(withFrame frame: CGRect) -> T {
        let nibView: T = loadFromNib()
        nibView.frame = frame
        return nibView
    }

    func loadFromNib() {
        let nibView = type(of: self).loadFromNib()
        addSubview(nibView)
        nibView.autoFillSuperview()
    }

    func customize() {
        // implement your customization logic here
    }
}

extension UIView {

    func autoFillSuperview() -> [NSLayoutConstraint] {
        return autoFillSuperview(withInsets: .zero)
    }

    func autoFillSuperview(withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        let c1 = leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: insets.left)
        let c2 = trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: -insets.right)
        let c3 = topAnchor.constraint(equalTo: superview!.topAnchor, constant: insets.top)
        let c4 = bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -insets.bottom)

        let constraints = [c1, c2, c3, c4]

        NSLayoutConstraint.activate(constraints)

        return constraints
    }
}
