//
//  OnboardingPageVC.swift
//  Bestie
//
//  Created by Nicholas Naudé on 28/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {
    
    //    weak var tutorialDelegate: TutorialPageViewControllerDelegate?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newPageViewController("OnboardOne"),
            self.newPageViewController("OnboardTwo"),
            self.newPageViewController("OnboardThree")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        view?.backgroundColor = UIColor.bestiePurple()
        //        dataSource = self
        //        delegate = self
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                viewControllerAfterViewController: visibleViewController) {
                    scrollToViewController(nextViewController)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                return orderedViewControllers.first
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    
    private func newPageViewController(nameFor: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(nameFor)ViewController")
    }
    
    private func scrollToViewController(viewController: UIViewController) {
        setViewControllers([viewController],
            direction: .Forward,
            animated: true,
            completion: { (finished) -> Void in
        })
    }
}
