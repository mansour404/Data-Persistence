//
//  Array + Extensions.swift
//  Data-Persistence
//
//  Created by Mohamed Adel on 24/01/2024.
//

import Foundation

extension Array
{
    mutating func mapInPlace(transform: (inout Element) -> Void)
    {
        for i in 0 ..< self.count
        {
            transform(&self[i])
        }
    }
}
