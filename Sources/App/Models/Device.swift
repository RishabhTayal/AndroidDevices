//
//  Copyright © 2017 Patrick Balestra. All rights reserved.
//

import Vapor
import FluentProvider

final class Device: Model {

    static var entity = "device"

    let storage = Storage()
    
    var id: Node?
    var categoryId: Identifier
    var manufacturerId: Identifier

    var name: String
    var image: String
    var price: String
    var productLink: String
    var viewsCount: Int
    var clapsCount: Int
    var approved: Bool

    var category: Parent<Device, Category> {
        return parent(id: categoryId)
    }

    var manufacturer: Parent<Device, Manufacturer> {
        return parent(id: manufacturerId)
    }

    init(name: String, image: String, price: String, productLink: String, category: Identifier, manufacturer: Identifier, approved: Bool = false, viewsCount: Int = 0, clapsCount: Int = 0) {
        self.name = name
        self.categoryId = category
        self.manufacturerId = manufacturer
        self.image = image
        self.price = price
        self.productLink = productLink
        self.approved = approved
        self.viewsCount = viewsCount
        self.clapsCount = clapsCount
    }

    init(row: Row) throws {
        id = try row.get("id")
        name = try row.get("name")
        image = try row.get("image")
        price = try row.get("price")
        productLink = try row.get("product_link")
        viewsCount = try row.get("views_count")
        clapsCount = try row.get("claps_count")
        approved = try row.get("approved")
        manufacturerId = try row.get("manufacturer_id")
        categoryId = try row.get("category_id")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("category_id", categoryId)
        try row.set("name", name)
        try row.set("image", image)
        try row.set("price", price)
        try row.set("product_link", productLink)
        try row.set("manufacturer_id", manufacturerId)
        try row.set("views_count", viewsCount)
        try row.set("claps_count", clapsCount)
        try row.set("approved", approved)
        return row
    }
}

extension Device: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "image": image,
            "price": price,
            "product_link": productLink,
            "manufacturer": manufacturer.get()?.name,
            "manufacturer_link": manufacturer.get()?.directLink,
            "manufacturer_website": manufacturer.get()?.websiteLink,
            "category_id": categoryId.string!,
            "views_count": viewsCount,
            "claps_count": clapsCount
        ])
    }
}

extension Device: ResponseRepresentable {

    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("id", id)
        try json.set("category_id", categoryId)
        try json.set("name", name)
        try json.set("image", image)
        try json.set("price", price)
        try json.set("product_link", productLink)
        try json.set("manufacturer_id", manufacturerId)
        try json.set("views_count", viewsCount)
        try json.set("claps_count", clapsCount)
        try json.set("approved", approved)
        return try json.makeResponse()
    }
}

extension Device: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Category.self)
            builder.parent(Manufacturer.self)
            builder.string("name")
            builder.string("image")
            builder.string("price")
            builder.string("product_link")
            builder.int("views_count")
            builder.int("claps_count")
            builder.bool("approved")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(Device.self)
    }
}
