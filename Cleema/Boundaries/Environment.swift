//
//  Environment.swift
//  Cleema
//
//  Created by Manuel Lehner on 10.04.24.
//

import Foundation

class Environment {

    private var variables: [String: String] = [:]

    init() {
        if let envFilePath = Bundle.main.path(forResource: ".env", ofType: nil) {
            do {
                let envString = try String(contentsOfFile: envFilePath)
                envString
                    .split(separator: "\n")
                    .forEach {
                        let keyValuePair = $0.split(separator: "=", maxSplits: 1)
                        if keyValuePair.count == 2 {
                            let key = String(keyValuePair[0])
                            let value = String(keyValuePair[1])
                            variables[key] = value
                        }
                    }
            } catch {
                print("Error reading .env file: \(error)")
            }
        }
    }

    func value(forKey key: String) -> String {
        return variables[key] ?? ""
    }
}
