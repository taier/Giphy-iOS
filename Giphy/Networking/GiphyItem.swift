//
// Created by Den on 5/18/18.
// Copyright (c) 2018 Deniss Kaibagarovs. All rights reserved.
//

import Foundation

struct GiphyItem : Codable {
    let data : Array<DataItem>?
}

struct DataItem : Codable {
    let images: Dictionary<String,ImgContainer>?
}

struct ImgContainer : Codable {
    let url : String?
}

