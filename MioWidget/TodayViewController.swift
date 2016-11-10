//
//  TodayViewController.swift
//  MioWidget
//
//  Created by bell on 2016/11/03.
//  Copyright © 2016年 Addon Inc. All rights reserved.
//

import UIKit
import NotificationCenter
import RxCocoa
import RxSwift

class TodayViewController: UIViewController, NCWidgetProviding {
        

	@IBOutlet weak var btn_Coupon: UIButton!
	
	@IBAction func btn_detail(_ sender: Any) {
		let urlString = "mioswitchapp://"
		self.extensionContext?.open(URL.init(string: urlString)!, completionHandler: nil)
	}
	
	let disposeBag = DisposeBag()
	var token = Variable("")
	var coupon = Variable(0)
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let shared = UserDefaults(suiteName: "group.jp.addon.mioswitch")
		coupon.value = (shared?.integer(forKey: "coupon"))!
		token.value	= (shared?.string(forKey: "token"))!
	
		coupon.asObservable().subscribe(onNext: { (value) in
			if (self.token.value != ""){
				self.btn_Coupon.setTitle("\(value) MB", for: UIControlState.normal)
			}else{
				self.btn_Coupon.setTitle("---- MB", for: UIControlState.normal)
			}
		}).addDisposableTo(disposeBag)
		
		btn_Coupon.rx.tap.subscribe(onNext:{ (value) in
			print("tap!")
		}).addDisposableTo(disposeBag)
	
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }

}
