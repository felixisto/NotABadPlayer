//
//  SearchView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SearchView: UIView
{
    public var collectionActionDelegate : BaseSearchViewActionDelegate?
    
    public var collectionDataSource : BaseSearchViewDataSource? {
        get { return searchBaseView.collectionDataSource }
        set { searchBaseView.collectionDataSource = newValue }
    }
    
    public var highlightedChecker : BaseSearchHighlighedChecker? {
        get { return searchBaseView.highlightedChecker }
        set { searchBaseView.highlightedChecker = newValue }
    }
    
    public var favoritesChecker : BaseSearchFavoritesChecker? {
        get { return searchBaseView.favoritesChecker }
        set { searchBaseView.favoritesChecker = newValue }
    }
    
    public var onSearchResultClickedCallback: (UInt)->Void {
        get { return searchBaseView.onSearchResultClickedCallback }
        set { searchBaseView.onSearchResultClickedCallback = newValue }
    }
    public var onSearchFieldTextEnteredCallback: (String)->Void {
        get { return searchBaseView.onSearchFieldTextEnteredCallback }
        set { searchBaseView.onSearchFieldTextEnteredCallback = newValue }
    }
    public var onSearchFilterPickedCallback: (Int)->Void {
        get { return searchBaseView.onSearchFilterPickedCallback }
        set { searchBaseView.onSearchFilterPickedCallback = newValue }
    }
    
    public var onQuickPlayerPlaylistButtonClickCallback: ()->Void {
        get { return quickPlayerView.onPlaylistButtonClickCallback }
        set { quickPlayerView.onPlaylistButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerButtonClickCallback: (ApplicationInput)->() {
        get { return quickPlayerView.onPlayerButtonClickCallback }
        set { quickPlayerView.onPlayerButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerPlayOrderButtonClickCallback: ()->Void {
        get { return quickPlayerView.onPlayOrderButtonClickCallback }
        set { quickPlayerView.onPlayOrderButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerSwipeUpCallback: ()->Void {
        get { return quickPlayerView.onSwipeUpCallback }
        set { quickPlayerView.onSwipeUpCallback = newValue }
    }
    
    var searchBaseView: SearchViewPlain!
    
    var quickPlayerView: QuickPlayerView!
    
    private var initialized: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        self.searchBaseView = SearchViewPlain.create(owner: self)
        self.quickPlayerView = QuickPlayerView.create(owner: self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !initialized
        {
            initialized = true
            
            setup()
        }
    }
    
    private func setup() {
        let guide = self
        
        addSubview(searchBaseView)
        addSubview(quickPlayerView)
        
        // Search plain view setup
        searchBaseView.translatesAutoresizingMaskIntoConstraints = false
        searchBaseView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        searchBaseView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        searchBaseView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        searchBaseView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        // Quick player setup
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.2).isActive = true
    }
    
    public func reloadData() {
        searchBaseView.reloadData()
    }
    
    public func setTextFieldText(_ text: String) {
        searchBaseView.setTextFieldText(text)
    }
    
    public func setTextFilterIndex(_ index: Int) {
        searchBaseView.setTextFilterIndex(index)
    }
    
    public func updateSearchResults(resultsCount: UInt, searchTip: String?) {
        searchBaseView.updateSearchResults(resultsCount: resultsCount, searchTip: searchTip)
    }
    
    public func playSelectionAnimation(reloadData: Bool) {
        searchBaseView.playSelectionAnimation(reloadData: reloadData)
    }
}

// QuickPlayerObserver
extension SearchView: QuickPlayerObserver {
    public func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    public func updateMediaInfo(track: BaseAudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
        
        self.searchBaseView.reloadData()
    }
    
    public func updatePlayButtonState(isPlaying: Bool) {
        quickPlayerView.updatePlayButtonState(isPlaying: isPlaying)
    }
    
    public func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        
    }
}

// Builder
extension SearchView {
    class func create(owner: Any) -> SearchView? {
        let bundle = Bundle.main
        let nibName = String(describing: SearchView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? SearchView
    }
}
