//
//  PlaylistPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class PlaylistPresenter: BasePresenter
{
    public weak var delegate: PlaylistViewDelegate?
    
    private let audioInfo: AudioInfo
    private let playlist: AudioPlaylist
    
    private var collectionDataSource: PlaylistViewDataSource?
    private var collectionActionDelegate: PlaylistViewActionDelegate?
    
    required init(view: PlaylistViewDelegate?=nil, audioInfo: AudioInfo, playlist: AudioPlaylist) {
        self.delegate = view
        self.audioInfo = audioInfo
        
        // Sort playlist
        // Sort only playlists of type album
        let sorting = GeneralStorage.shared.getTrackSortingValue()
        let sortedPlaylist = playlist.isAlbumPlaylist() ? playlist.sortedPlaylist(withSorting: sorting) : playlist
        self.playlist = sortedPlaylist
    }
    
    func start() {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let dataSource = PlaylistViewDataSource(audioInfo: audioInfo, playlist: playlist)
        self.collectionDataSource = dataSource
        
        let actionDelegate = PlaylistViewActionDelegate(view: delegate)
        self.collectionActionDelegate = actionDelegate
        
        let audioPlayer = AudioPlayer.shared
        var scrollIndex: UInt? = nil
        
        if let playlist = audioPlayer.playlist
        {
            for e in 0..<playlist.tracks.count
            {
                if playlist.tracks[e] == playlist.playingTrack && self.playlist.name == playlist.name
                {
                    scrollIndex = UInt(e)
                    break
                }
            }
        }
        
        if playlist.isAlbumPlaylist()
        {
            delegate.onAlbumSongsLoad(name: playlist.name, dataSource: dataSource, actionDelegate: actionDelegate)
        }
        else
        {
            delegate.onPlaylistSongsLoad(name: playlist.name, dataSource: dataSource, actionDelegate: actionDelegate)
        }
        
        if let scrollToIndex = scrollIndex
        {
            delegate.scrollTo(index: scrollToIndex)
        }
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let playlistName = playlist.name
        
        let clickedTrack = playlist.tracks[Int(index)]
        
        let newPlaylist = AudioPlaylist(name: playlistName, tracks: playlist.tracks, startWithTrack: clickedTrack)
        
        delegate.openPlayerScreen(playlist: newPlaylist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(PlaylistPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        let _ = Keybinds.shared.performAction(action: action)
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(PlaylistPresenter.self, "Change audio player play order")
        
        let _ = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
    }
    
    func onOpenPlaylistButtonClick() {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(searchValue: String) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(themeValue: AppTheme) {
        
    }
    
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting) {
        
    }
    
    func onAppAppearanceChange(showStars: ShowStars, showVolumeBar: ShowVolumeBar) {
        
    }
    
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput) {
        
    }
}
