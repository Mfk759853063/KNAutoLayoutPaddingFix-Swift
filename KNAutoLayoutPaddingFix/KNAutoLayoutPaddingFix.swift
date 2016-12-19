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
    static let KNAutoLayoutPaddingFixAxisHorizontal = KNAutoLayoutPaddingFixAxis(rawValue:1 << 0)
    static let KNAutoLayoutPaddingFixAxisVertical = KNAutoLayoutPaddingFixAxis(rawValue:1 << 1)
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
        
        if axis.contains(.KNAutoLayoutPaddingFixAxisVertical) {
            let topConstraint = self.findTopConstraintWithView(view: view)
            guard topConstraint != nil else {
                return
            }
            var parms : [String:AnyObject] = [:]
            parms[KNCONSTAINTKEY] = topConstraint
            parms[KNCONSTANTKEY] = NSNumber(floatLiteral:Double((topConstraint?.constant)!)) as AnyObject
            view.restoreConstraints?.add(parms)
            topConstraint?.constant = 0
        }
        if axis.contains(.KNAutoLayoutPaddingFixAxisHorizontal) {
            let leftConstraint = self.findLeftConstraintWithView(view: view)
            guard leftConstraint != nil else {
                return
            }
            var parms : [String:AnyObject] = [:]
            parms[KNCONSTAINTKEY] = leftConstraint
            parms[KNCONSTANTKEY] = NSNumber(floatLiteral:Double((leftConstraint?.constant)!)) as AnyObject
            view.restoreConstraints?.add(parms)
            leftConstraint?.constant = 0
        }
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
    
    
    private class func findTopConstraintWithView(view:UIView) -> NSLayoutConstraint? {
        var constraint : NSLayoutConstraint?
        guard view.superview != nil else {
            return nil;
        }
        let superView   = view.superview!
        for c in superView.constraints {
            if ((c.firstItem as? UIView == view && c.firstAttribute == .top) ||
                (c.secondItem as? UIView == view && c.secondAttribute == .top)) {
                constraint = c
                break;
            }
        }
        return constraint
    }
    
    private class func findLeftConstraintWithView(view:UIView) -> NSLayoutConstraint? {
        var constraint : NSLayoutConstraint?
        guard view.superview != nil else {
            return nil;
        }
        let superView   = view.superview!
        for c in superView.constraints {
            if ((c.firstItem as? UIView == view && c.firstAttribute == .leading) ||
                (c.secondItem as? UIView == view && c.secondAttribute == .leading)) {
                constraint = c
                break;
            }
        }
        return constraint
    }
}
