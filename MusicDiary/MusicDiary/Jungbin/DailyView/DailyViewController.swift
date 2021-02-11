//
//  DailyViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/01/31.
//

import UIKit
import FSCalendar
import Firebase

var currentDairyId = "hPP6YvFvsilOPYoAlmJs"
var currentDairyUserList:[String]!
var currentContentData = ContentData()
var currentContentID:String?
var currentOtehrUserID = currentUID

class DailyViewController: UIViewController, FSCalendarDelegate {
    var datesWithEvent = [Date(), Date()-86400]
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var goDetailBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    let db = Firestore.firestore()
    var newMemberList: [UserStructure] = []
    var newMemberIDList: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        noDataLabel.alpha = 0
        titleLabel.numberOfLines = 6
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.alpha = 0
        goDetailBtn.alpha = 0
        calendar.delegate = self
        //calendar.appearance.backgroundColors =
        // 유저 목록 불러오기
        presentUserList()
        getContentsListForDaily(date: Date())
        
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleWeekendColor = .black
        // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .black
        // 달력의 요일 글자 색깔
        calendar.appearance.weekdayTextColor = .black
        //년 월 custom
        calendar.appearance.headerDateFormat = "MMM"
        calendar.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0)
        
    }
    
    @IBAction func goMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func goDetail(_ sender: Any) {
        print("go detail")
        
        
    }
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        return UIImage(contentsOfFile: "Daily_calendarHeader")
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.datesWithEvent.contains(date) {
            calendar.reloadData()
            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
        }
        calendar.reloadData()
        
        return [appearance.eventDefaultColor]
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 아래 그날의 글들 보여주기
        noDataLabel.alpha = 0
        print("selected date: ", date)
        self.getContentsListForDaily(date: date)
        
        
    }
    
}


extension DailyViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.newMemberList.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentOtehrUserID = newMemberList[indexPath.row].userId!
        print("select id: ", currentOtehrUserID)
        
        self.calendar.reloadData()
        getContentsListForDaily(date: Date())
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! UserCollectionViewCell
        cell.imageView.layer.cornerRadius = cell.imageView.frame.width / 2
        cell.imageView.clipsToBounds = true
        
        DispatchQueue.global().async { let data = try? Data(contentsOf: self.newMemberList[indexPath.row].userImage!)
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data!)
            }
        }
        
        
        return cell
        
        
    }    
    //상하 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //좌우 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
