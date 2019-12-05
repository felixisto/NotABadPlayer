//
//  AudioPlaylistV1.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AudioPlaylistV1 : MutableAudioPlaylist {
    convenience init(_ prototype: MutableAudioPlaylist) throws {
        try self.init(name: prototype.name, tracks: prototype.tracks, startWithTrackIndex: prototype.playingTrackPosition)
        isTemporary = prototype.isTemporary
    }
    
    override init(name: String, tracks: [AudioTrack]) {
        super.init(name: name, tracks: tracks)
    }
    
    convenience init(name: String, startWithTrack: AudioTrack) {
        self.init(name: name, tracks: [startWithTrack])
        
        self.goToTrack(startWithTrack)
    }
    
    convenience init(name: String, tracks: [AudioTrack], startWithTrack: AudioTrack?) throws {
        try self.init(name: name, tracks: tracks, startWithTrack: startWithTrack, sorting: .NONE)
    }
    
    convenience init(name: String, tracks: [AudioTrack], startWithTrackIndex: Int) throws {
        if startWithTrackIndex < 0 || startWithTrackIndex >= tracks.count
        {
            throw AudioPlaylistError.invalidArgument("Playlist cannot start with given track, given index is invalid")
        }
        
        try self.init(name: name, tracks: tracks, startWithTrack: tracks[startWithTrackIndex], sorting: .NONE)
    }
    
    convenience init(name: String, tracks: [AudioTrack], sorting: TrackSorting) {
        self.init(name: name, tracks: MediaSorting.sortTracks(tracks, sorting: sorting))
    }
    
    convenience init(name: String, tracks: [AudioTrack], startWithTrack: AudioTrack?, sorting: TrackSorting) throws {
        self.init(name: name, tracks: MediaSorting.sortTracks(tracks, sorting: sorting))
        
        if let startingTrack = startWithTrack
        {
            if self.hasTrack(startingTrack)
            {
                self.goToTrack(startingTrack)
            }
            else
            {
                throw AudioPlaylistError.invalidArgument("Playlist cannot start with given track, was not found in the given tracks")
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    static func == (lhs: AudioPlaylistV1, rhs: AudioPlaylistV1) -> Bool {
        return lhs.name == rhs.name && lhs.playingTrackPosition == rhs.playingTrackPosition && lhs.tracks == rhs.tracks
    }
    
    override func equals(_ other: BaseAudioPlaylist) -> Bool {
        if let other_ = other as? AudioPlaylistV1 {
            return self == other_
        }
        
        return false
    }
}
