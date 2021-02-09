//
//  DiarySettingViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/02/07.
//

import UIKit
import Firebase

class DiarySettingViewController: UIViewController {
    let db = Firestore.firestore()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var diaryNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        presentDiaryDataForSetting()
    }
    
    @IBAction func goSearchBtn(_ sender: Any) {
        
    }
    @IBAction func editDairyName(_ sender: Any) {
    }
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func tapAddUserBtn(_ sender: Any) {
    }
    func presentDiaryDataForSetting() { // 다이어리 '한개!!!' 의 다어어리 정보 가져오는거임!!!
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

                // 여기 밑에부터는 데이터 가져와서 어케 띄우고 하는거임
                DispatchQueue.global().async { let data = try? Data(contentsOf: newDiaryData.diaryImageUrl!)
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data!)
                        self.titleLabel.text = newDiaryData.diaryMusicTitle!
                        self.artistLabel.text = newDiaryData.diaryMusicArtist!
                        self.diaryNameLabel.text = newDiaryData.diaryName!
                    }
                }
                // 여기까지

            } else {
                print("Document does not exist")
            }
        }
    }
}
