//
//  UIView+FKAutoLayout.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit

func FKAutoLayoutMakeSize(_ a: Any, _ attr1: NSLayoutConstraint.Attribute, _ relation: NSLayoutConstraint.Relation, _ c: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(item: a,
                              attribute: attr1,
                              relatedBy: relation,
                              toItem: nil,
                              attribute: .notAnAttribute,
                              multiplier: 1,
                              constant: c)
}

func FKAutoLayoutMake(_ a: Any, _ attr1: NSLayoutConstraint.Attribute, _ relation: NSLayoutConstraint.Relation, _ b: Any, _ attr2: NSLayoutConstraint.Attribute, _ c: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(item: a,
                              attribute: attr1,
                              relatedBy: relation,
                              toItem: b,
                              attribute: attr2,
                              multiplier: 1,
                              constant: c)
}

func FKAutoLayoutMakeM(_ a: Any, _ attr1: NSLayoutConstraint.Attribute, _ relation: NSLayoutConstraint.Relation, _ b: Any, _ attr2: NSLayoutConstraint.Attribute, _ n: CGFloat, _ c: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(item: a,
                              attribute: attr1,
                              relatedBy: relation,
                              toItem: b,
                              attribute: attr2,
                              multiplier: n,
                              constant: c)
}

extension UIView {
    func autoFillSuperView() -> [NSLayoutConstraint] {
        return autoFillSuperView(withInsets: .zero)
    }

    func autoFillSuperView(withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let c1 = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1, constant: insets.left)
        let c2 = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1, constant: -insets.right)
        let c3 = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1, constant: insets.top)
        let c4 = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1, constant: -insets.bottom)
        
        let array = [c1, c2, c3, c4]
        
        self.superview?.addConstraints(array)
        
        return array
    }
}
