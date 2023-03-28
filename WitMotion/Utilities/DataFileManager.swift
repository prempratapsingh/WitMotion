//
//  DataFileManager.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit

class DataFileManager {
    
    // MARK: - Public methods
    
    static func createDirectory(atPath path: String, error: inout Error?) -> Bool {
        let manager = FileManager.default
        do {
            try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch let err {
            error = err
            return false
        }
    }
    
    static func getNowTimeTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let time = formatter.string(from: Date())
        return time
    }
    
    static func fileRootPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileRootPath = (paths[0] as NSString).appendingPathComponent("WITMOTION")
        
        return fileRootPath
    }
    
    static func getTheFilePath(recordFileName: String) -> String {
        let fileRootPath = self.fileRootPath()
        let todayFilePath = (fileRootPath as NSString).appendingPathComponent(self.getNowTimeTimestamp())
        
        var error: Error?
        if self.createDirectory(atPath: todayFilePath, error: &error) {
            // no error
        } else if let err = error {
            print("Error creating directory: \(err)")
        }
        
        let tempFilePath = (todayFilePath as NSString).appendingPathComponent("\(recordFileName).txt")
        return tempFilePath
    }
    
    class func listFilesInDirectory() -> [String]? {
        return listFilesInDirectoryAtPath(self.fileRootPath(), deep: false)
    }

    class func listFilesInDirectoryAtPath(_ path: String, deep: Bool) -> [String]? {
        var listArr: [String]?
        let manager = FileManager.default
        var error: Error?
        if deep {
            // Deep traversal
            let deepArr = manager.subpaths(atPath: path)
            if error == nil {
                listArr = deepArr
            } else {
                listArr = nil
            }
        } else {
            // Shallow traversal
            let shallowArr = try? manager.contentsOfDirectory(atPath: path)
            if error == nil {
                listArr = shallowArr
            } else {
                listArr = nil
            }
        }
        return listArr
    }

    class func removeItemAtPath(_ path: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    class func writeToTXTFile(with string: String, recordFileName: String) {
        DispatchQueue.global(qos: .background).async {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            let filePath = self.getTheFilePath(recordFileName: recordFileName)
            // create file manager
            let fileManager = FileManager.default
            // if file does not exist, create it
            if !fileManager.fileExists(atPath: filePath) {
                try? "".write(toFile: filePath, atomically: true, encoding: .utf8)
            }
            let fileHandle = FileHandle(forUpdatingAtPath: filePath)
            fileHandle?.seekToEndOfFile()  // set the file handle to the end of the file
            let stringData = "\(string)\n".data(using: .utf8)
            fileHandle?.write(stringData ?? Data())  // append data to the file
            fileHandle?.closeFile()
        }
    }

    class func shareActivityVC(_ vc: UIViewController, recordFileName: String) {
        let filePath = self.getTheFilePath(recordFileName: recordFileName)
        let shareUrl = URL(fileURLWithPath: filePath)
        let activityItems = [shareUrl]
        let shareActivityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        vc.present(shareActivityVC, animated: true, completion: nil)
    }
}
