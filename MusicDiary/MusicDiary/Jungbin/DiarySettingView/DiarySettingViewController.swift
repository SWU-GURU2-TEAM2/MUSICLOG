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

    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func tapView(_ sender: Any) {
        // 저 장 후!!!!
        self.dismiss(animated: true)
    }
    @IBAction func tapAddUserBtn(_ sender: Any) {
    }
//    func presentData() {
//        var docRef = db.collection("Diary").document("\(currentDairyId)")
//        var newD =
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data()
//                newContent.musicCoverUrl = URL(string: (dataDescription!["musicCoverUrl"]! as? String)!)
//
//                newCD.authorID = dataDescription!["authorID"] as? String
//                newCD.conentText = dataDescription!["contentText"] as? String
//                newCD.musicTitle = dataDescription!["musicTitle"] as? String
//                newCD.musicArtist = dataDescription!["musicArtist"] as? String
//                newCD.musicCoverUrl = URL(string: (dataDescription!["musicCoverUrl"]! as? String)!)
//                newCD.date = dataDescription!["date"] as? Date
//                self.titleLabel.text = newCD.musicTitle
//                self.artistLabel.text = newCD.musicArtist
//                self.textView!.text = newCD.conentText
//
//                //print("Document data: ", newURL)
//
//                DispatchQueue.global().async { let data = try? Data(contentsOf: newCD.musicCoverUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//                    DispatchQueue.main.async { self.imageVIew.image = UIImage(data: data!) }
//                }
//
//            } else {
//                print("Document does not exist")
//            }
//        }
//
//
//    }
}
