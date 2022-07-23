//
//  NSAttributedString.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import Foundation

extension NSAttributedString {
    func height(containerWidth: CGFloat) -> CGFloat {
        let rect = boundingRect(with: CGSize(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                context: nil)
        return ceil(rect.size.height)
    }

    func width(containerHeight: CGFloat) -> CGFloat {
        let rect = boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: containerHeight),
                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                context: nil)
        return ceil(rect.size.width)
    }
}
