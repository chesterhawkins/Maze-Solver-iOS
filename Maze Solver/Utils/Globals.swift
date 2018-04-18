//
//  Globals.swift
//  Maze Solver
//
//  Created by Chester Hawkins on 4/13/18.
//  Copyright © 2018 Ojee Labs. All rights reserved.
//

struct Globals {
    //Struct to represent RGBA pixel info
    struct Pixel {
        var value: (UInt8,UInt8,UInt8,UInt8)
        var red: UInt8 {
            get { return value.0 }
            set { value = (newValue,value.1,value.2,value.3) }
        }
        var green: UInt8 {
            get { return value.1 }
            set { value = (value.0,newValue,value.2,value.3) }
        }
        var blue: UInt8 {
            get { return value.2 }
            set { value = (value.0,value.1,newValue,value.3) }
        }
        var alpha: UInt8 {
            get { return value.3 }
            set { value = (value.0,value.1,value.2,newValue) }
        }
        static var white: (UInt8, UInt8, UInt8, UInt8) = (255,255,255,255)
        static var green: (UInt8, UInt8, UInt8, UInt8)  = (0,255,0,255)
    }
}
