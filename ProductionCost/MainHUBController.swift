//
//  MainHUBController.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import Alamofire

class MainHUBController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var productsButton:   UIButton!
    @IBOutlet weak var componentsButton: UIButton!
    @IBOutlet weak var suppliersButton:  UIButton!
    @IBOutlet weak var accountButton:    UIButton!
    @IBOutlet weak var settingsButton:   UIButton!
    @IBOutlet weak var aboutbutton:      UIButton!
    @IBOutlet weak var quoteLabel:       UILabel!
    @IBOutlet weak var authorLabel:      UILabel!
    
    // MARK: properties 
    
    var hasQuote = false

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        requestQuote()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let font    = UIFont.fontAwesomeOfSize(20)
        let buttons = [productsButton:   String.fontAwesomeIconWithName(.Cubes),
                       componentsButton: String.fontAwesomeIconWithName(.Cube),
                       suppliersButton:  String.fontAwesomeIconWithName(.Truck),
                       accountButton:    String.fontAwesomeIconWithName(.User),
                       settingsButton:   String.fontAwesomeIconWithName(.Gears),
                       aboutbutton:      String.fontAwesomeIconWithName(.Info)]
        
        for (button, icon) in buttons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.size.height / 2
            button.titleLabel?.font = font
            button.setTitleColor(AppColors.white, forState: .Normal)
            button.setTitle(icon, forState: .Normal)
        }
        
        productsButton.setTitleColor(AppColors.raspberry, forState: .Normal)
        aboutbutton.setTitleColor(AppColors.raspberry, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    private func requestQuote() {
        print("quote requested")
        request(.GET, "http://api.forismatic.com/api/1.0/?method=getQuote&lang=en&format=json")
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .Success(let json):
                    self.prepareQuoteLabel(fromJSON: json as? [String:AnyObject])
                case .Failure(let error) :
                    print("JSON ERROR : \(error)")
                    if error.code == 3840 {
                        self.requestQuote()
                    }
                }
        }
    }
    
    private func prepareQuoteLabel(fromJSON json: [String:AnyObject]?) {
        guard let json = json else {
            print("json error")
            return
        }
        
        let quote  = json["quoteText"]!   as! String
        let author = json["quoteAuthor"]! as! String
        
        transition(onView: quoteLabel, withDuration: 0.5) {
            self.quoteLabel.text  = "\"\(quote.trim())\""
        }
        
        transition(onView: authorLabel, withDuration: 0.5) {
            self.authorLabel.text = "At some point in history, \(author.trim()) said :"
        }
        
    }

}
