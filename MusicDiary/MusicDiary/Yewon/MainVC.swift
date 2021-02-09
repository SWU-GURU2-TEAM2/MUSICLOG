//
//  MainView.swift
//  MusicDiary
//
//  Created by 강예원 on 2021/01/28.
//

import UIKit
import WebKit
import ScalingCarousel
import FirebaseFirestore
import FirebaseAuth
import FirebaseUI

//center에 있는 docID 전달 변수 (수정 예정)
var centerDocID = "IxLlj4mK2DKPIoBA9Qjp"

class MainVC:UIViewController {
    let db = Firestore.firestore()
    var diaryData: [DiaryStructure] = []
    var getDiaryList = [String]()
    var myDiaryID = [QueryDocumentSnapshot]()
    @IBOutlet weak var mainCarousel: ScalingCarouselView!
    let authUI = FUIAuth.defaultAuthUI()
    @IBAction func moveToWrite(_ sender: UIButton) {
        
    }
    @IBAction func moveToSetting(_ sender: UIButton) {
        let vc = UIStoryboard(name: "YujinStoryboard", bundle: nil).instantiateViewController(identifier: "appSettingView")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:  nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Users에서 diaryList 필드 읽어오기
        db.collection("Users").document("h1jETajvj6NiFtA9qSE1VRjQ7AP2").getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.getDiaryList = (dataDescription!["userDiaryList"] as? [String])!
                print("diary list : ", self.getDiaryList)
                
                
                
                //Diary에서
                for currentDId in self.getDiaryList {
                    let docRef = self.db.collection("Diary").document("\(currentDId)")
                    var newDiaryData = DiaryStructure()
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data()
                            //newContent.musicCoverUrl = URL(string: (dataDescription!["musicCoverUrl"]! as? String)!)
                            
                            newDiaryData.diaryName = dataDescription!["diaryName"] as? String
                            newDiaryData.diaryMusicTitle = dataDescription!["diaryMusicTitle"] as? String
                            newDiaryData.diaryMusicArtist = dataDescription!["diaryMusicArtist"] as? String
                            newDiaryData.diaryImageUrl = URL(string: (dataDescription!["diaryImageUrl"]! as? String)!)
                            //newDiaryData.memberList = dataDescription!["memberList"] as? [String]
                            
                            print("new data: ", newDiaryData)
                            self.diaryData.append(newDiaryData)
                            
                        } else {
                            print("Document does not exist")
                            
                        }
                        
                    }
                }
                self.mainCarousel.reloadData()
            }
        }
        
        
        
        
        
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainCarousel.deviceRotated()
    }
}

class MainCell: ScalingCarouselCell {
    @IBOutlet weak var mainDiaryImaage: UIImageView!
    @IBOutlet weak var mainDiaryName: UILabel!
    @IBOutlet weak var mainStartDate: UILabel!
}

typealias CarouselDatasource = MainVC
extension CarouselDatasource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getDiaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let carouselCell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath) as! MainCell
        //        let diaryCount = diaryData[indexPath.row]
        //        let data0Fdiary = diaryCount.data()
        //        //diary name insert
        //        carouselCell.mainDiaryName.text = data0Fdiary["diaryName"] as! String
        //        //date insert 0000년 00일 00일 형식으로 지정 필요
        //        let starDate = data0Fdiary["date"]
        //        //image insert
        //        //print("Image Url : \(data0Fdiary["diaryImageUrl"])")
        //        //carouselCell.mainStartDate.text = startDate
        carouselCell.setNeedsLayout()
        carouselCell.layoutIfNeeded()
        
        return carouselCell
    }
}

typealias CarouselDelegate = MainVC
extension MainVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

private typealias ScalingCarouselFlowDelegate = MainVC
extension ScalingCarouselFlowDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
