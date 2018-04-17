//
//  SolvedMazeViewController.swift
//  Maze Solver
//
//  Created by Chester Hawkins on 3/31/18.
//  Copyright © 2018 Ojee Labs. All rights reserved.
//

import UIKit

class SolvedMazeViewController: UIViewController, UIScrollViewDelegate {
    var maze: Maze!
    @IBOutlet weak var mazePic: UIImageView?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var action: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 10.0
        setupGestureRecognizer()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name(rawValue: Globals.MazeGlobals.mazeUpdateNotif), object: nil)
        update(NSNotification(name: NSNotification.Name(rawValue: Globals.MazeGlobals.mazeUpdateNotif), object: ["maze": maze]))
    }
    
    @objc func update(_ notification: NSNotification) {
        let dict = notification.object as! NSDictionary
        if let maze = dict["maze"] as? Maze {
            if maze.isEqualTo(self.maze) {
                DispatchQueue.main.async {
                    self.title = "\(self.maze.name): \(self.maze.status)"
                    switch self.maze.status {
                    case Maze.MazeStatus.Unsolved, Maze.MazeStatus.Unsolvable:
                        self.action.title = MazeCell.MazeAction.Solve.rawValue
                    case Maze.MazeStatus.Solving, Maze.MazeStatus.Solved:
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
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(SolvedMazeViewController.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
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
        case Maze.MazeStatus.Unsolved, Maze.MazeStatus.Unsolvable:
            maze?.solve {}
        case Maze.MazeStatus.Solved, Maze.MazeStatus.Solving:
            maze?.reset()
        }
    }
}
