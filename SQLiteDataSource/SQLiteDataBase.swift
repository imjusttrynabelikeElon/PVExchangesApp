//
//  SQLiteDataBase.swift
//  PVExchange
//
//  Created by Karon Bell on 7/19/23.
//

import Foundation
import SQLite
import Photos


class SQliteDatabase {
    static let sharedInstance = SQliteDatabase()
    var database: Connection?
    var isInitialized: Bool = false // Add the isInitialized property
    
    private init() {
        // Create connection to the database
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("myDatabase.sqlite3")
            database = try Connection(fileUrl.path)
            
            // Debug print statements
            print("Database connection successful")
            
            isInitialized = true // Mark the database as initialized
            
            if !isTableExists("photos") {
                createTable() // Call the createTable() function only if the "photos" table does not exist
            }
        } catch {
            print("Creating connection to the database error: \(error)")
        }
    }
    
    
    
    
    func insertPhoto(photo: Photo) {
        do {
            guard let database = database else {
                print("Error: Database is not initialized.")
                return
            }
            
            let photosTable = Table("photos")
            let id = Expression<Int>("id")
            let imageData = Expression<Data>("imageData")
            let identifierData = Expression<Data?>("identifierData") // Changed from assetData to identifierData
            
            let insert = photosTable.insert(
                imageData <- photo.image.pngData()!,
                identifierData <- photo.asset.localIdentifier.data(using: .utf8) // Store the identifier as Data
            )
            
            do {
                let rowID = try database.run(insert)
                print("Photo inserted with rowID: \(rowID)")
            } catch {
                print("Error inserting photo: \(error)")
            }
        } catch {
            print("Error creating photos table: \(error)")
        }
    }

    
    func getAllPhotos() -> [Photo] {
        var photos: [Photo] = []
        do {
            guard let database = database else {
                print("Error: Database is not initialized.")
                return photos
            }
            
            let photosTable = Table("photos")
            let imageData = Expression<Data?>("imageData")
            let assetData = Expression<Data?>("assetData") // Add the assetData column
            let identifierData = Expression<Data?>("identifierData")
            let creationDate = Expression<Date?>("creationDate")
            let latitude = Expression<Double?>("latitude")
            let longitude = Expression<Double?>("longitude")
            
            for photo in try database.prepare(photosTable) {
                if let imageData = photo[imageData],
                   let image = UIImage(data: imageData),
                   let assetData = photo[assetData], // Add this line to get the assetData column
                   let asset = NSKeyedUnarchiver.unarchiveObject(with: assetData) as? PHAsset, // Unarchive the asset data back to PHAsset
                   let identifierData = photo[identifierData],
                   let identifier = String(data: identifierData, encoding: .utf8), // Convert Data back to String
                   let creationDate = photo[creationDate],
                   let latitude = photo[latitude],
                   let longitude = photo[longitude]
                {
                    print("Photo retrieved with identifier: \(identifier)")
                    
                    // Create the Photo instance and add it to the photos array
                    let photo = Photo(image: image, asset: asset, identifier: identifier, creationDate: creationDate, location: CLLocation(latitude: latitude, longitude: longitude))
                    photos.append(photo)
                }
            }
        } catch {
            print("Error retrieving photos: \(error)")
        }
        return photos
    }


    
    
    // Add the createTable function that takes a database connection as a parameter
    // Add the createTable function to create the "photos" table
    func createTable() {
           guard let database = database else {
               print("Error: Database is not initialized.")
               return
           }
           
           do {
               if isTableExists("photos") {
                   print("Table 'photos' already exists.")
                   return
               }
               
               let photosTable = Table("photos")
               let id = Expression<Int>("id")
               let imageData = Expression<Data>("imageData")
               let identifierData = Expression<Data?>("identifierData") // Add the identifierData column
               let creationDate = Expression<Date?>("creationDate")
               let latitude = Expression<Double?>("latitude")
               let longitude = Expression<Double?>("longitude")
               
               let assetData = Expression<Data?>("assetData") // Add the assetData column

                  try database.run(photosTable.create(ifNotExists: true) { table in
                      table.column(id, primaryKey: .autoincrement)
                      table.column(imageData)
                      table.column(assetData) // Add the assetData column
                      table.column(identifierData)
                      table.column(creationDate)
                      table.column(latitude)
                      table.column(longitude)
                  })
               
               // Debug print statement
               print("Table 'photos' created successfully")
           } catch {
               print("Error creating table: \(error)")
           }
       }
    
    // Helper function to check if a table exists
    func isTableExists(_ tableName: String) -> Bool {
        guard let database = database else {
            print("Error: Database is not initialized.")
            return false
        }
        
        do {
            let count = try database.scalar("SELECT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?)", tableName)
            return (count as? Int64 ?? 0) > 0
        } catch {
            print("Error checking if table exists: \(error)")
            return false
        }
    }
}

extension Optional where Wrapped == Double {
    var optionalDouble: Double? {
        return self
    }
}


extension Optional where Wrapped == String {
    var optionalString: String? {
        return self
    }
}
