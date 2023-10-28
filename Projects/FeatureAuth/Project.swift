//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by 홍은표 on 10/14/23.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Auth",
    product: .staticFramework,
    dependencies: [
		.SPM.FirebaseAuth,
		.SPM.FirebaseFirestore
    ],
    sources: ["Scene/**"]
)
