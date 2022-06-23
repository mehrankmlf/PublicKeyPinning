//
//  ViewController.swift
//  PublicKeyPinning
//
//  Created by Mehran on 4/2/1401 AP.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var session: Session!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.testPinning()
    }
    
    private func testPinning() {
    
         session = Session(delegate:CustomSessionDelegate())
        
        session
            .request("https://github.com", method: .get)
            .validate()
            .response(completionHandler: { [weak self] response in
                switch response.result {
                case .success:
                    print(response.data)
                case .failure(let error):
                    print(error.errorDescription)
                }
            })
    }
}

