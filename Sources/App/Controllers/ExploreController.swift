//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import HTTP

final class ExploreController {

    var droplet: Droplet!

    func addRoutes(droplet: Droplet) {
        self.droplet = droplet
        droplet.get(handler: self.explore)
        let explore = droplet.grouped("explore")
        explore.get(handler: self.explore)
        let search = explore.grouped("search")
        search.get(handler: self.search)
        let clap = droplet.grouped("clap")
        clap.post(handler: self.clap)
    }
    
    func clap(request: Request) throws -> ResponseRepresentable {
        let deviceId = request.formURLEncoded?["device_id"]?.string ?? ""
        let device = try Device.makeQuery().filter("id", deviceId).first()
        device?.clapsCount += 1
        try device?.save()
        return (try device?.makeResponse())!
    }

    func explore(request: Request) throws -> ResponseRepresentable {
        let queryCategory = request.query?["category"]?.string ?? ""
        let category = try Category.makeQuery().filter("name", queryCategory).first()

        // Get all categories and find out if one of them is selected.
        let categories = try Category.all().select(selected: queryCategory)

        let accessories: [Device]
        let pageTitle: String
        let pageIcon: String

        if let category = category {
            // Get all accessories for the selected category.
            accessories = try Device.makeQuery().filter("approved", true).filter("category_id", category.id!.string!).all()
            pageTitle = category.name
            pageIcon = category.image
        } else {
            // Get all accessories because no category was selected.
            accessories = try Device.makeQuery().filter("approved", true).all()
            pageTitle = "All Devices"
            pageIcon = ""
        }

        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "pageTitle": pageTitle.makeNode(in: nil),
            "pageIcon": pageIcon.makeNode(in: nil),
            "noAccessories": accessories.count == 0
        ])
        return try droplet.view.make("explore", nodes)
    }

    func search(request: Request) throws -> ResponseRepresentable {
        let search = request.query?["term"]?.string ?? ""

        // Only search through accessory and manufacturer name.
        let categories = try Category.all()
        let accessories = try Device.makeQuery().filter("approved", true).all().filter { accessory -> Bool in
            let manufacturerResult = try accessory.manufacturer.get()?.name.lowercased().contains(search) ?? false
            let nameResult = accessory.name.lowercased().contains(search)
            return manufacturerResult || nameResult
        }
        let pageTitle = "Search for \"\(search)\""
        let pageIcon = ""

        let nodes = try Node(node: [
            "categories": categories.makeNode(in: nil),
            "accessories": accessories.makeNode(in: nil),
            "pageTitle": pageTitle.makeNode(in: nil),
            "pageIcon": pageIcon.makeNode(in: nil),
            "noAccessories": accessories.count == 0
        ])
        return try droplet.view.make("explore", nodes)
    }
}
