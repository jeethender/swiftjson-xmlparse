//
//  ViewController.swift
//  SwiftJSON&XMLParse
//
//  Created by maisapride8 on 13/07/16.
//  Copyright © 2016 maisapride8. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate
{
    
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryInfoTV: UITableView!
    
    var countriesArray = [String]()
    var countriesCodesArray = [String]()
    var countryCode: String?
    var countryDetailsDictionary = [String: AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initially hide the table view.
        self.countryInfoTV.hidden = true
        
        //Load the contents of the two .txt files to the arrays.
        if let pathOfCountriesFile = NSBundle.mainBundle().pathForResource("countries", ofType: "txt"){
            let allCountries = try? String(contentsOfFile: pathOfCountriesFile, encoding:  NSUTF8StringEncoding)
            countriesArray = allCountries!.componentsSeparatedByString("\n")
        }
        
        if let pathOfCountriesCode = NSBundle.mainBundle().pathForResource("countries_short", ofType: "txt"){
            let allCountriesCodes = try? String(contentsOfFile: pathOfCountriesCode, encoding: NSUTF8StringEncoding)
            countriesCodesArray = allCountriesCodes!.componentsSeparatedByString("\n")
        }
        
    }
    //MARK: UITextFieldDelegate method implementation.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Find the index of the typed country in the arrcountries arry.
        let filteredArray = countriesArray.filter {
            return $0.rangeOfString(self.countryTextField.text!.uppercaseString) != nil
        }
        //Check if the given country was found.
        if let country = filteredArray.first{
            //Get the two letter country code from arrcountryCodes array.
            self.countryCode = countriesCodesArray[countriesArray.indexOf(country)!]
            
            
            //Download the country info
            fetchCountryInfo()
            
        } else{
            // If country was not found show the alert message.
            UIAlertView(title: "Alert", message: "Country not found", delegate:  nil, cancelButtonTitle: nil,otherButtonTitles: "Done").show()
        }
        //Hide the keyboard
        countryTextField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Private functions
    private func fetchCountryInfo() {
        // Prepare the URL that we'll get the country info data from.
        let URLString = "http://api.geonames.org/countryInfoJSON?username=\(kUsername)&country=\(countryCode!)"
        let URL = NSURL(string: URLString)
        
        print("1URL: \(URLString)")
        
        
        AppDelegate.downloadDataFromURL(URL!, completion: { [weak self] (responseData) -> Void in
            
            // Check if any data returned.
            if let responseData = responseData {
                // Convert the returned data into a dictionary.
                var error: NSError?
                do {
                    let responseDictionary: AnyObject = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers)
                    
                              print("2Response dictionary: \(responseDictionary)")
                    
                    if let geonames: AnyObject = responseDictionary["geonames"] {
                        self?.countryDetailsDictionary = geonames[0] as! [String: AnyObject]
                        
                             print("3countryDetailsDictionary: \(self?.countryDetailsDictionary)")
                        
                        // Set the country name to the respective label.
                        let countryName = self?.countryDetailsDictionary["countryName"] as! String
                        let countryCode = self?.countryDetailsDictionary["countryCode"] as! String
                        self?.countryLabel.text = String(format: "\(countryName)      (\(countryCode))")
                        
                        // Reload the table view.
                        self?.countryInfoTV.reloadData()
                        self?.countryInfoTV.hidden = false
                    }
                } catch let error1 as NSError {
                    error = error1
                    print("\(error?.localizedDescription)")
                } catch {
                    fatalError()
                }
            }
            })
    }
    
    //MARK: TableView methods.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
            cell!.accessoryType = .None
            cell!.selectionStyle = .None
        }
        switch indexPath.row {
        case 0:
            cell?.detailTextLabel?.text = "Capital"
            if let capital = countryDetailsDictionary["capital"] as? String {
                cell?.textLabel?.text = capital
            }
        case 1:
            cell?.detailTextLabel?.text = "Continent"
            if let continent = countryDetailsDictionary["continentName"] as? String{
                cell?.textLabel?.text = continent
            }
        case 2:
            cell?.detailTextLabel?.text = "Population"
            if let population = countryDetailsDictionary["population"] as? String{
                cell?.textLabel?.text = population
            }
        case 3:
            cell?.detailTextLabel?.text = "Area In Square Km"
            if let areaInSqKm = countryDetailsDictionary["areaInSqKm"] as? String {
                cell?.textLabel?.text = areaInSqKm
            }
        case 4:
            cell?.detailTextLabel?.text = "Currency"
            if let currency = countryDetailsDictionary["currencyCode"] as? String{
                cell?.textLabel?.text = currency
            }
        case 5:
            cell?.detailTextLabel?.text = "Languages"
            if let languages = countryDetailsDictionary["languages"] as? String{
                cell?.textLabel?.text = languages
            }
        case 6:
            cell?.detailTextLabel?.text = "Neighbour Countries"
            cell!.accessoryType = .DisclosureIndicator;
            cell!.selectionStyle = .None;
        default:
            break
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 6 {
            performSegueWithIdentifier("idSegueNeighbours", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    //MARK: IBAction compose mail method.
    @IBAction func sendJSON(sender: UIBarButtonItem) {
        //Create the dictionary only the values we need.
        let emailDictionary = ["countryName": countryDetailsDictionary["countryName"] as! String,
                               "countryCode": countryDetailsDictionary["countryCode"] as! String,
                               "capital": countryDetailsDictionary["capital"] as! String,
                               "continent": countryDetailsDictionary["continent"] as! String,
                               "population": countryDetailsDictionary["population"] as! String,
                               "areaInSqKm": countryDetailsDictionary["areaInSqKm"] as! String,
                               "currencyCode": countryDetailsDictionary["currencyCode"] as! String,
                               "languages": countryDetailsDictionary["languages"] as! String
        ]
        
        //Convert the dictionary into JSON data object.
        let JSONData = try? NSJSONSerialization.dataWithJSONObject(emailDictionary, options: NSJSONWritingOptions.PrettyPrinted)
        let JSONString = NSString(data: JSONData!, encoding: NSUTF8StringEncoding)
        
        print("\(JSONString)")
        
        if MFMailComposeViewController.canSendMail() {
            let mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            
            mailViewController.setSubject("Country JSON")
            mailViewController.setMessageBody(JSONString as! String , isHTML: false)
            
            presentViewController(mailViewController, animated: true, completion: nil)
        }
    }
    //MARK: MailcomposecontrollerDelegate.
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if let error = error{
            print("\(error.localizedDescription)")
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "idSegueNeighbours" {
            let neighboursViewController = segue.destinationViewController as! NeighboursViewController
            neighboursViewController.geonameID = countryDetailsDictionary["geonameId"] as! Int
        }
    }
}

