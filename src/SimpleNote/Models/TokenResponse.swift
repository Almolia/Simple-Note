//
//  TokenResponse.swift
//  SimpleNote
//
//  Created by Ali M.Sh on 4/19/1404 AP.
//

import Foundation

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access"
        case refreshToken = "refresh"
    }
}
