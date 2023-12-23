//
//  UIFont+.swift
//  DesignSystem
//
//  Created by 홍은표 on 12/23/23.
//  Copyright © 2023 com.hongkim. All rights reserved.
//

import UIKit

public extension UIFont {
    static var h1: UIFont { .jejuMyeongjo(.h1) }
    static var h2: UIFont { .jejuMyeongjo(.h2) }
    static var body1: UIFont { .jejuMyeongjo(.body1) }
    static var body2: UIFont { .jejuMyeongjo(.body2) }
    static var body3: UIFont { .jejuMyeongjo(.body3) }
    static var caption: UIFont { .jejuMyeongjo(.caption) }
}

fileprivate extension UIFont {
    static func jejuMyeongjo(_ size: FontSize) -> UIFont {
        DesignSystemFontFamily.JejuMyeongjoOTF.regular.font(size: size.rawValue)
    }
}

fileprivate enum FontSize: CGFloat {
    case h1 = 36
    case h2 = 20
    case body1 = 18
    case body2 = 16
    case body3 = 14
    case caption = 12
}
