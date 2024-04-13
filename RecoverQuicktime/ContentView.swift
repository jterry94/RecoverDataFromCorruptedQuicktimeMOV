//
//  ContentView.swift
//  RecoverQuicktime
//
//  Created by Jeff Terry on 4/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var filePath: String = "/Volumes/My%20Passport%20for%20Mac/EclipseApril082024/20240408_155422_L/20240408_155422_L.mov"
                @State private var fileContent: Data?
                
                var body: some View {
                    VStack {
                        TextField("Enter file path", text: $filePath)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            do {
                                
                                try loadFile()
                            }catch{
                                
                                print(error)
                            }
                            }) {
                            Text("Load File")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        
                        
                        Spacer()
                    }
                    .padding()
                }
    
    
    func loadBlock(myOffset: UInt64, size: Int, path: String) throws -> Data {
            let correctPath = path.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")

            guard let fileHandle = FileHandle(forReadingAtPath: correctPath) else { throw NSError() }

            let bytesOffset = UInt64(myOffset)
            fileHandle.seek(toFileOffset: bytesOffset)
            let data = fileHandle.readData(ofLength: size)
            fileHandle.closeFile()
            return data
        }
    
    func loadFile() throws {
        
            let correctPath = filePath.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        
            let size = sizeForLocalFilePath(filePath: correctPath)
        
            print(size)
        
        let imageSizeInBytes :Int = 2736*2192*2
        
        print(imageSizeInBytes)
        
        let numberOfImages = size/UInt64(imageSizeInBytes)
        
        print(numberOfImages)
        
        for i in 0..<numberOfImages{
            
            let offset :UInt64 = i*UInt64(imageSizeInBytes) + 4096
            
            
            do {
                fileContent = try loadBlock(myOffset: offset, size: imageSizeInBytes, path: filePath)
                
                
            } catch {
                // Handle file loading error
                print("error")
            }
            
            var newFilePath = (URL(string: $filePath.wrappedValue)?.deletingLastPathComponent().absoluteString)!
            
            newFilePath += "\(i)" + ".bin"
            
            let outPutPath = newFilePath.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
            
            FileManager.default.createFile(atPath: outPutPath, contents: nil, attributes: nil)

            guard let outPutFileHandle = FileHandle(forWritingAtPath: outPutPath) else { throw NSError() }
            
            outPutFileHandle.write(fileContent!)
            
            
            try outPutFileHandle.close()
        }
            
            
        
        }
    
    func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
}

#Preview {
    ContentView()
}
