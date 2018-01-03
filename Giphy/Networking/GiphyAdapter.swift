//
//  GiphyAdapter.swift
//  Giphy
//
//  Created by Den on 12/7/17.
//  Copyright © 2017 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

class GiphyAdapter: NSObject, NetworkingCallsProtocol {
    
    let API_KEY = "kpPeUe6TpJCHlCrgUrR68M9lEaISJPEP"
    
    func getImagesURLsForQuery(query: String, limit: Int, offset: Int, completion: @escaping (Array<AnyObject>) -> Void) {
        
        var returnImages = Array<AnyObject> ()
        let myUrl = self.composeRequestURL(query: query, limit: limit, offset: offset);
        var request = URLRequest(url:myUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
        
            if error != nil {
                print("error=\(error as Optional)")
                return
            }
            
            returnImages = self.parse(data:data!)
            
            DispatchQueue.main.async {
                completion(returnImages)
            }
        }
        
        task.resume()
    }
    
    func composeRequestURL(query: String, limit: Int, offset: Int) -> URL {
        // Excape input
        let excapedInput = query.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let requestUrl = "https://api.giphy.com/v1/gifs/search?q=" + excapedInput!
        let urlWithParams = requestUrl + "&api_key=" + API_KEY + "&limit=" + String(limit) + "&offset=" + String(offset)
        let myUrl = URL(string: urlWithParams);
        
        return myUrl!;
    }
    
    func parse(data: Data) -> Array<AnyObject> {
        var returnImages = Array<AnyObject> ()
        do {
            if let json = try JSONSerialization.jsonObject(with:data, options:.allowFragments) as? [String:Any] {
                if let data = json["data"] as? [AnyObject] {
                    for item in data  {
                        if let images = item["images"] as? [String:Any] {
                            if let fixed_height_downsampled = images["fixed_height_downsampled"] as? [String:AnyObject] {
                                if let url = fixed_height_downsampled["url"] {
                                    returnImages.append(url);
                                }
                            }
                        }
                    }
                }
            }
        } catch let err{
            print(err.localizedDescription)
        }
    
        return returnImages;
    }

}
