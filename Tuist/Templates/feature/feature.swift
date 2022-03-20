import Foundation
import ProjectDescription

let authorName = "Mathew Gacy"

let companyName = "Mathew Gacy"

var defaultYear: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.string(from: Date())
}

var defaultDate: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.string(from: Date())
}

let nameAttribute: Template.Attribute = .required("name")
let authorAttribute: Template.Attribute = .optional("author", default: authorName)
let yearAttribute: Template.Attribute = .optional("year", default: defaultYear)
let dateAttribute: Template.Attribute = .optional("date", default: defaultDate)
let companyAttribute: Template.Attribute = .optional("company", default: companyName)

var items: [Template.Item] = [
    .file(path: "Targets/\(nameAttribute)/Sources/\(nameAttribute)Domain.swift", templatePath: "Domain.stencil"),
    .file(path: "Targets/\(nameAttribute)/Sources/\(nameAttribute)View.swift", templatePath: "View.stencil"),
    .file(path: "Targets/\(nameAttribute)/Tests/\(nameAttribute)DomainTests.swift", templatePath: "Tests.stencil"),
]


let template = Template(
    description: "Feature template",
    attributes: [
        nameAttribute,
        authorAttribute,
        yearAttribute,
        dateAttribute,
        companyAttribute,
        .optional("platform", default: "ios")
    ],
    items: items
)