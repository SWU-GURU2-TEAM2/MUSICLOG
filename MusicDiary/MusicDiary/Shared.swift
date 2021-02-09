//
//  Shared.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/02/09.
//

import UIKit
import Firebase

func presentDiaryData() { // 다이어리 '한개!!!' 의 다어어리 정보 가져오는거임!!!
    let db = Firestore.firestore()
    var docRef = db.collection("Diary").document("\(currentDairyId)")
    var newDiaryData = DiaryStructure()
    docRef.getDocument { (document, error) in
        if let document = document, document.exists {
            let dataDescription = document.data()
            //newContent.musicCoverUrl = URL(string: (dataDescription!["musicCoverUrl"]! as? String)!)

            newDiaryData.diaryName = dataDescription!["diaryName"] as? String
            newDiaryData.diaryMusicTitle = dataDescription!["diaryMusicTitle"] as? String
            newDiaryData.diaryMusicArtist = dataDescription!["diaryMusicArtist"] as? String
            newDiaryData.diaryImageUrl = URL(string: (dataDescription!["diaryImageUrl"]! as? String)!)
            newDiaryData.memberList = dataDescription!["memberList"] as? [String]

            print("new data: ", newDiaryData)

            // 여기 밑에부터는 데이터 가져와서 어케 띄우고 하는거임 (지금 있는건 이미지뷰 띄우기)
            
            
//            DispatchQueue.global().async { let data = try? Data(contentsOf: newDiaryData.diaryImageUrl!)
//                DispatchQueue.main.async {
//                    self.imageView.image = UIImage(data: data!)
//                    self.titleLabel.text = newDiaryData.diaryMusicTitle!
//                    self.artistLabel.text = newDiaryData.diaryMusicArtist!
//                    self.diaryNameLabel.text = newDiaryData.diaryName!
//                }
//            }
            
            
            
            // 여기까지

        } else {
            print("Document does not exist")
        }
    }
}
