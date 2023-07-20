//
//  SQLiteCommands.swift
//  PVExchange
//
//  Created by Karon Bell on 7/19/23.
//

import Foundation
import SQLite


class SQLiteCommands {
  
    
    static let id = Expression<Int>("id")
    static let firstName = Expression<String>("firstName")
    static let lastName  = Expression<String>("lastName")
    static let photo = Expression<Data>("photo")
}
