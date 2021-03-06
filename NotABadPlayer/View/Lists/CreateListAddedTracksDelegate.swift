//
//  CreateListAddedTracksDelegate.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 22.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import UIKit

// Table data source
class CreateListAddedTracksTableDataSource : NSObject, BaseCreateListAddedTracksTableDataSource
{
    let audioInfo: AudioInfo
    let tracks: [AudioTrackProtocol]
    
    init(audioInfo: AudioInfo, tracks: [AudioTrackProtocol]) {
        self.audioInfo = audioInfo
        self.tracks = tracks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListAddedTrackCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAddedTrackCell else {
            return reusableCell
        }
        
        let item = tracks[indexPath.row]
        
        cell.coverImage.image = item.albumCoverImage
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = getTrackDescription(track: item)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getTrackDescription(track: AudioTrackProtocol) -> String {
        return track.duration
    }
}

// Table action delegate
class CreateListAddedTracksActionDelegate : NSObject, BaseCreateListAddedTracksActionDelegate
{
    private weak var view: CreateListView?
    
    init(view: CreateListView) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionAddedTrackClick(index: UInt(indexPath.row))
    }
}
