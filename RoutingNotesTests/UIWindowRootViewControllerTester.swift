//
//  UIWindowRootViewControllerTester.swift
//  RoutingNotesTests
//
//  Created by Sergi Hernanz on 28/12/2018.
//  Copyright © 2018 Sergi Hernanz. All rights reserved.
//

import XCTest
import UIKit

class UIWindowRootViewControllerTester<T: UIViewController> {

    private(set) var rootWindow: UIWindow

    init(viewController: T) {
        rootWindow = UIWindow(frame: UIScreen.main.bounds)
        rootWindow.isHidden = false
        rootWindow.rootViewController = viewController
        viewController.loadView()
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)
    }

    func tearDown() {
        guard let rootViewController = rootWindow.rootViewController as? T else {
            XCTFail("UIWindowRootViewControllerTester tearDown called twice ?")
            return
        }
        rootViewController.viewWillDisappear(false)
        rootViewController.viewDidDisappear(false)
        rootWindow.rootViewController = nil
        rootWindow.isHidden = true
    }
}

extension UIView {

    func orders_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image!
        }
        XCTAssert(false)
        return UIImage()
    }
}

extension UIView {

    func flatSelfAndAllSubviews() -> [UIView] {
        var mutableViews = [UIView]()
        mutableViews.append(self)
        for subview in self.subviews {
            mutableViews += subview.flatSelfAndAllSubviews()
        }
        return mutableViews
    }

    func allLabels(text:String) -> [UILabel] {
        return self.flatSelfAndAllSubviews().filter { (view:UIView) -> Bool in
            guard let label = view as? UILabel else {
                return false
            }
            guard let txt = label.text else {
                return false
            }
            return txt.isEqual(text)
            } as! [UILabel]
    }

    func allButtons(text:String) -> [UIButton] {
        return self.flatSelfAndAllSubviews().filter { (view:UIView) -> Bool in
            guard let button = view as? UIButton else {
                return false
            }
            guard let title = button.title(for: .normal) else {
                return false
            }
            return title.isEqual(text)
            } as! [UIButton]
    }
}
