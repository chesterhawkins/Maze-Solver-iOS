//
//  Maze.swift
//  Maze Solver
//
//  Created by Chester Hawkins on 3/29/18.
//  Copyright © 2018 Ojee Labs. All rights reserved.
//

import UIKit
import Kingfisher

extension Helper {
    class MazeHelper {
        class func fetchAllMazes() {
            Globals.MazeGlobals.allMazes.removeAll()
            let mazesUrl = URL(string: "https://ojeelabs.nyc3.digitaloceanspaces.com/mazes.json")
            let request = URLRequest(url: mazesUrl!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
            URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else { return }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                    let list = json["list"] as? [[String: String]] ?? []
                    for i in stride(from: 0, to: list.count, by: 1) {
                        guard list[i]["description"] != nil, list[i]["url"] != nil, list[i]["shape"] != nil, let description = list[i]["description"], let mazeUrl = list[i]["url"], let shape = Maze.MazeShape(rawValue: list[i]["shape"]!) else { continue }
                        ImageDownloader.default.downloadImage(with: URL(string: mazeUrl)!, options: [], progressBlock: nil) {
                            (image, error, url, data) in
                            if error == nil && image != nil {
                                let maze = Maze(newMaze: "Maze \(i+1)", description: description, url: mazeUrl, image: image!, shape: shape)
                                maze.pixelData = Array2D(columns: Int(maze.image.size.width), rows: Int(maze.image.size.height), values: maze.image.pixelData()!)
                                Globals.MazeGlobals.allMazes.append(maze)
                                Globals.MazeGlobals.allMazes.sort(by: Maze.descending)
                                postMazeUpdate(maze: maze)
                            }
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            }).resume()
        }
        
        class func solveAllMazes() {
            for maze in Globals.MazeGlobals.allMazes {
                DispatchQueue.global(qos: .background).async {
                    maze.solve {
                    }
                    postMazeUpdate(maze: maze)
                }
            }
        }
        
        class func resetAllMazes() {
            for maze in Globals.MazeGlobals.allMazes {
                DispatchQueue.global(qos: .background).async {
                    maze.reset()
                    postMazeUpdate(maze: maze)
                }
            }
        }
        
        class func postMazeUpdate(maze: Maze) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Globals.MazeGlobals.mazeUpdateNotif), object: ["maze": maze])
        }
    }
}

extension Globals {
    struct MazeGlobals {
        static var allMazes: [Maze] = []
        static var mazeUpdateNotif = "MazeUpdated"
    }
}

class Maze {
    var name: String
    var description: String
    var url: String
    var pixelData: Array2D<Globals.Pixel>?
    var image: UIImage
    var status: MazeStatus
    var shape: MazeShape
    
    enum MazeStatus: String {
        case Unsolved
        case Solving
        case Solved
        case Unsolvable
    }
    
    enum MazeShape: String {
        case Rectangular
        case Circular
        case Triangular
        case Hexagonal
    }
    
    public init(newMaze name: String, description: String, url: String, image: UIImage, shape: MazeShape){
        self.name = name
        self.description = description
        self.url = url
        self.status = .Unsolved
        self.image = image
        self.shape = shape
    }
    
    func isEqualTo(_ other: Maze) -> Bool
    {
        return self.url == other.url
    }
    
    //Solve using breadth first search
    func solve(done: @escaping () -> ()){
        guard self.status != .Solving && self.status != .Solved else { return }
        reset()
        self.status = .Solving
        Helper.MazeHelper.postMazeUpdate(maze: self)
        
        DispatchQueue.global(qos: .background).async {
            let start = self.findStart()
            
            guard start != nil else {
                self.status = .Unsolvable
                Helper.MazeHelper.postMazeUpdate(maze: self)
                return
            }
            
            var queue = Queue<[(Int,Int)]>()
            queue.enqueue([start!])
            pathSearch: while !queue.isEmpty && self.status == .Solving {
                let path = queue.dequeue()!
                let pixel = path.last
                
                for adjacent in self.getAdjacentPixel(pixelLoc: pixel!) {
                    if self.pixelIsPath(pixelLoc: adjacent) {
                        self.markPixelAsVisited(pixelLoc: adjacent)
                        var newPath = path
                        newPath.append(adjacent)
                        queue.enqueue(newPath)
                    }
                    else if self.pixelIsEndingColor(pixelLoc: adjacent) {
                        self.status = .Solved
                        self.setPath(path: path)
                        break pathSearch
                    }
                }
            }
            if self.status != .Solved && self.status != .Unsolved {
                self.status = .Unsolvable
            }
            Helper.MazeHelper.postMazeUpdate(maze: self)
            done()
        }
    }
    
