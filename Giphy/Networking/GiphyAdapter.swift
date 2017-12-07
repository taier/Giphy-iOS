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
    let IMG_DOWNLOAD_PER_REQUEST_COUNT = "100"
    
    func getImagesURLsForQuery(query: String, limit: Int, offset: Int, completion: @escaping (Array<AnyObject>) -> Void) {
        
        var returnImages = Array<AnyObject> ()
        
        // Excape input
        let excapedInput = query.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // Prepare request URL
        let requestUrl = "https://api.giphy.com/v1/gifs/search?q=" + excapedInput!
        
        let urlWithParams = requestUrl + "&api_key=kpPeUe6TpJCHlCrgUrR68M9lEaISJPEP&limit=" + String(limit) + "&offset=" + String(offset)
        
        // Create NSURL Ibject
        let myUrl = URL(string: urlWithParams);
        
        // Creaste URL Request
        var request = URLRequest(url:myUrl!)
        
        // Set request HTTP method to GET.
        request.httpMethod = "GET"
        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
        
            // Check for error
            if error != nil
            {
                print("error=\(error as Optional)")
                return
            }
            do {
                // Obtain gif urls from JSON
                if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String:Any] {
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
            
            DispatchQueue.main.async {
                completion(returnImages)
            }
        }
        task.resume()
    }
}
