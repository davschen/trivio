//
//  EnglishDictionary.swift
//  Trivio! (iOS)
//
//  Created by David Chen on 4/24/23.
//

import Foundation

struct Datamuse {
    let baseUrl = "https://api.datamuse.com/words?"

    func checkWord(word: String, completion: @escaping (Bool) -> Void) {
        let urlString = baseUrl + "sp=\(word.lowercased())&max=1"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            if let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
               let firstResult = jsonArray.first,
               let foundWord = firstResult["word"] as? String,
               foundWord.lowercased() == word.lowercased() {
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
}

