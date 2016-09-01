//
//  NeighboursViewController.swift
//  SwiftJSON&XMLParse
//
//  Created by maisapride8 on 13/07/16.
//  Copyright © 2016 maisapride8. All rights reserved.
//

import UIKit

class NeighboursViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate
{

    @IBOutlet weak var tableView: UITableView!
    
    var geonameID: Int!
    var xmlParser:  NSXMLParser!
    var foundValue = String()
    var currentElement = String()
    var neigbhoursDataArray = [AnyObject]()
    var tempDataStorageDict = [String: AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Download the neigbour countries data.
       downloadNeighbourCountries()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Private functions.
    func downloadNeighbourCountries(){
        //Prepare the url that we will get the neigbourcountries from.
        let URLString = "http://api.geonames.org/neighbours?geonameId=\(geonameID)&username=\(kUsername)"
        let URL = NSURL(string: URLString)!
        print(URL)
        //Download the data.
        AppDelegate.downloadDataFromURL(URL, completion:  { [weak self] (responseData) -> Void in
            //make sure that there is a data.
            if let responseData = responseData {
               self?.xmlParser = NSXMLParser(data: responseData)
                self?.xmlParser.delegate = self
                
                //Initialize the mutablestring that we will use during parsing.
                self?.foundValue = String()
                
                //Start parsing
                self?.xmlParser.parse()
            }
        })
    }
    //MARK: NSXMLParser Delegate methods.
    func parserDidStartDocument(parser: NSXMLParser) {
        //Initalize the neigbours data array.
        neigbhoursDataArray = [AnyObject]()
    }
    func parserDidEndDocument(parser: NSXMLParser) {
        //when parsing has been finished relaod the tableview
        tableView.reloadData()
    }
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print(parseError.localizedDescription)
    }
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        //If current name is equal to "geoname" then initialize the temporary dictionary.
        if elementName == "geoname" {
            tempDataStorageDict = [String: AnyObject]()
        }
        currentElement = elementName
    }
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "geoname":
            //If the closing element equals to "geoname" then all the data of a neighbour country has been parsed and the dictionary should be added to the neighbours data
            neigbhoursDataArray += [tempDataStorageDict]
        case "name":
            //If the country name element was found then store it.
            tempDataStorageDict["name"] = foundValue
        case "toponymName":
            //If toponymname was found then store it.
            tempDataStorageDict["toponymName"] = foundValue
        default:
            break
        }
        //Clear the mutablestring
        foundValue = ""
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        //Store the found characters if only we are intrested in the current element.
        if currentElement == "name" || currentElement == "toponymName" {
            if !(string == "\n"){
               foundValue += string
                print("found \(foundValue)")
            }
        }
    }
    
    
    //MARK: TableView Methods.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(neigbhoursDataArray.count)
        return neigbhoursDataArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
            cell!.accessoryType = .None
            cell!.selectionStyle = .None
        }
        
        let neighbour = neigbhoursDataArray[indexPath.row] as! [String : AnyObject]
        cell?.textLabel?.text = neighbour["name"] as? String
        cell?.detailTextLabel?.text = neighbour["toponymName"] as? String
        
        print(cell!)
        return cell!
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    
    
    
    
    
    
    
    
}
