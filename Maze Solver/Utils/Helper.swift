//
//  Helper.swift
//  Maze Solver
//
//  Created by Chester Hawkins on 4/13/18.
//  Copyright © 2018 Ojee Labs. All rights reserved.
//

import UIKit

class Helper {
    //Convert array of Pixels to UIImage
    class func image(fromPixelValues pixelValues: [Globals.Pixel]?, width: Int, height: Int) -> UIImage?
    {
        if var pixelValues = pixelValues {
            let bitmapCount: Int = pixelValues.count
            let bitsPerComponent = 8
            let bytesPerPixel = 4
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let render: CGColorRenderingIntent = CGColorRenderingIntent.defaultIntent
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
            let providerRef: CGDataProvider? = CGDataProvider(data: NSData(bytes: &pixelValues, length: bitmapCount * bytesPerPixel))
            let cgimage: CGImage? = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: true, intent: render)
            if cgimage != nil
            {
                return UIImage(cgImage: cgimage!)
            }
        }
        
        return nil
    }
}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UIImage {
    //Convert CGImage to  array of Pixels (R,G,B)
    func pixelData() -> [Globals.Pixel]? {
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage!.bitsPerComponent,
                                bytesPerRow: cgImage!.bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        var arr: [Globals.Pixel] = []
        
        for pixel in stride(from: 0, to: pixelData.count, by: 4) {
            let p = Globals.Pixel(value: (pixelData[pixel],pixelData[pixel+1],pixelData[pixel+2],pixelData[pixel+3]))
            arr.append(p)
        }
        return arr
    }
}
