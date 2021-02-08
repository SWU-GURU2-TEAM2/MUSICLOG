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
    var diaryData = [QueryDocumentSnapshot]()
    var getDiaryList = [String]()
    var diaryID = [String]()
    @IBOutlet weak var mainCarousel: ScalingCarouselView!
    let authUI = FUIAuth.defaultAuthUI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.diaryData = [QueryDocumentSnapshot]()
        self.getDiaryList = [String]()
        
        //Users>diaryList
        db.collection("Users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let snapshot = snapshot {
                for getDoc in snapshot.documents {
                    //print("\(getDoc.documentID) => \(getDoc.data()["userDiaryList"])")
                    self.getDiaryList = getDoc.data()["userDiaryList"] as! [String]
                }
                self.mainCarousel.reloadData()
            }
        }
        //getDiaryList
        db.collection("Users").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let snapshot = snapshot {
                for change in snapshot.documentChanges {
                    print("getDiary\(change.document.data())")
                }
            }
            
        }
        
        //Diary>data
        db.collection("Diary").order(by: "date").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.diaryData.append(document)
                }
                self.mainCarousel.reloadData()
            }
        }
        //diaryData change listener
        db.collection("Diary").order(by: "date").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let snapshot = snapshot {
                for change in snapshot.documentChanges {
                    //print(change.document.data())
                    let docID = change.document.documentID
                    let document = change.document
                    
                    if self.newDiary(document) {
                        self.diaryData.append(document)
                        self.diaryID.append(docID)
                        print("add diary")
                        //self.mainCarousel.reloadItems(at: [IndexPath(item: self.getDiaryList.count-1, section: 0)])
                    }
                }
            }
        }
    }
    
    func newDiary(_ diary_doc:QueryDocumentSnapshot) -> Bool {
        for diary_data in diaryData {
            if diary_data.documentID == diary_doc.documentID {
                return false
            }
        }
        return true
    }
        
    
    @IBAction func addDiary(_ sender: UIButton) {

        //firebase에 다이어리 증가 + 유저 다이어리 리스트에도 추가 됨
        var ref: DocumentReference? = nil
        let date = Date()

        ref = db.collection("Diary").addDocument(data: [
            "diaryImageUrl":"",
            "diaryName":"oppa",
            "diaryMusicTitle":"",
            "diaryMusicArtist":"",
            "memberList":[],
            "date":date
            //memberList에 currentUserId 들거갈 것 예상
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        //diary추가하고 읽어와서 반영...
        db.collection("Users").document("TNrcZtxj42Mfqq2KRy1A").updateData([
            "userDiaryList": FieldValue.arrayUnion([ref!.documentID])
        ])
        self.name()
    }
    func name() {
        print("ggg:")
        db.collection("Users").getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
                return
            }
            if let snapshot = snapshot {
                for getDoc in snapshot.documents {
                    print("\(getDoc.documentID) => \(getDoc.data()["userDiaryList"])")
                    self.getDiaryList = getDoc.data()["userDiaryList"] as! [String]
                }
            }
        }
    }
    
    @IBAction func moveToWrite(_ sender: UIButton) {
//        guard let mainCurrentCenterIndex = mainCarousel.currentCenterCellIndex?.row
//        else {
//            return
//        }
//        centerDocID = diaryID[mainCurrentCenterIndex]
//        print(centerDocID)
//        let vc = UIStoryboard(name: "JungbinStoryboard", bundle: nil).instantiateViewController(identifier: "appSettingView")
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true, completion:  nil)
    }
    
    @IBAction func moveToSetting(_ sender: UIButton) {
        let vc = UIStoryboard(name: "YujinStoryboard", bundle: nil).instantiateViewController(identifier: "appSettingView")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:  nil)
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
        let diaryCount = diaryData[indexPath.row]
        let data0Fdiary = diaryCount.data()
        //diary name insert
        carouselCell.mainDiaryName.text = data0Fdiary["diaryName"] as! String
        //date insert 0000년 00일 00일 형식으로 지정 필요
        let starDate = data0Fdiary["date"]
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

