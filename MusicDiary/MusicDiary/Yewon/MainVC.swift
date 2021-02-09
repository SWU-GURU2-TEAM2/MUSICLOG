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
    
    @IBOutlet weak var mainCarousel: ScalingCarouselView!
    let authUI = FUIAuth.defaultAuthUI()
    
    
    @IBAction func moveToWrite(_ sender: UIButton) {
        
        //center Diary 해당 날짜에 콘텐츠 있으면 안보이게
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
                            let dataDescriptions = document.data()
                            let calendar = Calendar.current
                            newDiaryData.diaryName = dataDescriptions!["diaryName"] as? String
                            newDiaryData.diaryMusicTitle = dataDescriptions!["diaryMusicTitle"] as? String
                            newDiaryData.diaryMusicArtist = dataDescriptions!["diaryMusicArtist"] as? String
                            newDiaryData.diaryImageUrl = URL(string: (dataDescriptions!["diaryImageUrl"]! as? String)!)
                            newDiaryData.date = Date(timeIntervalSince1970: TimeInterval((dataDescriptions!["date"] as! Timestamp).seconds))
                            newDiaryData.memberList = dataDescriptions!["memberList"] as? [String]
                            
                            self.diaryData.append(newDiaryData)
                            self.diaryData.sort {$0.date! < $1.date!}   //date에 따라 정렬
                            self.mainCarousel.reloadData()
                        } else {
                            print("Document does not exist")
                            
                        }
                        
                    }
                }
            }
        }
        
    }
    @IBAction func addDiary(_ sender: UIButton) {
        //firebase에 다이어리 증가 + 유저 다이어리 리스트에도 추가 됨
        var ref: DocumentReference? = nil
        let date = Date()
        
        ref = self.db.collection("Diary").addDocument(data: [
            "diaryImageUrl":"https://firebasestorage.googleapis.com/v0/b/musicdiary-a095d.appspot.com/o/defaltDiaryImg.png?alt=media&token=1556a66e-c81f-4aad-ba96-8b25d6ab5dfc",
            "diaryName":"new Diary",
            "diaryMusicTitle":"",
            "diaryMusicArtist":"",
            "memberList":[currentUID],
            "date":date
            ]){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                //Diary 필드에 새 다이어리 documentID 추가 update
                
                self.db.collection("Users").document(currentUID).updateData(["userDiaryList": FieldValue.arrayUnion([ref!.documentID])])
                self.viewDidLoad()
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
        return diaryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let carouselCell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath) as! MainCell
        //let diaryCount = diaryData[indexPath.row]
        //let data0Fdiary = diaryCount.data()
        //diary name insert
        carouselCell.mainDiaryName.text = diaryData[indexPath.row].diaryName
        
        //이미지 넣기, 날짜 넣기
        
        //carouselCell.mainDiaryImaage.image = UIImage(data: try! Data(contentsOf: self.diaryData[indexPath.row].diaryImageUrl!))
//        DispatchQueue.global().async { let data = try? Data(contentsOf: self.diaryData[indexPath.row].diaryImageUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            DispatchQueue.main.async { carouselCell.mainDiaryImaage.image = UIImage(data: data!) }
//            }
        //date insert 0000년 00일 00일 형식으로 지정 필요
       // let starDate = data0Fdiary["date"]
        //image insert
        //print("Image Url : \(data0Fdiary["diaryImageUrl"])")
        //carouselCell.mainStartDate.text = startDate
        carouselCell.setNeedsLayout()
        carouselCell.layoutIfNeeded()
        
        return carouselCell
    }
}

typealias CarouselDelegate = MainVC
extension MainVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let currentCenterIndex = mainCarousel.currentCenterCellIndex?.row else { return }
        print(currentCenterIndex)
        //center Cell 의 documentID 저장해둬야함
        //self.diaryData[currentCenterIndex]
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
