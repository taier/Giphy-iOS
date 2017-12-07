//
//  NetworkingCallsProtocol.swift
//  Giphy
//
//  Created by Den on 12/7/17.
//  Copyright © 2017 Deniss Kaibagarovs. All rights reserved.
//


protocol NetworkingCallsProtocol {
    func getImagesURLsForQuery(query:String, limit:Int, offset:Int, completion:@escaping  (_ result: Array<AnyObject>) -> Void)
}
