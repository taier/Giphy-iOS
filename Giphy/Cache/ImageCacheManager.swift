//
//  ImageCacheManager.swift
//  Giphy
//
//  Created by Den on 12/14/17.
//  Copyright © 2017 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

class ImageCacheManager: NSObject {

    static func saveGifToCacheDirectory(imageData:Data, name:String){
        let fileManager = FileManager.default
        let paths = (self.getImagesCacheDirectoryPath() as NSString).appendingPathComponent(name + ".gif")
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    static func getImageFromCache(name:String) -> UIImage?{
        var image:UIImage? = nil;
        let fileManager = FileManager.default
        let imagePAth = (self.getImagesCacheDirectoryPath() as NSString).appendingPathComponent(name + ".gif")
        if fileManager.fileExists(atPath: imagePAth){
            if let imageData:NSData = NSData(contentsOfFile:imagePAth) {
                image = UIImage.gif(data:imageData as Data)
            }
        }else{
            print("No Image found")
        }
        
        return image
    }
    
    static func getImagesCacheDirectoryPath() -> String {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var cachesDirectory = paths[0]
        cachesDirectory = (cachesDirectory as NSString).appendingPathComponent("images")
        var isDir : ObjCBool = true
        if !fileManager.fileExists(atPath: cachesDirectory, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: cachesDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        return cachesDirectory
    }
    
    static func clearCachDirectory(){
       let fileManager = FileManager.default
        let paths = self.getImagesCacheDirectoryPath()
        if fileManager.fileExists(atPath: paths){
            try! fileManager.removeItem(atPath: paths)
        }else{
            print("Cant remove Cache directory")
        }
    }
}
