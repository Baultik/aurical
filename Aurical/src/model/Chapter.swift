//
//  Chapter.swift
//  Aurical
//
//  Created by Brian Ault on 7/6/17.
//  Copyright © 2017 XPR. All rights reserved.
//

import CoreMedia
import Foundation

class Chapter: NSObject {
    var title: String?
    var time = CMTime()
    var duration = CMTime()
    var index: Int = 0
}
