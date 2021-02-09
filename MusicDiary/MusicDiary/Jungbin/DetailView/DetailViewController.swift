//
//  DetailViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/02/09.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var writeView: UIView!
    var getMusic:MusicStruct!
    let db = Firestore.firestore()
    //var currentContentData = ContentData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async { let data = try? Data(contentsOf: currentContentData.musicCoverUrl!)
            
            DispatchQueue.main.async {
                self.imageVIew.image = UIImage(data: data!)
                self.titleLabel.text = currentContentData.musicTitle
                self.artistLabel.text = currentContentData.musicArtist
                self.textView!.text = currentContentData.conentText
                
            }
        }
        textView.isEditable = false
        imageVIew.layer.cornerRadius = imageVIew.frame.width / 2
        imageVIew.clipsToBounds = true
        writeView.backgroundColor = UIColor(patternImage: UIImage(named: "Write_underBG")!)
        
    }
    
    @IBAction func tapDeleteBtn(_ sender: Any) {
        // EDIT
        //        let calendar = Calendar.current
        //        var docRef = db.collection("Diary").document("\(currentDairyId)").collection("Contents").document("\(currentContentID)")
        //
        //        docRef.updateData( [
        //            "contentText":"\(textView.text!)",
        //            "musicArtist":"\(artistLabel.text!)",
        //            "musicCoverUrl":String(describing: newCD.musicCoverUrl!),
        //            "musicTitle":"\(titleLabel.text!)"
        //        ]) { err in
        //            if let err = err {
        //                print("Error adding document: \(err)")
        //            } else {
        //                print("Document updated with ID: \(docRef.documentID)")
        //            }
        //        }
        //        self.dismiss(animated: true)
        
    }
    @IBAction func tapVIew(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
