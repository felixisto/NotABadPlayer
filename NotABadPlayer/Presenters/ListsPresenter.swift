//
//  ListsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol ListsPresenterProtocol: BasePresenter {
    var delegate: ListsViewControllerProtocol? { get }
    
    func fetchData()
    
    func onOpenPlayer(playlist: AudioPlaylistProtocol)
    
    func onPlaylistItemClick(index: UInt)
    func onPlaylistItemEdit(index: UInt)
    func onPlaylistItemDelete(index: UInt)
    
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    func onQuickOpenPlaylistButtonClick()
}

enum ListsPresenterError: Error {
    case failedToBuildMutableList(String)
}

class ListsPresenter: ListsPresenterProtocol {
    weak var delegate: ListsViewControllerProtocol?
    
    private let audioInfo: AudioInfo
    
    private var playlists: [AudioPlaylistProtocol] = []
    
    private var collectionDataSource: BaseListsViewDataSource?
    
    private var fetchOnlyOnce: Counter = Counter(identifier: String(describing: ListsPresenter.self))
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    // ListsPresenterProtocol
    
    func start() {
        fetchData()
    }
    
    func fetchData() {
        // Prevent simultaneous fetch actions
        if !fetchOnlyOnce.isZero() {
            return
        }
        
        let _ = fetchOnlyOnce.increment()
        
        Logging.log(ListsPresenter.self, "Retrieving user playlists...")
        
        // Perform work on background thread
        DispatchQueue.global().async {
            var playlists = GeneralStorage.shared.getUserPlaylists()
            
            let playlistsCount = playlists.count
            
            let recentlyAddedTracks = self.audioInfo.recentlyAddedTracks()
            
            if recentlyAddedTracks.count > 0
            {
                var node = AudioPlaylistBuilder.start()
                node.name = Text.value(.PlaylistRecentlyAdded)
                node.tracks = recentlyAddedTracks
                node.isTemporary = true
                
                do {
                    playlists.insert(try node.buildMutable(), at: 0)
                } catch {
                    
                }
            }
            
            let recentlyPlayedTracks = AudioPlayerService.shared.playerHistory.playHistory
            
            if recentlyPlayedTracks.count > 0
            {
                var node = AudioPlaylistBuilder.start()
                node.name = Text.value(.PlaylistRecentlyPlayed)
                node.tracks = recentlyPlayedTracks
                node.isTemporary = true
                
                do {
                    playlists.insert(try node.buildMutable(), at: 0)
                } catch {
                    
                }
            }
            
            let favoriteTracks = self.audioInfo.favoriteTracks()
            
            if favoriteTracks.count > 0
            {
                var node = AudioPlaylistBuilder.start()
                node.name = Text.value(.PlaylistFavorites)
                node.tracks = favoriteTracks
                node.isTemporary = true
                
                do {
                    playlists.insert(try node.buildMutable(), at: 0)
                } catch {
                    
                }
            }
            
            // Then, update on main thread
            DispatchQueue.main.async {
                Logging.log(ListsPresenter.self, "Retrieved \(playlistsCount) user playlists, updating view")
                
                self.playlists = playlists
                self.collectionDataSource = ListsViewDataSource(audioInfo: self.audioInfo, playlists: self.playlists)
                
                self.delegate?.onUserPlaylistsLoad(audioInfo: self.audioInfo, dataSource: self.collectionDataSource)
                
                let _ = self.fetchOnlyOnce.decrement()
            }
        }
    }
    
    func onOpenPlayer(playlist: AudioPlaylistProtocol) {
        Logging.log(ListsPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(ListsPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        if let error = Keybinds.shared.performAction(action: action)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(ListsPresenter.self, "Change audio player play order")
        
        if let error = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onQuickOpenPlaylistButtonClick() {
        if let playlist = AudioPlayerService.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist, options: OpenPlaylistOptions.buildDefault())
        }
    }
    
    func onPlaylistItemClick(index: UInt) {
        if index >= self.playlists.count
        {
            return
        }
        
        let playlist = self.playlists[Int(index)]
        
        Logging.log(ListsPresenter.self, "Open playlist screen for playlist \(playlist.name)")
        
        let appropriateOptions = getAppropriateOptions(for: playlist)
        
        self.delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist, options: appropriateOptions)
    }
    
    func onPlaylistItemEdit(index: UInt) {
        if index >= self.playlists.count
        {
            return
        }
        
        if !canEditPlaylist(at: index)
        {
            return
        }
        
        let playlistToEdit = self.playlists[Int(index)]
        
        Logging.log(ListsPresenter.self, "Edit user playlist '\(playlistToEdit.name)'")
        
        self.delegate?.openCreateListsScreen(with: playlistToEdit)
    }
    
    func onPlaylistItemDelete(index: UInt) {
        if index >= self.playlists.count
        {
            return
        }
        
        if !canEditPlaylist(at: index)
        {
            return
        }
        
        let playlistToDelete = self.playlists[Int(index)]
        
        self.playlists.remove(at: Int(index))
        
        // Save
        do {
            let playlistsToSave = try buildMutablePlaylistsFromCurrentData(ignoreTemporary: true)
            GeneralStorage.shared.saveUserPlaylists(playlistsToSave)
        } catch {
            Logging.log(ListsPresenter.self, "Failed to delete user playlist '\(playlistToDelete.name)' from storage, unknown error")
            return
        }
        
        Logging.log(ListsPresenter.self, "Deleted user playlist '\(playlistToDelete.name)' from storage")
        
        // Update data source
        updateDataSource()
    }
    
    private func updateDataSource() {
        self.collectionDataSource = ListsViewDataSource(audioInfo: audioInfo, playlists: playlists)
        
        delegate?.onUserPlaylistsLoad(audioInfo: audioInfo, dataSource: collectionDataSource)
    }
    
    private func canEditPlaylist(at index: UInt) -> Bool {
        // Do not edit temporary playlists, as they are automatically generated
        return !self.playlists[Int(index)].isTemporary
    }
    
    private func buildMutablePlaylistsFromCurrentData(ignoreTemporary: Bool) throws -> [MutableAudioPlaylist] {
        // Do not save temporary playlists, as they are recently played/added playlists
        var playlists: [MutableAudioPlaylist] = []
        
        for playlist in self.playlists
        {
            if !ignoreTemporary || !playlist.isTemporary
            {
                do {
                    let node = AudioPlaylistBuilder.start(prototype: playlist)
                    playlists.append(try node.buildMutable())
                } catch {
                    throw ListsPresenterError.failedToBuildMutableList("Failed to build")
                }
            }
        }
        
        return playlists
    }
    
    private func getAppropriateOptions(for playlist: AudioPlaylistProtocol) -> OpenPlaylistOptions {
        if !playlist.isTemporary {
            return OpenPlaylistOptions.buildDefault()
        }
        
        if playlist.name == Text.value(.PlaylistFavorites) {
            return OpenPlaylistOptions.buildFavorites()
        }
        
        if playlist.name == Text.value(.PlaylistRecentlyAdded) {
            return OpenPlaylistOptions.buildRecentlyAdded()
        }
        
        if playlist.name == Text.value(.PlaylistRecentlyPlayed) {
            return OpenPlaylistOptions.buildRecentlyPlayed()
        }
        
        return OpenPlaylistOptions.buildDefault()
    }
}
