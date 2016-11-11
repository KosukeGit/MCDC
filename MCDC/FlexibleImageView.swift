//
//  FlexibleImageView.swift
//  MCDC
//
//  Created by x13089xx on 2016/11/03.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit
/**
 * 画像のピンチイン、ピンチアウト、回転、移動
 */
class FlexibleImageView: UIImageView,UIGestureRecognizerDelegate {
    
    var scale: Float = 0.0
    var rotation: Float = 0.0
    var isChange = false
    var isReset = false
    var defaultTransform: CGAffineTransform?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup() {
        self.userInteractionEnabled = true
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(FlexibleImageView.doAnimation(_:)))
        rotation.delegate = self
        self.addGestureRecognizer(rotation)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(FlexibleImageView.doAnimation(_:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
        
        self.isChange = false
        self.scale = 1.0
        self.rotation = 0.0
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(FlexibleImageView.doPanAciton(_:)))
        self.addGestureRecognizer(pan)
    }
    
    //MARK: - Action
    func doPanAciton(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.superview!)
        let movedPoint = CGPointMake(self.center.x + translation.x, self.center.y + translation.y)
        self.center = movedPoint
        sender.setTranslation(CGPointZero, inView: self)
    }
    
    func doAnimation(sender: UIGestureRecognizer) {
        
        if !isChange && sender.state == UIGestureRecognizerState.Began {
            
            isChange = true
            defaultTransform = self.transform
            
        } else if isChange && sender.state == UIGestureRecognizerState.Ended {
            reset()
            return
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            return
        }
        
        if sender.isKindOfClass(UIRotationGestureRecognizer) {
            
            self.rotation = Float((sender as! UIRotationGestureRecognizer).rotation)
        } else {
            self.scale = Float((sender as! UIPinchGestureRecognizer).scale)
        }
        
        let transform = CGAffineTransformConcat(
            CGAffineTransformConcat(self.defaultTransform!, CGAffineTransformMakeRotation(CGFloat(self.rotation))),
            CGAffineTransformMakeScale(CGFloat(self.scale), CGFloat(self.scale)))
        
        self.transform = transform
    }
    
    //MARK: - Private
    func resetAnimation() {
        
        if isReset == true {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.transform = self.defaultTransform!
            })
        }
    }
    
    func reset() {
        
        self.isChange = false
        self.scale = 1.0
        self.rotation = 0.0
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(FlexibleImageView.resetAnimation), userInfo: nil, repeats: false)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}