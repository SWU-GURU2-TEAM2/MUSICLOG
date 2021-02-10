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
    @IBOutlet weak var shareMusicView: UIView!
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
    
    @IBAction func tapSharedBtn(_ sender: Any) {
        
        guard let image = shareMusicView.transfromToImage() else {
                    return
                }
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                //vc.excludedActivityTypes = [.saveToCameraRoll] //
                present(vc, animated: true)
        
    }
    @IBAction func tapDeleteBtn(_ sender: Any) {
        
        let alert = UIAlertController(title: "삭제", message: "정말로 삭제하시겠어요? 💁🏻", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "안 할래요 📛", style: .cancel)
        let ok = UIAlertAction(title: "삭제할래요", style: .default) { (_) in
            var docRef = self.db.collection("Diary").document("\(currentDairyId)").collection("Contents").document("\(currentContentID)")
            docRef.delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            self.dismiss(animated: true)
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
        
        
      
        
    }
    @IBAction func tapVIew(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
extension UIView {
    func transfromToImage() -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
            defer {
                UIGraphicsEndImageContext()
            }
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
                return UIGraphicsGetImageFromCurrentImageContext()
            }
            return nil
        }
}
