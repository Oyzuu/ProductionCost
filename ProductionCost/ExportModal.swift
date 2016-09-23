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

class ExportModal: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var csvButton: UIButton!
    
    // MARK: Properties
    
    var productToExport: Product!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addBlurredBackground(onView: view, withStyle: .Dark)
        
        pdfButton.withRoundedBorders()
        csvButton.withRoundedBorders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let avenir24 = UIFont(name: "Avenir", size: 24)!
        let avenir16 = UIFont(name: "Avenir", size: 16)!
        let avenir12 = UIFont(name: "Avenir", size: 12)!
        let avenir10 = UIFont(name: "Avenir", size: 10)!
        var suppliers = Set<Supplier>() // Will be populated in the table creation loop and used later
        
        // Title
        
        pdf.setFont(futura24)
        pdf.addText(productToExport!.name)
        
        // User
        
        let userMail = FIRAuth.auth()?.currentUser?.email
        pdf.setFont(avenir12)
        pdf.addText("created by \(userMail!)")
        
        pdf.addLineSpace(5)
        pdf.addLineSeparator(height: 0.1)
        pdf.addLineSpace(15)
        
        // Components table
        
        var dataArray = [[String]]()
        let titles = ["Name", "Quantity", "Category", "Supplier", "Price"]
        dataArray.append(titles)
        
        for modifiedComponent in productToExport.components {
            let material = modifiedComponent.material!
            let modifier = modifiedComponent.modifier
            suppliers.insert(material.supplier!)
            
            dataArray.append(material.asArray(withModifier: modifier))
        }
        
        let total = ["", "", "", "TOTAL :", String(format: "%.2f $", productToExport.price)]
        dataArray.append(total)
        
        pdf.addTable(dataArray.count,
                     columnCount: titles.count,
                     rowHeight: 30,
                     columnWidth: CGFloat(widthWithoutMargins / titles.count),
                     tableLineWidth: 0.5, font: avenir12,
                     dataArray: dataArray)
        
        // Suppliers list
        pdf.addLineSpace(15)
        pdf.setFont(avenir16)
        
        pdf.addAttributedText(NSAttributedString(string: "Suppliers", attributes: [
            NSFontAttributeName: avenir16,
            NSUnderlineStyleAttributeName: 1]))
        
        pdf.addLineSpace(15)
        
        pdf.setFont(avenir12)
        for supplier in suppliers {
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
            
        }
        
        // PDF file generation
        
        let pdfData = pdf.generatePDFdata()
        do {
            try pdfData.writeToFile(getDocumentsDirectory() + "test.pdf", options: .DataWritingAtomic)
            HUD.flash(.LabeledSuccess(title: nil, subtitle: "Exported to documents"), delay: 1) {
                result in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        catch {
            HUD.flash(.LabeledError(title: nil, subtitle: "Error"), delay: 1)
        }
        
    }
    
    @IBAction func exportToCSV(sender: AnyObject) {
        HUD.flash(.LabeledError(title: nil, subtitle: "Not implemented yet"), delay: 1)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
