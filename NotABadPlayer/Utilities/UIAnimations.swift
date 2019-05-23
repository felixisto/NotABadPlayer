//
//  ViewAnimation.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 11.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class UIAnimations {
    public static let CLICK_COLOR = UIColor(red:0.0, green:0.7, blue:0.25, alpha:1.0)
    public static let CLICK_ANIMATION_DURATION: Double = 0.5
    public static let FADE_OUT_ANIMATION_DURATION: Double = 0.5
    
    public static let UPDATE_COUNT: Double = 5
    
    static func stopAnimations(_ view: UIView) {
        CATransaction.begin()
        view.layer.removeAllAnimations()
        CATransaction.commit()
    }
    
    static func animateImageClicked(_ image: UIImageView) {
        let currentColor = image.tintColor
        
        image.tintColor = CLICK_COLOR
        
        UIView.animate(withDuration: CLICK_ANIMATION_DURATION,
                       delay: CLICK_ANIMATION_DURATION / UPDATE_COUNT,
                       options: [.allowUserInteraction],
                       animations: {image.tintColor = currentColor},
                       completion: nil)
    }
    
    static func animateViewFadeOut(_ view: UIView) {
        view.alpha = 1
        
        UIView.animate(withDuration: FADE_OUT_ANIMATION_DURATION,
                       delay: FADE_OUT_ANIMATION_DURATION / UPDATE_COUNT,
                       options: [],
                       animations: {view.alpha = 0},
                       completion: nil)
    }
}
