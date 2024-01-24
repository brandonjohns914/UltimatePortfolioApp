//
//  Bundle-Decodable.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/23/24.
//

import Foundation

extension Bundle {
    // 1)  decoding a file of type string to a generic T
    //T.Type = what kind of type T is expected to decode
    //T.self = default type of T if swift can decode it
    
    func decode<T: Decodable>(
        _ file: String,
        as type: T.Type = T.self,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        guard let url = self.url(forResource: file, withExtension: nil ) else {
            fatalError("Failed to locate \(file) in bundle")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        
        do {
            //returning the decodable contents
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' - \(context.debugDescription) ")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch - \(context.debugDescription) ")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to deocde \(file) from bundle due to missing \(type) value - \(context.debugDescription) ")
        } catch DecodingError.dataCorrupted(_){
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)" )
        }
        
    }
}


/*
1)
 T is a place holder itll be the same everywhere T is
 <T: Decodable> is generic type
 as T.Type = what kind of type T is expected to decode
  T.self = default type of T if swift can decode it
 Custom date if not use default dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
 Custom key if not use default keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
 
 
 
 */
