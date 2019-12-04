//
//  AudioTrackBuilder.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

enum AudioTrackBuilderError: Error {
    case deserializationFailed(String)
}

class AudioTrackBuilder {
    public static func start() -> BaseAudioTrackBuilderNode {
        return AudioTrackBuilderNode()
    }
    
    public static func start(prototype: AudioTrack) -> BaseAudioTrackBuilderNode {
        return AudioTrackBuilderNode(prototype: prototype)
    }
    
    public static func buildLatestVersionFrom(serializedData :String) throws -> AudioTrack {
        if let result: AudioTrackV1 = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
    
    public static func buildLatestVersionListFrom(serializedData :String) throws -> [AudioTrack] {
        if let result: [AudioTrackV1] = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
}

protocol BaseAudioTrackBuilderNode {
    func build() throws -> AudioTrack
    func reset()
    
    var identifier : Int { get set }
    var filePath : URL? { get set }
    var title : String { get set }
    var artist : String { get set }
    var albumTitle : String { get set }
    var albumID : Int { get set }
    var albumCover : MPMediaItemArtwork? { get set }
    var trackNum : Int { get set }
    var durationInSeconds : Double { get set }
    var source : AudioTrackSource { get set }
    
    var lyrics : String { get set }
    var dateAdded : Date { get set }
    var dateFirstPlayed : Date { get set }
    var dateLastPlayed : Date? { get set }
    var lastPlayedPosition : TimeInterval { get set }
}

class AudioTrackBuilderNode: BaseAudioTrackBuilderNode {
    static let genericOrigin: AudioTrackV1 = AudioTrackV1()
    static let genericDate: AudioTrackDateValue = AudioTrackDateValue()
    
    private var template: AudioTrack
    private var track: AudioTrackV1
    
    private var _dateAdded: AudioTrackDateValue = AudioTrackBuilderNode.genericDate
    private var _dateFirstPlayed: AudioTrackDateValue = AudioTrackBuilderNode.genericDate
    private var _dateLastPlayed: AudioTrackDateValue? = AudioTrackBuilderNode.genericDate
    
    public var identifier : Int {
        get { return track.identifier }
        set { track.identifier = newValue }
    }
    public var filePath : URL? {
        get { return track.filePath }
        set { track.filePath = newValue }
    }
    public var title : String {
        get { return track.title }
        set { track.title = newValue }
    }
    public var artist : String {
        get { return track.artist }
        set { track.artist = newValue }
    }
    public var albumTitle : String {
        get { return track.albumTitle }
        set { track.albumTitle = newValue }
    }
    public var albumID : Int {
        get { return track.albumID }
        set { track.albumID = newValue }
    }
    public var albumCover : MPMediaItemArtwork? {
        get { return track.albumCover }
        set { track.albumCover = newValue }
    }
    public var trackNum : Int {
        get { return track.trackNum }
        set { track.trackNum = newValue }
    }
    public var durationInSeconds : Double {
        get { return track.durationInSeconds }
        set { track.durationInSeconds = newValue }
    }
    public var source : AudioTrackSource {
        get { return track.source }
        set { track.source = newValue }
    }
    public var lyrics : String {
        get { return track.lyrics }
        set { track.lyrics = newValue }
    }
    public var dateAdded : Date {
        get { return _dateAdded.value }
        set { _dateAdded = AudioTrackDateValue(newValue) }
    }
    public var dateFirstPlayed : Date {
        get { return _dateFirstPlayed.value }
        set { _dateFirstPlayed = AudioTrackDateValue(newValue)}
    }
    public var dateLastPlayed : Date? {
        get { return _dateLastPlayed?.value }
        set {
            if let newDate = newValue {
                _dateLastPlayed = AudioTrackDateValue(newDate)
            } else {
                _dateLastPlayed = nil
            }
        }
    }
    public var lastPlayedPosition : TimeInterval {
        get { return track.lastPlayedPosition }
        set { track.lastPlayedPosition = newValue }
    }
    
    init() {
        template = AudioTrackBuilderNode.genericOrigin
        track = AudioTrackBuilderNode.genericOrigin
        reset()
    }
    
    init(prototype: AudioTrack) {
        template = prototype
        track = AudioTrackBuilderNode.genericOrigin
        reset()
    }
    
    func build() throws -> AudioTrack {
        let track = self.track
        self.track = AudioTrackV1()
        self.track.date = AudioTrackDateBuilder.build(_dateAdded, _dateFirstPlayed, _dateLastPlayed)
        return track
    }
    
    func reset() {
        track = AudioTrackV1(template)
        _dateAdded = AudioTrackBuilderNode.genericDate
        _dateFirstPlayed = AudioTrackBuilderNode.genericDate
        _dateLastPlayed = AudioTrackBuilderNode.genericDate
    }
}
