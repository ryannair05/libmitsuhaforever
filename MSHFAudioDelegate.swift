//
//  MSHFAudioDelegate.swift
//  libmitsuhaforever
//
//  Created by Ryan Nair on 9/17/20.
//  Copyright © 2020 Ryan Nair. All rights reserved.
//

import Foundation

protocol MSHFAudioDelegate: class {
    func updateBuffer(_ bufferData: UnsafeMutablePointer<Float>, withLength length: Int)
}
