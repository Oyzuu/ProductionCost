//
//  ExportModal.swift
//  ProductionCost
//
//  Created by BT-Training on 23/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import PKHUD
import SimplePDF
import FirebaseAuth

class ActionsModal: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var csvButton: UIButton!
    @IBOutlet weak var seeSuppliersButton: UIButton!
    
    // MARK: Properties
    
    var productToExport: Product!
    let userMail = FIRAuth.auth()?.currentUser?.email
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        addBlurredBackground(onView: view, withStyle: .Dark)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        addBlurredBackground(onView: view, withStyle: .Dark)
        
        seeSuppliersButton.withRoundedBorders()
        pdfButton.withRoundedBorders()
        csvButton.withRoundedBorders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SuppliersMap" {
            guard let navigationController = segue.destinationViewController as? UINavigationController,
                controller = navigationController.viewControllers[0] as? SuppliersMap else {
                    return
            }
            
            controller.product = productToExport
        }
    }
    
    // MARK: Methods
    
    @IBAction func exportToPDF(sender: AnyObject) {
        
        // Constants
        
        let width  = 595
        let height = 842
        let margin = 20
        let widthWithoutMargins = 595 - (margin * 2)
        
        let A4paperSize = CGSize(width: width, height: height)
        let pdf = SimplePDF(pageSize: A4paperSize, pageMargin: CGFloat(margin))
        
        let futura24 = UIFont(name: "Futura", size: 24)!
//        let avenir24 = UIFont(name: "Avenir", size: 24)!
        let avenir16 = UIFont(name: "Avenir", size: 16)!
        let avenir12 = UIFont(name: "Avenir", size: 12)!
        let avenir10 = UIFont(name: "Avenir", size: 10)!
        
        // Title
        
        pdf.setFont(futura24)
        pdf.addText(productToExport!.name)
        
        // User
        
        pdf.setFont(avenir12)
        pdf.addText("created by \(userMail!)")
        
        pdf.addLineSpace(5)
        pdf.addLineSeparator(height: 0.1)
        pdf.addLineSpace(15)
        
        // Components table
        
        let productData = generateData(fromProduct: productToExport, forFileType: ".pdf")
        
        pdf.addTable(productData.tableData.count,
                     columnCount: productData.columnCount,
                     rowHeight: 30,
                     columnWidth: CGFloat(widthWithoutMargins / productData.columnCount),
                     tableLineWidth: 0.5, font: avenir12,
                     dataArray: productData.tableData)
        
        // Suppliers list
        
        pdf.addLineSpace(15)
        pdf.setFont(avenir16)
        
        pdf.addAttributedText(NSAttributedString(string: "Suppliers", attributes: [
            NSFontAttributeName: avenir16,
            NSUnderlineStyleAttributeName: 1]))
        
        pdf.addLineSpace(15)
        
        pdf.setFont(avenir12)
        for supplier in productData.suppliers {
            pdf.addText(supplier.name)
            
            var addressString = ""
            
            if let address = supplier.address {
                addressString = address
            }
            else {
                addressString = "No address for this supplier"
            }
            
            pdf.addAttributedText(NSAttributedString(string: addressString, attributes: [
                NSForegroundColorAttributeName: UIColor.grayColor(),
                NSFontAttributeName: avenir10]))
            
            // commented until appropriate solution from image display
            
//            let filename = supplier.name
//                .stringByReplacingOccurrencesOfString(" ", withString: "") + ".png"
//            let filepath = getDocumentsDirectory() + filename
//            if let image = UIImage(contentsOfFile: filepath) {
//                pdf.addImage(image)
//            }
            
            pdf.addText("")
            
            pdf.addLineSpace(5)
        }
        
        // PDF file generation
        
        let pdfData = pdf.generatePDFdata()
        do {
            try pdfData.writeToFile(getDocumentsDirectory() + getFilename(".pdf"),
                                    options: .DataWritingAtomic)
            HUD.flash(.LabeledSuccess(title: nil,
                subtitle: "Exported to documents"), delay: 1) { result in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        catch {
            HUD.flash(.LabeledError(title: nil, subtitle: "Error"), delay: 1)
        }
    }
    
    @IBAction func exportToCSV(sender: AnyObject) {
        let productData = generateData(fromProduct: productToExport, forFileType: ".csv")
        var dataString = ""
        for row in productData.tableData {
            for element in row {
                dataString += element
                dataString += element == row.last ? "" : ";"
            }
            
            dataString += "\n"
        }
        
        let data = dataString.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            try data!.writeToFile(getDocumentsDirectory() + getFilename(".csv"),
                                  options: .DataWritingAtomic)
            HUD.flash(.LabeledSuccess(title: nil,
                subtitle: "Exported to documents"), delay: 1) { result in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        catch {
            HUD.flash(.LabeledError(title: nil, subtitle: "Error"), delay: 1)
        }
    }
    
    private func generateData(fromProduct product: Product, forFileType type: String) ->
        (tableData: [[String]], columnCount: Int, suppliers: Set<Supplier>) {
        var suppliers = Set<Supplier>()
        var dataArray = [[String]]()
        let titles = ["Name", "Quantity", "Category", "Supplier", "Price"]
        dataArray.append(titles)
        
        print(productToExport.components.count)
        
        for materialWithModifier in productToExport.components {
            let material = materialWithModifier.material!
            let modifier = materialWithModifier.modifier
            
            if let supplier = material.supplier where !suppliers.contains(supplier) {
                suppliers.insert(supplier)
            }
            
            print("tick")
            dataArray.append(material.asArray(withModifier: modifier, forFileType: type))
        }
        
        let total = ["", "", "", "TOTAL :", String(format: "%.2f $", productToExport.price)]
        dataArray.append(total)
        
        return (dataArray, titles.count, suppliers)
    }
    
    private func getFilename(withExtension: String) -> String {
        var filename = "\(productToExport.name)"
        if let userMail = self.userMail {
            filename += " by \(userMail)"
        }
        
        return filename + withExtension
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
