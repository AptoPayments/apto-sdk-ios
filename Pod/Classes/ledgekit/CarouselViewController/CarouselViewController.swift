//
//  CarouselViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 08/03/16.
//
//

import UIKit

class CarouselViewcontroller: ShiftViewController {

  var nextPageIndex = 0
  var currentPageIndex = 0 {
    didSet {
      self.viewControllerShown(self.currentPageIndex)
    }
  }

  let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
  var viewControllers: [UIViewController] = [] {
    didSet {
      guard let firstVC = self.viewControllers.first else {
        return
      }
      self.pageViewController.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
      self.viewControllerShown(0)
    }
  }

  override func viewDidLoad() {
    self.edgesForExtendedLayout = UIRectEdge()
    self.extendedLayoutIncludesOpaqueBars = true
    self.addChildViewController(pageViewController)
    pageViewController.didMove(toParentViewController: self)
    self.view.addSubview(pageViewController.view)
    pageViewController.view.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(self.view)
    }
    pageViewController.dataSource = self
    pageViewController.delegate = self
  }

  func showNextViewController() {
    guard (currentPageIndex + 1) < viewControllers.count else {
      return
    }
    let vcs = viewControllers[currentPageIndex + 1]
    pageViewController.setViewControllers([vcs], direction: .forward, animated: true, completion: nil)
    currentPageIndex = currentPageIndex + 1
  }

  func showPreviousViewController() {
    guard currentPageIndex > 0 else {
      return
    }
    let vcs = viewControllers[currentPageIndex - 1]
    pageViewController.setViewControllers([vcs], direction: .reverse, animated: true, completion: nil)
    currentPageIndex = currentPageIndex - 1
  }

  func viewControllerShown(_ index:Int) {}

}

extension CarouselViewcontroller: UIPageViewControllerDataSource {

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = self.viewControllers.index(of: viewController) else {
      return nil
    }
    let previousIndex = viewControllerIndex - 1
    guard previousIndex >= 0 else {
      return nil
    }
    guard self.viewControllers.count > previousIndex else {
      return nil
    }
    return self.viewControllers[previousIndex]
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = self.viewControllers.index(of: viewController) else {
      return nil
    }
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = self.viewControllers.count
    guard orderedViewControllersCount != nextIndex else {
      return nil
    }
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    return self.viewControllers[nextIndex]
  }

}

extension CarouselViewcontroller: UIPageViewControllerDelegate {

  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    nextPageIndex = indexFor(viewController:pendingViewControllers.first!)
  }

  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if !finished { return }
    currentPageIndex = nextPageIndex
  }

  func indexFor(viewController : UIViewController) -> Int {
    var index = 0
    for vc in self.viewControllers {
      if vc == viewController {
        break
      }
      index = index + 1
    }
    return index
  }

}
