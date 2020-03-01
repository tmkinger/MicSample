//
//  RecorderUtility.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 01/03/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit

class RecorderUtility: NSObject {
    
    class func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    class func getLastFileIndex() -> Int {
        var lastFileIndex = 0
        if let fileURLS = self.fetchFileURLs(), let lastFileName = fileURLS.last, let fileNumber = lastFileName.components(separatedBy: " ").last {
            lastFileIndex = Int(fileNumber) ?? 0
        }
        return lastFileIndex
    }
    
    class func fetchFileURLs() -> [String]? {
        let fileManager = FileManager.default
        if let documentsURL = self.getDocumentsDirectory() {
            do {
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                print(directoryContents)
                
                // if you want to filter the directory contents you can do like this:
                let cafFiles = directoryContents.filter{ $0.pathExtension == "caf" }
                var cafFileNames = cafFiles.map{ $0.deletingPathExtension().lastPathComponent }
                cafFileNames.sort{$0.localizedStandardCompare($1) == .orderedAscending}
                return cafFileNames
            } catch {
                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
        }
        return []
    }
}

extension UIButton {
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.bounds.contains(point) ? self : nil
    }
    
    func blink(enabled: Bool = true, duration: CFTimeInterval = 1.0, stopAfter: CFTimeInterval = 0.0 ) {
        enabled ? (UIView.animate(withDuration: duration, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in
                self?.alpha = 0.3
                self?.layer.borderWidth = 3.0
                self?.layer.borderColor = UIColor.green.cgColor
            },
            completion: { [weak self] _ in
                self?.alpha = 1.0
                self?.layer.borderWidth = 0.0
                
        })) : self.layer.removeAllAnimations()
        if !stopAfter.isEqual(to: 0.0) && enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) { [weak self] in
                self?.layer.removeAllAnimations()
            }
        }
    }
}
