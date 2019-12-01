//
//  AudioInfo.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol AudioInfo {
    func loadIfNecessary()
    func load()
    
    func getAlbums() -> [AudioAlbum];
    func getAlbum(byID identifier: Int) -> AudioAlbum?
    func getAlbumTracks(album: AudioAlbum) -> [AudioTrack]
    func searchForTracks(query: String) -> [AudioTrack]
}
