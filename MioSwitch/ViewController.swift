//
//  ViewController.swift
//  MioSwitch
//
//  Created by tanabe on 2016/11/02.
//  Copyright © 2016年 Addon Inc. All rights reserved.
//

import UIKit
import SafariServices
import RxCocoa
import RxSwift
import SwiftyJSON
import Keys
import Moya

class ViewController: UIViewController {
	
	let disposeBag = DisposeBag()
	let devID = MioswitchKeys().devID()	
	var token:String?
	var coupon_avail = Variable(0)
	var safariVC: SFSafariViewController?
	
	@IBOutlet weak var btn_login: UIButton!
	@IBOutlet weak var btn_miopon: UIButton!
	@IBOutlet weak var lbl_coupon: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let shared = UserDefaults(suiteName: "group.jp.addon.mioswitch")
		token = shared?.string(forKey: "token")
		print("******* token : \(token)")

		NotificationCenter.default.addObserver(self, selector: #selector(oAuthDone), name: Notification.Name("oAuthDone"), object: nil)
		
		//初期値設定
		let amount = shared?.integer(forKey: "coupon")
		if (amount != nil){
			coupon_avail.value = amount!
		}
		
		btn_login.rx.tap.subscribe(onNext:{
			if (self.token == ""){
				self.openAuthURL()
			}else{
				self.token = ""
				self.coupon_avail.value = 0
			}
		}).addDisposableTo(disposeBag)
		
		btn_miopon.rx.tap.subscribe(onNext:{
			self.openMioPon()
		}).addDisposableTo(disposeBag)
		
		coupon_avail.asObservable().subscribe(onNext: { (value) in
			if (self.token == nil || self.token == ""){
				self.lbl_coupon.text = " ----- MB"
			}else{
				self.lbl_coupon.text = String(value) + " MB"
			}
			print(value)
		}).addDisposableTo(disposeBag)
		
	}
	
	func countCoupon(json:JSON) -> Int{
		let coupons = json["couponInfo"][0]
		var amount = 0
		for (_,c) in coupons["coupon"]{
			amount += c["volume"].intValue
		}
		print ("総残量:\(amount)")
		return amount
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//表示する時にリロード
		if (token != nil && token != ""){
			self.loadCoupon()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc private func oAuthDone(notification: NSNotification?){
		self.token = (notification?.object as! String)
		safariVC?.dismiss(animated: true, completion: { 
			self.loadCoupon()
		})
	}
	
	private func openAuthURL(){
		let urlString = "https://api.iijmio.jp/mobile/d/v1/authorization/?response_type=token&client_id="+self.devID!+"&redirect_uri=mioswitchapp://callback/&state=test_state"
		safariVC =  SFSafariViewController(url: NSURL(string: urlString)! as URL)
		self.present(safariVC!, animated: true, completion: nil)
	}
	
	private func openMioPon(){
		let urlString = "miopon://"
		UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
	}
	
	@objc private func loadCoupon(){
		print("loadCoupon! \(self.token)")
		let provider = MioProvider.DefaultProvider()
		provider.request(.coupon(token:token!)) { (result) in
			switch result{
			case let .success(moyaResponse):
				//let statusCode = moyaResponse.statusCode
				do{
					let data = try moyaResponse.mapJSON()
					//print(data)
					let amount = self.countCoupon(json:JSON(data))
					self.coupon_avail.value = amount
					self.saveSharedDefault(coupon: amount)
				}catch{
					//
				}
			case let .failure(error):
				print(error)
			}
		}
	}
	
	private func loadPacket(){
		let provider = MioProvider.DefaultProvider()
		provider.request(.packet(token:token!)) { (result) in
			switch result{
			case let .success(moyaResponse):
				//let statusCode = moyaResponse.statusCode
				do{
					let data = try moyaResponse.mapJSON()
					print(data)
				}catch{
					//
				}
			case let .failure(error):
				print(error)
			}
		}
	}

	func saveSharedDefault(coupon:Int){
		let shared = UserDefaults(suiteName: "group.jp.addon.mioswitch")
		shared?.setValue(coupon, forKey: "coupon")
		shared?.synchronize()
	}
}

