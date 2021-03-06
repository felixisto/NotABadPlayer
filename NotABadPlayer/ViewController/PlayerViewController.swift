//
//  PlayerViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol PlayerViewControllerProtocol: BaseView {
    func updatePlayerScreen(playlist: AudioPlaylistProtocol)
    
    func onPlayerErrorEncountered(_ error: Error)
}

class PlayerViewController: UIViewController, PlayerViewControllerProtocol {
    // If the user has tapped the lyrics this many times, do not display toasts anymore.
    // They will kinda get the idea about clicking on the cover image to see lyrics.
    public static let MAX_COUNT_LYRICS_TAP_TOAST_DISPLAY = 10
    
    var baseView: PlayerView? {
        return self.view as? PlayerView
    }
    
    private let presenter: PlayerPresenterProtocol?
    
    private var encounteredError: String?
    
    init(presenter: PlayerPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented decode()")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
        
        QuickPlayerService.shared.attach(observer: self)
    }
    
    private func setup() {
        self.baseView?.onCoverImageTapCallback = {[weak self] () in
            guard let strongSelf = self else
            {
                return
            }
            
            if let trackLyrics = strongSelf.presenter?.contextAudioTrackLyrics{
                if !trackLyrics.isEmpty {
                    strongSelf.baseView?.showLyrics(trackLyrics)
                } else {
                    strongSelf.displayNoLyricsToast()
                }
            }
        }
        
        self.baseView?.onLyricsTapCallback = {[weak self] () in
            self?.baseView?.showCoverImage()
        }
        
        self.baseView?.onPlayerSeekCallback = {(percentage) in
            let player = AudioPlayerService.shared
            let duration = player.durationSec
            
            player.seekTo(seconds: duration * percentage)
            
            self.baseView?.updateSoftUIState(player: player)
        }
        
        self.baseView?.onPlayerButtonClickCallback = {[weak self] (input) in
            self?.presenter?.onPlayerButtonClick(input: input)
        }
        
        self.baseView?.onPlayOrderButtonClickCallback = {[weak self] () in
            self?.presenter?.onPlayOrderButtonClick()
        }
        
        self.baseView?.onSwipeDownCallback = {[weak self] () in
            self?.goBack()
        }
        
        self.baseView?.onSideVolumeBarSeekCallback = {[weak self] (percentage) in
            self?.presenter?.onPlayerVolumeSet(value: percentage)
        }
        
        self.baseView?.onFavoritesCallback = {[weak self] () in
            guard let strongSelf = self else
            {
                return
            }
            
            let result = strongSelf.presenter?.onMarkOrUnmarkContextTrackFavorite() ?? false
            
            strongSelf.baseView?.markFavorite(result)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if any errors have been encountered
        if let error = encounteredError
        {
            self.encounteredError = nil
            
            AlertWindows.shared.show(sourceVC: self, withTitle: "Error", withDescription: error, actionText: "Ok", action: {(action: UIAlertAction) in
                self.goBack()
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        QuickPlayerService.shared.detach(observer: self)
    }
    
    // PlayerViewControllerProtocol
    
    func goBack() {
        NavigationHelpers.dismissPresentedVC(self)
    }
    
    func updatePlayerScreen(playlist: AudioPlaylistProtocol) {
        let playingTrack = playlist.playingTrack
        
        self.baseView?.updateUIState(player: AudioPlayerService.shared, track: playingTrack, isFavorite: isStorageMarkedFavorite(playingTrack))
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        self.encounteredError = error.localizedDescription
    }
    
    private func onSystemVolumeChanged(_ value: Double) {
        baseView?.onSystemVolumeChanged(value)
    }
    
    private func displayNoLyricsToast() {
        let count = GeneralStorage.shared.numberOfLyricsTapped()
        
        if count < PlayerViewController.MAX_COUNT_LYRICS_TAP_TOAST_DISPLAY {
            GeneralStorage.shared.incrementNumberOfLyricsTapped()
            
            Toast.show(message: Text.value(.PlayerLyricsNotAvailable), controller: self, duration: 1)
        }
    }
    
    private func isStorageMarkedFavorite(_ track: AudioTrackProtocol) -> Bool {
        return GeneralStorage.shared.favorites.isMarkedFavorite(track)
    }
}

extension PlayerViewController : QuickPlayerObserver {
    func updateTime(currentTime: Double, totalDuration: Double) {
        baseView?.updateSoftUIState(player: AudioPlayerService.shared)
    }
    
    func updateMediaInfo(track: AudioTrackProtocol) {
        let isFavorite = isStorageMarkedFavorite(track)
        self.baseView?.updateUIState(player: AudioPlayerService.shared, track: track, isFavorite: isFavorite)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        self.baseView?.updatePlayButtonState(player: AudioPlayerService.shared)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        self.baseView?.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        self.onSystemVolumeChanged(volume)
    }
}
