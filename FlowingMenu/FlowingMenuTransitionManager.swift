/*
 * FlowingMenu
 *
 * Copyright 2015-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

public final class FlowingMenuTransitionManager: NSObject {
  enum AnimationMode {
    case Presentation
    case Dismissal
  }

  var animationMode: AnimationMode = .Presentation
  let duration = 0.2

  private func presentMenu(menuView: UIView, otherView: UIView, containerView: UIView, completion: () -> Void) {
    let ov = otherView.snapshotViewAfterScreenUpdates(true)

    containerView.addSubview(ov)
    containerView.addSubview(menuView)

    var menuFrame        = menuView.frame
    menuFrame.size.width = 250
    menuFrame.origin.x   = -250
    menuView.frame       = menuFrame

    UIView.animateWithDuration(duration, delay: 0, options: [], animations: { () -> Void in
      menuFrame.origin.x = 0
      menuView.frame     = menuFrame

      otherView.alpha = 0
      ov.alpha        = 0.4
      }) { _ in
        completion()
    }
  }

  private func dismissMenu(menuView: UIView, otherView: UIView, containerView: UIView, completion: () -> Void) {
    let ov = otherView.snapshotViewAfterScreenUpdates(true)

    var menuFrame = menuView.frame

    containerView.addSubview(otherView)
    containerView.addSubview(ov)
    containerView.addSubview(menuView)

    otherView.alpha = 0
    ov.alpha        = 0.4

    UIView.animateWithDuration(duration, delay: 0, options: [.CurveEaseOut], animations: { () -> Void in
      menuFrame.origin.x = -menuFrame.width
      menuView.frame     = menuFrame

      otherView.alpha = 1
      ov.alpha        = 1
      }) { _ in
        completion()
    }
  }
}

extension FlowingMenuTransitionManager: UIViewControllerAnimatedTransitioning {
  public func animateTransition(context: UIViewControllerContextTransitioning) {
    let fromVC = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC   = context.viewControllerForKey(UITransitionContextToViewControllerKey)!

    let containerView = context.containerView()!
    let menuView      = animationMode == .Presentation ? toVC.view : fromVC.view
    let otherView     = animationMode == .Presentation ? fromVC.view : toVC.view

    let action = animationMode == .Presentation ? presentMenu : dismissMenu

    action(menuView, otherView: otherView, containerView: containerView) {
      context.completeTransition(!context.transitionWasCancelled())
    }
  }

  public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return duration
  }
}