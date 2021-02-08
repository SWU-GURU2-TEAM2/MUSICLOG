//
//  SearchViewController.swift
//  MusicDiary
//
//  Created by 강유진 on 2021/02/01.
//

import UIKit
import Alamofire
import SwiftyXMLParser
protocol SendDataDelegate {
    func sendData(data: MusicStruct)
}
//SearchViewController
class SearchViewController: UIViewController {
    //values
    @IBOutlet weak var tableView: UITableView! //tableView
    @IBOutlet weak var searchTextField: UITextField! //searchTextField
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! //loadingIndicator
    var musicData = [MusicStruct]() //musicData
    var searchKeyword: String = "" //searchKeyword
    var selectedMusicData:MusicStruct = MusicStruct() //selectedMusicData
    var delegate: SendDataDelegate! //delegate
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.hidesWhenStopped = true
    }//viewDidLoad
    
    //searchButtonPressed
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        //indicator animating
        self.loadingIndicator.startAnimating()
        //검색결과 초기화
        musicData.removeAll()
        tableView.reloadData()
        //텍스트필드의 값 확인
        searchKeyword = searchTextField.text ?? ""
        if searchKeyword != "" {
            searchKeyword = searchKeyword.replacingOccurrences(of: " ", with: "%20")
            let urlString = "http://www.maniadb.com/api/search/\(searchKeyword)/?sr=song&display=100&key=jgkyj@naver.com&v=0.5"
            let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let convertedUrl = URL(string: encodedString)!
            //Alamofire로 필요한 정보 가져오기
            print("start Alamofire")
            AF.request(convertedUrl, encoding: URLEncoding.httpBody, headers: nil).responseData { [self] (response) in
                print("response SONG")
                //song 검색결과에서 데이터 저장
                if let data = response.data {
                    let xml = XML.parse(data)
                    print("songDataLoaded")
                    //전체 검색 결과가 0개면 출력 안함.
                    //현재 한국어 검색 X, 띄어쓰기 포함하면 X
                    if let totalResult = Int(xml["rss", "channel", "total"].text!), totalResult  != 0{
                        for index in 0...totalResult - 1 {
                            let musicID = xml["rss", "channel", "item", index].attributes["id"]
                            let musicName = xml["rss", "channel", "item", index, "title"].text
                            let artist = xml["rss", "channel", "item", index, "maniadb:artist", "name"].text
                            let id = Int(musicID!)
                            //musicCover가 있으면 넣고 아니면 없게
                            if let musicCover = xml["rss", "channel", "item", index, "maniadb:album", "image"].text{
                                let url = URL(string: musicCover)
                                musicData.append(MusicStruct(musicTitle: musicName!, musicArtist: artist!, musicCoverUrl: url, musicLyrics: nil, musicID: id!))
                            } else {
                                musicData.append(MusicStruct(musicTitle: musicName!, musicArtist: artist!, musicCoverUrl: nil, musicLyrics: nil, musicID: id!))
                            }
                            //print(musicData[index].musicID)
                            let indexPath = IndexPath(item: index, section: 0)
                            tableView.performBatchUpdates({
                                self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
                                tableView.insertRows(at: [indexPath], with: .none)
                            }, completion: nil)
                        }//for
                    } else {
                        musicData.append(MusicStruct(musicTitle: "검색 결과가 없습니다.", musicArtist: "", musicCoverUrl: nil, musicLyrics: nil, musicID: nil))
                        tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .none)
                    }//totalResult
                    //tableView.reloadData()
                }//data
                self.loadingIndicator.stopAnimating()
            }//AF.request
            
        }
    }//searchButtonPressed
    
}//SearchViewController

//extension SearchViewController (TableView_DataSource)
extension SearchViewController: UITableViewDataSource {
    //numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicData.count
    }//numberOfRowsInSection
    
    //cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //스토리보드의 셀을 형식으로, MusicData의 정보로 셀을 구성. (제목, 제작자, 앨범아트)
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as! SearchResultCell
        if musicData.count == 0 {
            return cell
        }
        cell.musicTitle.text = musicData[indexPath.row].musicTitle
        cell.musicArtist.text = musicData[indexPath.row].musicArtist
        if let url = musicData[indexPath.row].musicCoverUrl {
            do {
                let data = try Data(contentsOf: url)
                cell.musicCover.image = UIImage(data: data)
            } catch {
            }
        }
        return cell
        
    }//cellForRowAt
    
}//searchViewController

//extension SearchViewController (TableView_Delegate)
extension SearchViewController: UITableViewDelegate{
    //tableView_heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //세로모드, 가로 모드에 따라 한 번에 보여줄 테이블 셀 갯수 조절
        let size = tableView.frame.size
        if size.height > size.width {
            return size.height / 10
        } else {
            return size.height / 5
        }
    }//heightForRowAt
    
    //tableView_didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = musicData[indexPath.row]
        selectedMusicData.musicTitle = data.musicTitle
        selectedMusicData.musicArtist = data.musicArtist
        selectedMusicData.musicCoverUrl = data.musicCoverUrl
        delegate?.sendData(data: selectedMusicData)
        self.dismiss(animated: true, completion: nil)
        
//        print(selectedMusicData.musicTitle)
//        print(selectedMusicData.musicArtist)
//        print(selectedMusicData.musicCoverUrl)
    }//didSelectRowAt
}//SearchViewController
