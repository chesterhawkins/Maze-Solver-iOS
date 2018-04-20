//
//  SolvedMazeViewController.swift
//  Maze Solver
//
//  Created by Chester Hawkins on 3/31/18.
//  Copyright © 2018 Ojee Labs. All rights reserved.
//

import UIKit

class MazeViewController: UIViewController, UIScrollViewDelegate {
    var maze: Maze!
    @IBOutlet weak var mazePic: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var action: UIBarButtonItem!
    var userUpload = false
    var state: State = .Ready
    
    enum State: String {
        case Ready
        case SetStart
        case SetEnd
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizer()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name(rawValue: Globals.MazeGlobals.mazeUpdateNotif), object: nil)
        update(NSNotification(name: NSNotification.Name(rawValue: Globals.MazeGlobals.mazeUpdateNotif), object: ["maze": maze]))
        checkForUserUpload()
    }
    
    func checkForUserUpload() {
        if userUpload {
            action.isEnabled = false
            addMazeGesture()
            promptForStart()
        }
    }
    
    func promptForStart() {
        self.state = .SetStart
        let alert2 = UIAlertController(title: "Set Start Position", message: "Tap anywhere in the maze to set the start position", preferredStyle: UIAlertControllerStyle.actionSheet)
        let ok = UIKit.UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            
        })
        alert2.addAction(ok)
        self.present(alert2, animated: true, completion: nil)
    }
    
    func promptForEnd() {
        self.state = .SetEnd
        let alert2 = UIAlertController(title: "Set End Position", message: "Tap anywhere in the maze to set the end position", preferredStyle: UIAlertControllerStyle.actionSheet)
        let ok = UIKit.UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            
        })
        alert2.addAction(ok)
        self.present(alert2, animated: true, completion: nil)
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: mazePic)
        
        let point = mapPointThroughAspectFill(uiViewPoint: touchPoint)

        guard Int(point.x) >= 0, Int(point.x) < maze.pixelData!.columns, Int(point.y) >= 0, Int(point.y) < maze.pixelData!.rows else { return }
        
        switch state {
        case .SetStart:
            maze.setStart(pixelLoc: (Int(point.x),Int(point.y)))
            promptForEnd()
        case .SetEnd:
            maze.setEnd(pixelLoc: (Int(point.x),Int(point.y)))
            self.action.isEnabled = true
            removeMazeGesture()
        default: break
        }
    }
    
    func mapPointThroughAspectFill(uiViewPoint:CGPoint)->CGPoint
        // Maps a point from the coordinate space of our UIView into the space of the image
        // which AspectFills that UIView
    {
        let imageWidth = mazePic!.image!.size.width
        let imageHeight = mazePic!.image!.size.height
        let xScale = mazePic!.bounds.size.width / imageWidth
        let yScale = mazePic!.bounds.size.height / imageHeight
        var x, y,  o:CGFloat
        
        if (yScale>xScale) {
            // scale vertically from the center for height-pegged images
            o = (mazePic.bounds.size.height - (imageHeight*xScale))/2;
            x = uiViewPoint.x / xScale;
            y = (uiViewPoint.y-o) / xScale;
        } else {
            // scale horizontally from the center for width-pegged images
            o = (mazePic.bounds.size.width - (imageWidth*yScale))/2;
            x = (uiViewPoint.x-o) / yScale;
            y = uiViewPoint.y / yScale;
        }
        return CGPoint(x: x, y: y)
    }
    
    @objc func update(_ notification: NSNotification) {
        let dict = notification.object as! NSDictionary
        if let maze = dict["maze"] as? Maze {
            if maze.isEqualTo(self.maze) {
                DispatchQueue.main.async {
                    if self.maze.name != nil {
                        self.title = "\(String(describing: self.maze.name!)): \(self.maze.status)"
                    }
                    else {
                        self.title = "\(self.maze.status)"
                    }
                    switch self.maze.status {
                    case Maze.MazeStatus.Unsolved:
                        self.action.title = MazeCell.MazeAction.Solve.rawValue
                    case Maze.MazeStatus.Solving, Maze.MazeStatus.Solved, Maze.MazeStatus.Unsolvable:
                        self.action.title = MazeCell.MazeAction.Reset.rawValue
                    }
                    self.mazePic?.image = Helper.image(fromPixelValues: self.maze.pixelData?.getArray(), width: self.maze.pixelData!.columns, height: self.maze.pixelData!.rows)!
                }
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return self.mazePic
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MazeViewController.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 10.0
    }
    
    func addMazeGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        mazePic.isUserInteractionEnabled = true
        mazePic.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func removeMazeGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        mazePic.isUserInteractionEnabled = false
        mazePic.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @IBAction func handleMazeAction() {
        switch maze!.status {
        case Maze.MazeStatus.Unsolved:
            maze?.solve {}
        case Maze.MazeStatus.Solved, Maze.MazeStatus.Solving, Maze.MazeStatus.Unsolvable:
            maze?.reset()
            checkForUserUpload()
        }
    }
}
