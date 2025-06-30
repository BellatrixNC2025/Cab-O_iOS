//
//  PreviewHelper.swift
//  CabO
//
//  Created by Octos.
//

import SwiftUI
import UIKit

struct PreviewContainer<T: UIViewController>: UIViewControllerRepresentable {

    let viewController: T
    
    init(_ viewControllerBuilder: @escaping () -> T) {
        viewController = viewControllerBuilder()
    }
    
    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> T {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) {}
}
