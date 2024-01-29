//
//  Award.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/24/24.
//

import Foundation

struct Award: Decodable, Identifiable {
    var id: String {name}
    var name: String
    var description: String
    var color: String
    var criterion: String
    var value: Int
    var image: String
    // decode is coming from the bundle extension
    // static let allAwards: [Award] = Bundle.main.decode("Awards.json") these two lines are equal
    static let allAwards = Bundle.main.decode("Awards.json", as: [Award].self)
    static let example = allAwards[0]
}
