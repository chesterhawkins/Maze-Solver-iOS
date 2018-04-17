//
//  MazeCell.swift
//  Maze Solver
//
//  Created by Chester Hawkins on 3/29/18.
//  Copyright © 2018 Ojee Labs. All rights reserved.
//

import UIKit

class MazeCell: UITableViewCell {
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var mazeDesc: UILabel?
    @IBOutlet weak var status: UILabel?
    @IBOutlet weak var mazePic: UIImageView?
    @IBOutlet weak var action: UIButton?
    var maze: Maze?
    
    enum MazeAction: String {
        case Solve
        case Reset
    }
}
