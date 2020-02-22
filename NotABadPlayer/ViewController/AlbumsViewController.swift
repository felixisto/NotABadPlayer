//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class AlbumsViewController: UIViewController, BaseViewDelegate {
    private var baseView: AlbumsView?
    
    private let presenter: BasePresenter?
    
    private var subViewController: PlaylistViewController?
    private var subViewControllerPlaylistName: String = ""
    
    init(presenter: BasePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presenter = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = AlbumsView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
    }
    
    private func setup() {
        // User input
        baseView?.onAlbumClickCallback = { [weak self] (index) in
            self?.presenter?.onAlbumClick(index: index)
        }
        
        baseView?.onQuickPlayerPlaylistButtonClickCallback = { [weak self] () in
            self?.presenter?.onQuickOpenPlaylistButtonClick()
        }
        
        baseView?.onQuickPlayerButtonClickCallback = { [weak self] (input) in
            self?.presenter?.onPlayerButtonClick(input: input)
        }
        
        baseView?.onQuickPlayerPlayOrderButtonClickCallback = { [weak self] () in
            self?.presenter?.onPlayOrderButtonClick()
        }
        
        baseView?.onQuickPlayerSwipeUpCallback = { [weak self] () in
            if let currentlyPlaying = AudioPlayerService.shared.playlist
            {
                self?.presenter?.onOpenPlayer(playlist: currentlyPlaying)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseView?.reloadData()
        
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    func goBack() {
        self.subViewController?.goBack()
        self.subViewController = nil
        self.subViewControllerPlaylistName = ""
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: BaseAudioPlaylist, options: OpenPlaylistOptions) {
        if self.subViewController != nil
        {
            // Correct playlist is already open? Do nothing
            if playlist.name == self.subViewControllerPlaylistName
            {
                Logging.log(AlbumsViewController.self, "No need to open playlist screen, its already open for the correct playlist")
                return
            }
            
            Logging.log(AlbumsViewController.self, "Close current playlist screen, and reopen it for the correct playlist")
            goBack()
        }
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist, options: options)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.setView(vc)
        self.subViewController = vc
        self.subViewControllerPlaylistName = playlist.name
        
        NavigationHelpers.addVCChild(parent: self, child: vc, animation: .scaleUp)
    }
    
    func onMediaAlbumsLoad(dataSource: BaseAlbumsViewDataSource?, albumTitles: [String]) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.updateIndexerAlphabet(albumTitles: albumTitles)
        self.baseView?.reloadData()
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: BasePlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?) {
        
    }
    
    func openPlayerScreen(playlist: BaseAudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.setView(vc)
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func updatePlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: BaseSearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onThemeSelect(_ value: AppThemeValue) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onAudioLibraryChanged() {
        Toast.show(message: Text.value(.AlbumsLibraryChanged), controller: self)
    }
    
    func onFetchDataErrorEncountered(_ error: Error) {
        // Fetch data again until successful
        presenter?.fetchData()
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: "Error",
                                 withDescription: error.localizedDescription,
                                 actionText: "Ok",
                                 action: nil)
    }
}

extension AlbumsViewController : QuickPlayerObserver {
    func updateTime(currentTime: Double, totalDuration: Double) {
        baseView?.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: BaseAudioTrack) {
        baseView?.updateMediaInfo(track: track)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        baseView?.updatePlayButtonState(isPlaying: isPlaying)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        baseView?.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        
    }
}
