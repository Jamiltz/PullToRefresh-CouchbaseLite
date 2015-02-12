//
//  TableViewController.swift
//  PullToRefresh+CouchbaseLite
//
//  Created by James Nocentini on 09/02/2015.
//  Copyright (c) 2015 James Nocentini. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var recipes: [String] = []
    var pull: CBLReplication!

    override func viewDidLoad() {
        super.viewDidLoad()

        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("startFilteredPullReplication"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        runQuery()
    }
    
    func runQuery() {
        let query = db.createAllDocumentsQuery()
        let result = query.run(nil)
        
        for row in result.allObjects as [CBLQueryRow] {
            if let properties = row.document.properties as? [String : AnyObject] {
                if let name = properties["title"] as? String {
                    recipes.append(name)
                }
            }
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = recipes[indexPath.row]
        
        return cell
    }
    
    func startFilteredPullReplication() {
        
        let url = NSURL(string: kSyncGateway)
        pull = db.createPullReplication(url)
        pull.channels = ["public_recipes"]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replicationChanged:", name: kCBLReplicationChangeNotification, object: pull)
        
        pull.start()
        
    }
    
    func replicationChanged(notification: NSNotification) {

        if pull.status == CBLReplicationStatus.Stopped {
            runQuery()
            refreshControl?.endRefreshing()
        } else if(pull.status == CBLReplicationStatus.Offline) {
            refreshControl?.endRefreshing()
        }
        
    }

}
