//
//  UserStructure.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/01/31.
//

import UIKit

public struct UserStructure {
    var userName: String?
    var userId: String?
    var userImage: URL?
    var userDiaryList: [String]?
}

struct DiaryStructure {
    var diaryId: String?
    var contentList = [ContentData]()
    var diaryName: String?
    var diaryImageUrl: URL?
    var diaryMusicTitle:String?
    var diaryMusicArtist: String?
    var memberList: [String]?
    var date: Date?
    
}

struct ContentData {
    var authorID: String?
    var conentText: String?
    var musicTitle: String?
    var musicArtist: String?
    var musicCoverUrl: URL?
    var date: Date?
    
}

struct MusicStruct {
    var musicTitle: String?
    var musicArtist: String?
    var musicCoverUrl: URL?
    var musicLyrics: String?
    var musicID: Int?
}