    func reset() {
        pixelData = Array2D(columns: Int(image.size.width), rows: Int(image.size.height), values: image.pixelData()!)
        self.status = .Unsolved
        Helper.MazeHelper.postMazeUpdate(maze: self)
    }
    
    //Change all pixels in path to green
    func setPath(path: [(Int,Int)]) {
        for position in path {
            self.setPixelToGreen(pixelLoc: position)
            //Thicken path drawing if possible
            for adjacent in self.getAdjacentPixel(pixelLoc: position) {
                if pixelWasVisited(pixelLoc: adjacent) || pixelIsPath(pixelLoc: adjacent) {
                    self.setPixelToGreen(pixelLoc: adjacent)
                }
            }
        }
    }
    
    //Find first first pixel that's adjacent to a white pixel and treat it as the starting point
    func findStart() -> (Int,Int)? {
        var start: (Int,Int)? = nil
        for i in stride(from: 0, to: pixelData!.columns, by: 1) {
            for j in stride(from: 0, to: pixelData!.rows, by: 1) {
                if pixelIsStartingColor(pixelLoc: (i,j)) {
                    for pixel in getAdjacentPixel(pixelLoc: (i, j)) {
                        if pixelIsPath(pixelLoc: pixel) {
                            start = (i, j)
                            return start!
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func getAdjacentPixel(pixelLoc: (Int,Int)) -> [(Int,Int)] {
        var adjacent: [(Int,Int)] = []
        if pixelLoc.0 >= 0 && pixelLoc.0 < pixelData!.columns - 1 {
            adjacent.append((pixelLoc.0+1,pixelLoc.1))
        }
        if pixelLoc.0 > 0 && pixelLoc.0 <= pixelData!.columns - 1 {
            adjacent.append((pixelLoc.0-1,pixelLoc.1))
        }
        if pixelLoc.1 >= 0 && pixelLoc.1 < pixelData!.rows - 1 {
            adjacent.append((pixelLoc.0,pixelLoc.1+1))
        }
        if pixelLoc.1 > 0 && pixelLoc.1 <= pixelData!.rows - 1 {
            adjacent.append((pixelLoc.0,pixelLoc.1-1))
        }
        return adjacent
    }
    
    //Path pixel defined as any color where RGB are all >= 150
    func pixelIsPath(pixelLoc: (Int,Int)) -> Bool {
        return pixelData![pixelLoc.0,pixelLoc.1].red >= 150 && pixelData![pixelLoc.0,pixelLoc.1].green >= 150 && pixelData![pixelLoc.0,pixelLoc.1].blue >= 150 && pixelData![pixelLoc.0,pixelLoc.1].alpha == 255
    }
    
    func pixelWasVisited(pixelLoc: (Int,Int)) -> Bool {
        return pixelData![pixelLoc.0,pixelLoc.1].alpha == 254
    }
    
    //Starting color defined as any color where r >= 175, g < 150 and b <= 150
    func pixelIsStartingColor(pixelLoc: (Int,Int)) -> Bool {
        return pixelData![pixelLoc.0,pixelLoc.1].red >= 175 && pixelData![pixelLoc.0,pixelLoc.1].green < 150 && pixelData![pixelLoc.0,pixelLoc.1].blue < 150
    }
    
    //Ending color defined as any color where r < 150, g < 150 and b >= 175
    func pixelIsEndingColor(pixelLoc: (Int,Int)) -> Bool {
        return pixelData![pixelLoc.0,pixelLoc.1].red < 150 && pixelData![pixelLoc.0,pixelLoc.1].green < 150 && pixelData![pixelLoc.0,pixelLoc.1].blue >= 175
    }
    
    func setPixelToGreen(pixelLoc: (Int,Int)) {
        return pixelData![pixelLoc.0,pixelLoc.1].value = Globals.Pixel.green
    }
    
    func markPixelAsVisited(pixelLoc: (Int,Int)) {
        pixelData![pixelLoc.0,pixelLoc.1].alpha = 254
    }
    
    class func descending(_ m1: Maze, _ m2: Maze) -> Bool {
        return m1.name.compare(m2.name) == ComparisonResult.orderedDescending
    }
}
