//
//  KNAutoLayoutPaddingFix.swift
//  KNAutoLayoutPaddingFix
//
//  Created by vbn on 2016/12/19.
//  Copyright © 2016年 vbn. All rights reserved.
//

import UIKit

struct  KNAutoLayoutPaddingFixAxis : OptionSet{
    let rawValue: Int
    static let KNAutoLayoutPaddingFixAxisTop = KNAutoLayoutPaddingFixAxis(rawValue:1 << 0)
    static let KNAutoLayoutPaddingFixAxisLeft = KNAutoLayoutPaddingFixAxis(rawValue:1 << 1)
    static let KNAutoLayoutPaddingFixAxisRight = KNAutoLayoutPaddingFixAxis(rawValue:1 << 2)
    static let KNAutoLayoutPaddingFixAxisBottom = KNAutoLayoutPaddingFixAxis(rawValue:1 << 3)
}

private struct KNRestoreConstraintAssociateKey {
    static var restoreConstraintsKey  = "restoreConstraintsKey"
}

extension UIView {
    
    var restoreConstraints: NSMutableArray? {
        get {
            return objc_getAssociatedObject(self, &KNRestoreConstraintAssociateKey.restoreConstraintsKey) as? NSMutableArray
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &KNRestoreConstraintAssociateKey.restoreConstraintsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class KNAutoLayoutPaddingFix: NSObject {

    private static let KNCONSTAINTKEY = "constaint"
    private static let KNCONSTANTKEY = "constant"
    
    
    public class func fixViews(views:[UIView],axis:KNAutoLayoutPaddingFixAxis) {
        for view in views {
            self.fixView(view: view, axis: axis)
        }
    }
    
    public class func fixView(view:UIView, axis:KNAutoLayoutPaddingFixAxis) {
        if view.restoreConstraints == nil {
            view.restoreConstraints = NSMutableArray()
        }
        view.restoreConstraints?.removeAllObjects()
        
        if axis.contains(.KNAutoLayoutPaddingFixAxisTop) {
            let topConstraint = self.findTopConstraintWithView(view: view)
            guard topConstraint != nil else {
                return
            }
            self.setView(view: view, constant: 0, constraint: topConstraint!)
        }
        
        if axis.contains(.KNAutoLayoutPaddingFixAxisLeft) {
            let leftConstraint = self.findLeftConstraintWithView(view: view)
            guard leftConstraint != nil else {
                return
            }
            self.setView(view: view, constant: 0, constraint: leftConstraint!)
        }
        
        if axis.contains(.KNAutoLayoutPaddingFixAxisRight) {
            let rightConstraint = self.findRightConstraintWithView(view: view)
            guard rightConstraint != nil else {
                return
            }
            self.setView(view: view, constant: 0, constraint: rightConstraint!)
        }
        
        if axis.contains(.KNAutoLayoutPaddingFixAxisBottom) {
            let bottomConstraint = self.findBottomConstraintWithView(view: view)
            guard bottomConstraint != nil else {
                return
            }
            self.setView(view: view, constant: 0, constraint: bottomConstraint!)
        }
    }
    
    private class func setView(view: UIView, constant: CGFloat, constraint: NSLayoutConstraint) {
        var parms : [String:AnyObject] = [:]
        parms[KNCONSTAINTKEY] = constraint
        parms[KNCONSTANTKEY] = NSNumber(floatLiteral:Double(constraint.constant)) as AnyObject
        view.restoreConstraints?.add(parms)
        constraint.constant = constant
    }
    
    public class func restoreViews(views:[UIView]) {
        for view in views {
            self.restoreView(view: view)
        }
    }
    
    public class func restoreView(view:UIView) {
        guard view.restoreConstraints != nil else {
            return
        }
        for d in view.restoreConstraints! {
            let parms = d as! NSDictionary
            let constraint = parms[KNCONSTAINTKEY] as! NSLayoutConstraint
            let constant = parms[KNCONSTANTKEY] as! NSNumber
            constraint.constant = CGFloat(constant.doubleValue)
        }
        view.restoreConstraints?.removeAllObjects()
    }
    
    private class func findView(view: UIView,attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        var constraint : NSLayoutConstraint?
        guard view.superview != nil else {
            return nil;
        }
        let superView   = view.superview!
        for c in superView.constraints {
            if ((c.firstItem as? UIView == view && c.firstAttribute == attribute) ||
                (c.secondItem as? UIView == view && c.secondAttribute == attribute)) {
                constraint = c
                break;
            }
        }
        return constraint
    }
    
    private class func findTopConstraintWithView(view:UIView) -> NSLayoutConstraint? {
        return self.findView(view: view, attribute: .top)
    }
    
    private class func findLeftConstraintWithView(view:UIView) -> NSLayoutConstraint? {
        return self.findView(view: view, attribute: .leading)
    }
    
    private class func findRightConstraintWithView(view:UIView) -> NSLayoutConstraint? {
        return self.findView(view: view, attribute: .trailing)
    }
    
    private class func findBottomConstraintWithView(view:UIView) -> NSLayoutConstraint? {
        return self.findView(view: view, attribute: .bottom)
    }
}
