//
//  MainView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class MainView : UIView
{
    public static let TAB_BAR_HEIGHT: CGFloat = 48
    
    @IBOutlet weak var tabBar: MainTabView!
    @IBOutlet weak var quickPlayer: QuickPlayerView!
    
    var albumsButton: UIImageView {
        get {
            return tabBar.albumsButton
        }
    }
    
    var listsButton: UIImageView {
        get {
            return tabBar.listsButton
        }
    }
    
    var searchButton: UIImageView {
        get {
            return tabBar.searchButton
        }
    }
    
    var settingsButton: UIImageView {
        get {
            return tabBar.settingsButton
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        let guide = self.safeAreaLayoutGuide
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        tabBar.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        tabBar.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        tabBar.heightAnchor.constraint(equalToConstant: MainView.TAB_BAR_HEIGHT).isActive = true
    }
    
    func embedViewIntoPrimaryArea(_ view: UIView) {
        if view.superview != self
        {
            fatalError("MainView: Cannot embed a non-child of this view")
        }
        
        let guide = self.safeAreaLayoutGuide
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: tabBar.bottomAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
    }
}

// Builder
extension MainView {
    class func create(owner: Any) -> MainView? {
        let bundle = Bundle.main
        let nibName = String(describing: MainView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? MainView
    }
}
