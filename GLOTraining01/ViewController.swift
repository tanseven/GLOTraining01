//
//  ViewController.swift
//  GLOTraining01
//
//  Created by Tanapong Borrirakwisitsak on 27/9/2562 BE.
//  Copyright © 2562 ClickNext. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import IHProgressHUD

class ViewController: UIViewController {
	
	@IBOutlet weak var scanButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	
	let sessionManager = SessionManager.default
	var dataJSON : JSON = JSON.null

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		self.setupUI()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.tableView.reloadData()
	}
	
	func setupUI() {
		
		self.sessionManager.session.configuration.timeoutIntervalForRequest = 60
		self.sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
			var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
			var credential: URLCredential?
			
			credential = self.sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
			if credential != nil {
				disposition = .cancelAuthenticationChallenge
			}
			return (disposition, credential)
		}
		
		self.tableView.tableFooterView = UIView()
		
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		self.loadLottery()
		
	}
	
	func loadLottery() {
		
		let urlString = "https://hq-api-dev-01.glo.or.th/lotterycheck/sheets/get"
		
		let parameters : [String:Any] = [
			"date" : "01"
			, "month" : "09"
			, "year" : "2019"
		]
		
		let headers : HTTPHeaders = [
			"requestId" : UUID().uuidString
			, "appId" : "GENERAL_IOS_APP"
			, "operation" : "getLotteryResult"
		]
		
		IHProgressHUD.show()
		
		self.sessionManager.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
			
			IHProgressHUD.dismiss()
			
			if let htmlStatusCode : Int = response.response?.statusCode {
				if htmlStatusCode == 200 {
					switch response.result {
					case .success:
						if let jsonResponse = response.result.value {
							let json = JSON(jsonResponse)
							switch (json["responseStatus"]["code"].stringValue) {
							case "00000":
								print(json["result"])
								self.dataJSON = json["result"]["data"]
								self.tableView.reloadData()
								break
							default:
								break
							}
						}
						break
					case .failure(_):
						
						break
					default:
						break
						
					}
				}
				
			}
			
		}
		
	}

}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as? UITableViewCell {
			
			let row = indexPath.row
			let section = indexPath.section
			
			var numbers : JSON = JSON.null
			if self.dataJSON != JSON.null {
				switch section {
				case 0:
					numbers = self.dataJSON["first"]["number"]
					
				case 1:
					numbers = self.dataJSON["second"]["number"]
					
				case 2:
					numbers = self.dataJSON["third"]["number"]
					
				case 3:
					numbers = self.dataJSON["fourth"]["number"]
					
				case 4:
					numbers = self.dataJSON["fifth"]["number"]
					
				default :
					
					break
				}
				
			}
			
			if row < numbers.count {
				let data = numbers[row]
				cell.textLabel?.text = data["value"].stringValue
			}
			
			return cell
		}
		
		return UITableViewCell(style: .default, reuseIdentifier: "none")
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.dataJSON != JSON.null {
			switch section {
			case 0:
				return self.dataJSON["first"]["number"].count
				
			case 1:
				return self.dataJSON["second"]["number"].count
				
			case 2:
				return self.dataJSON["third"]["number"].count
				
			case 3:
				return self.dataJSON["fourth"]["number"].count
				
			case 4:
				return self.dataJSON["fifth"]["number"].count
				
			default :
				
				break
			}
			
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "รางวัลที่ 1"
			
		case 1:
			return "รางวัลที่ 2"
			
		case 2:
			return "รางวัลที่ 3"
			
		case 3:
			return "รางวัลที่ 4"
			
		case 4:
			return "รางวัลที่ 5"
			
		default :
			
			break
		}
		return nil
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if self.dataJSON != JSON.null {
			
			return 5
		}
		return 0
	}
	
}
