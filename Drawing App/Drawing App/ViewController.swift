//
//  ViewController.swift
//  Drawing App
//
//  Created by JPK5090 on 2021-03-04.
//

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    
    var toolPicker: PKToolPicker!
    
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500

    var drawing = PKDrawing();

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true

        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = .anyInput
            toolPicker = PKToolPicker()
        } else {
            canvasView.allowsFingerDrawing = true
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        canvasView.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x:0, y: -canvasView.adjustedContentInset.top)

    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
    }

    func updateContentSizeForDrawing(){
        let drawing = canvasView.drawing
        let contentHeight : CGFloat

        if !drawing.bounds.isNull{
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + self.canvasOverscrollHeight) * canvasView.zoomScale)
        }else{
            contentHeight = canvasView.bounds.height
        }

        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale,
                                        height: contentHeight)
    }

    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }

    @IBAction func toogleFingerOrPencil(_ sender:Any){

        if #available(iOS 14.0, *) {
            pencilFingerButton.title = canvasView.drawingGestureRecognizer.isEnabled ? "Finger" : "Pencil"
            canvasView.drawingGestureRecognizer.isEnabled = !canvasView.drawingGestureRecognizer.isEnabled
        }else{
            pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
            canvasView.allowsFingerDrawing.toggle()
        }
    }

    @IBAction func takeDrawingToCameraRoll(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)

        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if image != nil{
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            } completionHandler: { (success, error) in
                //dealing with results
            }

        }
    }

}
