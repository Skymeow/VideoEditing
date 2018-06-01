//
//  URL+Actions.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 1/3/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import UIKit

extension URL{
    func shareContentFromURL(in vc: UIViewController, message messageString: String?){
        
        var activityItems = [self] as [Any]
        
        if let message = messageString{
            activityItems.append(message)
        }
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                print("cancelled sending")
                return
            }
            // User completed activity
            print("finished sending")
        }
        
        activityController.popoverPresentationController?.sourceView = vc.view
        activityController.popoverPresentationController?.sourceRect = vc.view.frame
        vc.present(activityController, animated: true, completion: nil)
    }
}
