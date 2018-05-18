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
    
    func getImagesURLsForQuery(query: String, limit: Int, offset: Int, completion: @escaping (Array<DataItem>) -> Void) {
        
        var returnImages = Array<DataItem> ()
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
        // Escape input
        let excapedInput = query.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let requestUrl = "https://api.giphy.com/v1/gifs/search?q=" + excapedInput!
        let urlWithParams = requestUrl + "&api_key=" + API_KEY + "&limit=" + String(limit) + "&offset=" + String(offset)
        let myUrl = URL(string: urlWithParams);
        
        return myUrl!;
    }
    
    func parse(data: Data) -> Array<DataItem> {
        var itemsData:GiphyItem = GiphyItem(data: Array<DataItem>())
        do {
            let decoder = JSONDecoder()
            itemsData = try decoder.decode(GiphyItem.self, from: data)
        } catch let err{
            print(err.localizedDescription)
        }
        
        return itemsData.data!;
    }

}
