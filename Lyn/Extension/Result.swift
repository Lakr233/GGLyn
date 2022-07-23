//
//  Result.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import Foundation

public extension Result where Success == Void {
    static func success() -> Self { .success(()) }
}
