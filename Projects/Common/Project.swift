//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 홍은표 on 10/14/23.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Common",
    product: .staticFramework,
    dependencies: [
        .SPM.RxCocoa,
        .SPM.RxSwift
    ]
)
