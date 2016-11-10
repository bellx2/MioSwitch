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
        
	@IBOutlet weak var lbl_coupon: UILabel!
	@IBAction func btn_detail(_ sender: Any) {
		let urlString = "mioswitchapp://"
		self.extensionContext?.open(URL.init(string: urlString)!, completionHandler: nil)
	}
	
	let disposeBag = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		let shared = UserDefaults(suiteName: "group.jp.addon.mioswitch")
		let coupon = Variable(shared?.integer(forKey: "coupon"))		
		coupon.asObservable().subscribe(onNext: { (value) in
			if (self.token.value != ""){
				self.lbl_coupon.text = String(value) + " MB"
			}else{
				self.lbl_coupon.text = "------ MB"
			}
			self.saveSharedDefault(coupon: value)
		}).addDisposableTo(disposeBag)
		
		amount.asObservable().subscribe(onNext: { (value) in
			lbl_coupon.text = value + " MB"
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
