//
//  ViewController.swift
//  Maze Solver
//
//  Created by Chester Hawkins on 3/29/18.
//  Copyright © 2018 Ojee Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mazeViewChanger: UISegmentedControl!
    @IBOutlet weak var mazeTable: UITableView!
    var visibleMazes: [Maze] = []
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mazeTable.delegate = self
        mazeTable.dataSource = self
        picker.delegate = self
        picker.allowsEditing = false
        picker.modalPresentationStyle = .popover
        picker.popoverPresentationController?.barButtonItem = navigationController?.navigationBar.topItem?.leftBarButtonItem
        NotificationCenter.default.addObserver(self, selector: #selector(loadTable), name: NSNotification.Name(rawValue: Globals.MazeGlobals.mazeUpdateNotif), object: nil)
        Helper.MazeHelper.fetchAllMazes()
    }
    
    @IBAction func getMazeImage(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "", message: "Choose a maze from your photo library or take a new photo.", preferredStyle: UIAlertControllerStyle.actionSheet)
        let fromLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            self.photofromLibrary()
        })
        let camera = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
            self.photoFromCamera()
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
            
        })
        alert.popoverPresentationController?.barButtonItem = navigationController?.navigationBar.topItem?.leftBarButtonItems?.first
        alert.addAction(fromLibrary)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func photofromLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func photoFromCamera() {
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashMode.auto
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.dismiss(animated: true) {
                let solvedMaze = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "solvedmaze") as? MazeViewController
                solvedMaze?.maze = Maze(newMaze: nil, description: nil, url: nil, image: image, shape: nil)
                solvedMaze?.userUpload = true
                self.show(solvedMaze!, sender: nil)
            }
        }
        else {
            self.dismiss(animated: true, completion: {

            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = mazeTable.indexPathForSelectedRow{
            mazeTable.deselectRow(at: index, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleMazes.count
    }
    
    @IBAction func solveAllMazes() {
        Helper.MazeHelper.solveAllMazes()
    }
    
    @IBAction func resetAllMazes() {
        Helper.MazeHelper.resetAllMazes()
    }
    
    @IBAction func fetchAllMazes() {
        Helper.MazeHelper.fetchAllMazes()
    }
    
    @IBAction func cameraTapped() {
    }
    
    @objc func loadTable() {
        DispatchQueue.main.async {
            self.visibleMazes.removeAll()
            for maze in Globals.MazeGlobals.allMazes {
                switch self.mazeViewChanger.selectedSegmentIndex {
                case 0:
                    if maze.shape == .Rectangular {
                        self.visibleMazes.append(maze)
                    }
                case 1:
                    if maze.shape == .Circular {
                        self.visibleMazes.append(maze)
                    }
                case 2:
                    if maze.shape == .Triangular {
                        self.visibleMazes.append(maze)
                    }
                case 3:
                    if maze.shape == .Hexagonal {
                        self.visibleMazes.append(maze)
                    }
                default:
                    break
                }
            }
            self.mazeTable.reloadData()
        }
    }
    
    @IBAction func changeShapes() {
        loadTable()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maze") as! MazeCell
        let row = visibleMazes.count - (indexPath as NSIndexPath).row - 1;
        
        if row < visibleMazes.count  {
            let maze = visibleMazes[row]
            cell.name?.text = maze.name
            cell.mazeDesc?.text = maze.description
            cell.mazePic?.image = maze.image
            cell.status?.text = maze.status.rawValue
            cell.maze = maze
            switch maze.status {
            case Maze.MazeStatus.Unsolved, Maze.MazeStatus.Unsolvable:
                cell.status?.textColor = UIColor.red
                cell.action?.setTitle(MazeCell.MazeAction.Solve.rawValue, for: UIControlState.normal)
            case Maze.MazeStatus.Solving:
                cell.status?.textColor = UIColor.orange
                cell.action?.setTitle(MazeCell.MazeAction.Reset.rawValue, for: UIControlState.normal)
            case Maze.MazeStatus.Solved:
                cell.status?.textColor = UIColor.green
                cell.action?.setTitle(MazeCell.MazeAction.Reset.rawValue, for: UIControlState.normal)
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(handleMazeAction))
            cell.action?.addGestureRecognizer(tapGestureRecognizer)
        }
        
        return cell
    }
    
    @objc func handleMazeAction(_ sender: UITapGestureRecognizer) {
        if sender.view!.isKind(of: UIButton.self) {
            if let indexPath = mazeTable!.indexPathForRow(at: sender.location(in: mazeTable)) {
                //we could even get the cell from the index, too
                let cell = mazeTable!.cellForRow(at: indexPath) as! MazeCell
                switch cell.maze!.status {
                case Maze.MazeStatus.Unsolved, Maze.MazeStatus.Unsolvable:
                    cell.maze?.solve {}
                case Maze.MazeStatus.Solved, Maze.MazeStatus.Solving:
                    cell.maze?.reset()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = visibleMazes.count - (indexPath as NSIndexPath).row - 1;
        let maze = visibleMazes[row]
        
        let solvedMaze = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "solvedmaze") as? MazeViewController
        solvedMaze?.maze = maze
        self.show(solvedMaze!, sender: nil)
    }
}

