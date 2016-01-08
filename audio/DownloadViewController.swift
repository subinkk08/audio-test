//
//  DownloadViewController.swift
//  audio
//
//  Created by Vineeth Vijayan on 15/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit
import Alamofire
import FileKit

class DownloadViewController: UIViewController {

    @IBAction func btnDownloadTapped(sender: AnyObject) {
        
//        let destination = Alamofire.Request.suggestedDownloadDestination (directory: .DocumentDirectory, domain: .UserDomainMask)
//        Alamofire.download(.GET, "https://www.dropbox.com/s/4eskf3xvsiapp64/bsmpalv2purchase-2.0.0.11-2.1.0.0.zip", destination: destination)
        
        
//        Alamofire.download(.GET, "https://www.dropbox.com/s/4eskf3xvsiapp64/bsmpalv2purchase-2.0.0.11-2.1.0.0.zip")
//            { temporaryURL, response in
//            let suggestedFilename = response.suggestedFilename
//            let url = NSURL(fileURLWithPath: Path.UserTemporary.description
//                + suggestedFilename! as String)
//            print(url)
//            return url  // or FKPath(suggestedFilename) if not compil
//        }
    
        print(NSSearchPathDirectory.UserDirectory)
        
        print(Path.UserHome.description)
        
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: NSSearchPathDirectory.UserDirectory, domain: .UserDomainMask) //NSURL(fileURLWithPath: Path.UserTemporary.description as String)
        
        Alamofire.download(.GET, "https://www.dropbox.com/s/4eskf3xvsiapp64/bsmpalv2purchase-2.0.0.11-2.1.0.0.zip", destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                print(totalBytesRead)
                
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    print("Total bytes read on main queue: \(totalBytesRead)")
                }
            }
            .response { _, _, _, error in
                print(destination)
                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                }
        }
    }
    
    @IBAction func btnFileCheckTapped(sender: AnyObject) {
        print("File Check tapped")
        let zipFiles = Path.UserHome.find(searchDepth: 1) { path in
            path.pathExtension == "zip"
            &&
            path.fileName == "bsmpalv2purchase-2.0.0.11-2.1.0.0.zip"
        }
        
        print(zipFiles.count)
        if zipFiles.count >= 1 {
            print(zipFiles[0].fileSize)
            _ = try? zipFiles[0].deleteFile()
//            let p = zipFiles[0]
//            print(p.filePermissions)
            
        }
//        print(Path.UserHome.description)
//        Path.UserTemporary
//        FKPath(FKPath.UserTemporary.description+AddExpenseViewController.fileName).exists == true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
