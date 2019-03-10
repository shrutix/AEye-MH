//
//  ViewController.swift
//  AEye
//
//  Created by Shruti Jana on 3/9/19.
//  Copyright © 2019 SJ. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing image.")
        }
        guard let ciimage = CIImage(image: selectedImage) else {
                fatalError("Could not convert to CIImage")
            }
          //  photoImageView.image = selectedImage
           detect(image: ciimage)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed.")
        }
        let request = VNCoreMLRequest(model: model) { ( request, error ) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to process image.")
            }
           if let firstResult = results.first {
            //self.navigationItem.title = firstResult.identifier

                if firstResult.identifier.contains("orange"){
                    self.navigationItem.title = "orange"
                }
                else if firstResult.identifier.contains("bottle"){
                    self.navigationItem.title = "bottle"
                }
                else if firstResult.identifier.contains("pen"){
                    self.navigationItem.title = "pen"
                }
                else if firstResult.identifier.contains("watch"){
                    self.navigationItem.title = "watch"
                }
                else if firstResult.identifier.contains("cup"){
                    self.navigationItem.title = "cup"
                }
                else if firstResult.identifier.contains("feet"){
                    self.navigationItem.title = "feet"
                }
                else if firstResult.identifier.contains("person"){
                    self.navigationItem.title = "person"
                }
                else if firstResult.identifier.contains("woman"){
                    self.navigationItem.title = "woman"
                }
                else if firstResult.identifier.contains("man"){
                    self.navigationItem.title = "man"
                }
                else if firstResult.identifier.contains("shoe"){
                    self.navigationItem.title = "shoe"
                }
                else if firstResult.identifier.contains("backpack"){
                    self.navigationItem.title = "backpack"
                }
                else if firstResult.identifier.contains("laptop"){
                    self.navigationItem.title = "laptop"
                }
                else if firstResult.identifier.contains("apple"){
                    self.navigationItem.title = "apple"
                }
                else if firstResult.identifier.contains("toothbrush"){
                    self.navigationItem.title = "toothbrush"
                }
                else if firstResult.identifier.contains("wristband"){
                    self.navigationItem.title = "wristband"
                }
                else if firstResult.identifier.contains("fork"){
                    self.navigationItem.title = "fork"
                }
                else if firstResult.identifier.contains("spoon"){
                    self.navigationItem.title = "spoon"
                }
                else if firstResult.identifier.contains("donut"){
                    self.navigationItem.title = "donut"
                }
                else {
                    self.navigationItem.title = "try again"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image )
        
        do {
        try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
   lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        self.navigationItem.title = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
              let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.navigationItem.title = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.navigationItem.title = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "  (%.2f) %@", /*classification.confidence,*/ classification.identifier)
                }
                self.navigationItem.title = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

