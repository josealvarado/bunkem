//
//  SFDImageUploadDownloadService.swift
//  bunkem
//
//  Created by Jose Alvarado on 12/15/16.
//  Copyright © 2016 BunkEm. All rights reserved.
//

import UIKit

class SFDImageUploadDownloadService: NSObject {

    class  func getDownloadDocumentsDirectory() -> URL {
        do {
            try FileManager.default.createDirectory(
                at: NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download")!,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
        return NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("download")!
    }
    
    class func saveImageLocally(image: UIImage, fileName: String) -> URL?{
        do {
            let documentsURL = getDownloadDocumentsDirectory()
            let fileURL = documentsURL.appendingPathComponent("\(fileName)")
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: fileURL, options: .atomic)
                
                return fileURL
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    class func initiateDownloadImage(fileName: String) -> URL? {
        let documentsURL = getDownloadDocumentsDirectory()
        let downloadingFileURL = documentsURL.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: downloadingFileURL.path) {
            print("File is already saved locally")
            return downloadingFileURL
        } else {
            return nil
        }
    }
}
