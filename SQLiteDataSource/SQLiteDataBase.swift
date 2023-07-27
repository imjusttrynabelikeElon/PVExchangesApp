//
//  SQLiteDataBase.swift
//  PVExchange
//
//  Created by Karon Bell on 7/19/23.
//


import Foundation
import SQLite
import Photos

protocol SQliteDatabaseDelegate: AnyObject {
    func photoInserted(photo: Photo)
}

class SQliteDatabase {
    static let sharedInstance = SQliteDatabase()
       var database: Connection?
       var isInitialized: Bool = false // Add the isInitialized property
       weak var delegate: SQliteDatabaseDelegate?
       
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
    func initializeDatabase(completion: @escaping (Bool) -> Void) {
        // Get the URL for the documents directory where the database file will be stored
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not get documents directory URL.")
            completion(false) // Call the completion handler with `false` to indicate initialization failure
            return
        }
        
        // Append the database file name to the documents directory URL
        let databaseFileURL = documentsDirectoryURL.appendingPathComponent("photos.sqlite")
        
        do {
            
            
            // Create a connection to the database file
                   let database = try Connection(databaseFileURL.path)
                   self.database = database // Assign the database connection to the instance variable

                   // ... (rest of the code)
                   print("Database initialized successfully") // Add this line
                   completion(true) // Call the completion handler with `true` to indicate successful initialization
            
            // Create the "photos" table if it doesn't exist
            let photosTable = Table("photos")
            let imageData = Expression<Data>("imageData")
            let assetData = Expression<Data?>("assetData")
            let identifierData = Expression<Data?>("identifierData")
            let creationDate = Expression<Date?>("creationDate")
            let latitude = Expression<Double?>("latitude")
            let longitude = Expression<Double?>("longitude")
            
            try database.run(photosTable.create(ifNotExists: true) { table in
                table.column(imageData)
                table.column(assetData)
                table.column(identifierData)
                table.column(creationDate)
                table.column(latitude)
                table.column(longitude)
            })
            
            // Database is now initialized
            isInitialized = true
            completion(true) // Call the completion handler with `true` to indicate successful initialization
        } catch {
            print("Error initializing database: \(error)")
            completion(false) // Call the completion handler with `false` to indicate initialization failure
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
            let identifierData = Expression<Data?>("identifierData")
            let creationDate = Expression<Date>("creationDate") // Change to non-optional Date
            let latitude = Expression<Double>("latitude") // Change to non-optional Double
            let longitude = Expression<Double>("longitude") // Change to non-optional Double

            // Check if photo.creationDate is not nil, and if it is, use Date() as a default value
            let insertionDate = photo.creationDate ?? Date()

            // Check if photo.location is not nil, and if it is, use 0.0 as default latitude and longitude values
            let latitudeValue = photo.location?.coordinate.latitude ?? 0.0
            let longitudeValue = photo.location?.coordinate.longitude ?? 0.0

            let insert = photosTable.insert(
                imageData <- photo.image.pngData()!,
                identifierData <- photo.identifier.data(using: .utf8),
                creationDate <- insertionDate,
                latitude <- latitudeValue,
                longitude <- longitudeValue
            )

            do {
                let rowID = try database.run(insert)
                print("Photo inserted with rowID: \(rowID)")

                // Notify the delegate that a new photo is inserted
                delegate?.photoInserted(photo: photo)
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
            let imageData = Expression<Data>("imageData")
            let identifierData = Expression<Data?>("identifierData")
            let creationDate = Expression<Date?>("creationDate")
            let latitude = Expression<Double?>("latitude")
            let longitude = Expression<Double?>("longitude")

            for photo in try database.prepare(photosTable) {
                // Extract values from each column
                let imageDataValue = photo[imageData]
                let identifierDataValue = photo[identifierData]
                let creationDateValue = photo[creationDate] // Optional Date type
                let latitudeValue = photo[latitude]
                let longitudeValue = photo[longitude]
                
                print("ImageData: \(imageDataValue)")
                print("IdentifierData: \(identifierDataValue)")
                print("CreationDate: \(creationDateValue)")
                print("Latitude: \(latitudeValue)")
                print("Longitude: \(longitudeValue)")
                
                // Convert Data to UIImage
                if let image = UIImage(data: imageDataValue),
                    let identifierDataValue = identifierDataValue,
                    let identifier = String(data: identifierDataValue, encoding: .utf8),
                    let creationDate = creationDateValue,
                    let latitude = latitudeValue,
                    let longitude = longitudeValue
                {
                    // Create the Photo instance and add it to the photos array
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    let photo = Photo(image: image, identifier: identifier, creationDate: creationDate, location: location)
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
            let identifierData = Expression<Data?>("identifierData")
            let creationDate = Expression<Date>("creationDate") // Change to non-optional Date
            let latitude = Expression<Double>("latitude") // Change to non-optional Double
            let longitude = Expression<Double>("longitude") // Change to non-optional Double

            try database.run(photosTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(imageData)
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
