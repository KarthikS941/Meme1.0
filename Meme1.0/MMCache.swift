//
//  MMCache.swift
//  Meme1.0
//
//  Created by Karthik Sankar on 9/5/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//
// Used as Temporary Storage for Memes created , will get erased when app is closed.
import UIKit

class MMCache: NSObject {
    
    var sharedMemes = [MMMeme] ()       // Saves Meme Object
    
    static let sharedMemory = MMCache() // Singleton to access cache throughout application
    
    // Private Init
    private override init() {
        
    }
    // Save Meme given to Cache
    func saveShared(meme: MMMeme) {
        self.sharedMemes.append(meme)
    }
}
