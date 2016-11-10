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
	var token = Variable("")
	var coupon = Variable(0)
	var safariVC: SFSafariViewController?
	
	@IBOutlet weak var btn_login: UIButton!
	@IBOutlet weak var btn_miopon: UIButton!
	@IBOutlet weak var lbl_coupon: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let shared		= UserDefaults(suiteName: "group.jp.addon.mioswitch")
		token.value		= (shared?.string(forKey: "token")!)!
		coupon.value	= (shared?.integer(forKey: "coupon"))!

		NotificationCenter.default.rx.notification(Notification.Name("oAuthDone"))
			.subscribe(onNext: { (notification) in
			self.token.value = (notification.object as! String)
			self.safariVC?.dismiss(animated: true, completion: {
				self.loadCoupon()
			})
		}).addDisposableTo(disposeBag)
		
		token.asObservable().subscribe(onNext: { (str) in
			if (str != ""){
				self.loadCoupon()
			}else{
				self.saveSharedDefault(token: "")
			}
		}).addDisposableTo(disposeBag)

		coupon.asObservable().subscribe(onNext: { (value) in
			if (self.token.value != ""){
				self.lbl_coupon.text = String(value) + " MB"
			}else{
				self.lbl_coupon.text = "------ MB"
			}
			self.saveSharedDefault(coupon: value)
		}).addDisposableTo(disposeBag)
		
		btn_login.rx.tap.subscribe(onNext:{
			if (self.token.value == ""){
				let urlString = "https://api.iijmio.jp/mobile/d/v1/authorization/?response_type=token&client_id="+self.devID!+"&redirect_uri=mioswitchapp://callback/&state=test_state"
				self.safariVC =  SFSafariViewController(url: NSURL(string: urlString)! as URL)
				self.present(self.safariVC!, animated: true, completion: nil)
			}else{
				self.token.value = ""
				self.coupon.value = 0
			}
		}).addDisposableTo(disposeBag)
		
		btn_miopon.rx.tap.subscribe(onNext:{
			UIApplication.shared.open(URL(string: "miopon://")!, options: [:], completionHandler: nil)
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
		//
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	private func loadCoupon(){
		print("loadCoupon! \(self.token.value)")
		let provider = MioProvider.DefaultProvider()
		provider.request(.coupon(token:token.value)) { (result) in
			switch result{
			case let .success(moyaResponse):
				//let statusCode = moyaResponse.statusCode
				do{
					let data = try moyaResponse.mapJSON()
					self.coupon.value = self.countCoupon(json:JSON(data))
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
		provider.request(.packet(token:token.value)) { (result) in
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
	
	func saveSharedDefault(token:String){
		let shared = UserDefaults(suiteName: "group.jp.addon.mioswitch")
		shared?.setValue(token, forKey: "token")
		shared?.synchronize()
	}
}

