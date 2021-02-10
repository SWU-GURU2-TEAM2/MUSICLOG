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

//centerCell docID 전달 변수
var centerDocID:String!

class MainVC:UIViewController {
    let db = Firestore.firestore()
    var diaryData: [DiaryStructure] = []
    var getDiaryList = [String]()
    var content_date:Date?
    
    //MARK: -IBDulet
    
    @IBOutlet weak var mainCarousel: ScalingCarouselView!
    @IBOutlet weak var writeBtn: UIButton!
    @IBAction func moveToWrite(_ sender: UIButton) {
        
        //center Diary 해당 날짜에 콘텐츠 있으면 안보이게
        
        
    }
    @IBAction func moveToSetting(_ sender: UIButton) {
        let vc = UIStoryboard(name: "YujinStoryboard", bundle: nil).instantiateViewController(identifier: "appSettingView")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:  nil)
        
    }
    //MARK: -viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.diaryData = []
        
        //Users에서 diaryList 필드 읽어오기
        db.collection("Users").document(currentUID).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.getDiaryList = (dataDescription!["userDiaryList"] as? [String])!
                print("diary list : ", self.getDiaryList)
                //Diary에서 getDiaryList랑 맞는 거 읽어오기
                for currentDId in self.getDiaryList {
                    let docRef = self.db.collection("Diary").document("\(currentDId)")
                    var newDiaryData = DiaryStructure()
                    docRef.getDocument { [self] (document, error) in
                        if let document = document, document.exists {
                            let dataDescriptions = document.data()
                            newDiaryData.diaryId = dataDescriptions!["diaryID"] as? String
                            newDiaryData.diaryName = dataDescriptions!["diaryName"] as? String
                            newDiaryData.diaryMusicTitle = dataDescriptions!["diaryMusicTitle"] as? String
                            newDiaryData.diaryMusicArtist = dataDescriptions!["diaryMusicArtist"] as? String
                            newDiaryData.diaryImageUrl = URL(string: (dataDescriptions!["diaryImageUrl"]! as? String)!)
                            newDiaryData.date = Date(timeIntervalSince1970: TimeInterval((dataDescriptions!["date"] as! Timestamp).seconds))
                            newDiaryData.memberList = dataDescriptions!["memberList"] as? [String]
                            
                            self.diaryData.append(newDiaryData)
                            //print("URL : ", URL(string: ((dataDescriptions!["diaryImageUrl"] as? String)!)))
                            self.diaryData.sort {$0.date! < $1.date!}   //date에 따라 정렬
                            print(diaryData)
                        } else {
                            print("Document does not exist")
                            
                        }
                        self.mainCarousel.reloadData()
                        
                    }
                }
            }
        }
        //test 중
        let testRef = db.collection("Diary").document("hPP6YvFvsilOPYoAlmJs").collection("Contents").document("2EfFkE8a1AfBE1iC2fdB")
        testRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.content_date = Date(timeIntervalSince1970: TimeInterval((dataDescription!["date"] as! Timestamp).seconds))
            } else {
                print("Document does not exist")
            }
        }
        
        //        //오늘 작성한 글이 있다면 writeBtn 안 보이게
        //        let today = dateFormater.string(from: Date())
        //        //if today == content_date {writeBtn.alpha = 0}
        
    }
    
    //MARK: -ADD Diary
    
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
            "date":date,
            "diaryID":""
        ]){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                //Diary 필드에 새 다이어리 documentID update
                self.db.collection("Diary").document(ref!.documentID).updateData(["diaryID":ref!.documentID])
                //Users diaryList update
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


func dateFormat(date:Date) -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy년 MM월 dd일"
    let result = dateFormater.string(from: date)
    return result
}

// MARK: -MainCell

class MainCell: ScalingCarouselCell {
    @IBOutlet weak var mainDiaryImaage: UIImageView!
    @IBOutlet weak var mainDiaryName: UILabel!
    @IBOutlet weak var mainStartDate: UILabel!
    @IBOutlet weak var mainMemberInfo: UIImageView!
}

typealias CarouselDatasource = MainVC
extension CarouselDatasource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let carouselCell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath) as! MainCell
        carouselCell.mainDiaryName.text = diaryData[indexPath.row].diaryName
        
        let start_date = dateFormat(date: self.diaryData[indexPath.row].date!)
        carouselCell.mainStartDate.text = start_date
        //이미지 넣기
        carouselCell.mainDiaryImaage.layer.cornerRadius = carouselCell.mainDiaryImaage.frame.width / 2
        carouselCell.mainDiaryImaage.clipsToBounds = true
        carouselCell.mainDiaryImaage.image = UIImage(data: try! Data(contentsOf: self.diaryData[indexPath.row].diaryImageUrl!))
        DispatchQueue.global().async { let data = try? Data(contentsOf: self.diaryData[indexPath.row].diaryImageUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async { carouselCell.mainDiaryImaage.image = UIImage(data: data!) }
        }
        
        //Share? Single?
        let memberList = diaryData[indexPath.row].memberList!.count
        //        if memberList >= 2 {
        //            carouselCell.mainMemberInfo.setImage(UIImage(named: "ShareDiary.png")!)
        //        } else {
        //            carouselCell.mainMemberInfo.setImage(UIImage(named: "SingleDiary.png")!)
        //        }
        
        carouselCell.setNeedsLayout()
        carouselCell.layoutIfNeeded()
        
        return carouselCell
    }
}

typealias CarouselDelegate = MainVC
extension MainVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let currentCenterIndex = mainCarousel.currentCenterCellIndex?.row else { return }
        //center Cell 의 documentID 저장
        centerDocID = self.getDiaryList[currentCenterIndex]
        //조금이라도 움직여야만 centerDocID 출력 가능...
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
