//
//  FMPhotoPickerImageCollectionViewLayout.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/23.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMPhotoPickerImageCollectionViewLayout: UICollectionViewFlowLayout {
    let numberOfColumns: CGFloat = 3
    let padding: CGFloat = 1
    
    override init() {
        super.init()
        self.minimumInteritemSpacing = self.padding
        self.minimumLineSpacing = self.padding
        let itemSizeW = (UIScreen.main.bounds.size.width - ((self.numberOfColumns - 1) * self.padding)) / numberOfColumns
        self.itemSize = CGSize(width: itemSizeW, height: itemSizeW)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
