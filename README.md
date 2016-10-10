# FlickTransition
A iOS UIViewController Transition
## Screenshot

![screenshot](https://github.com/NjrSea/FlickTransition/blob/master/Screenshot.gif)

## Installation & Usage

Install via [CocoaPods](http://cocoapods.org) by adding this to your Podfile:

```ruby
pod 'FlickTransition'
```

Then import to your swift file
```swift
import FlickTransition
```
For instance, present a view controller in a tableview controller:

```swift
var rect = tableView.rectForRowAtIndexPath(indexPath)
rect = tableView.convertRect(rect, toView: view)
FlickTransitionCoordinator.sharedCoordinator.presentViewController(WebViewController(), presentOriginFrame: rect)
```

Dismiss a view controller:

```swift
FlickTransitionCoordinator.sharedCoordinator.dismissViewControllerNoninteractively()
```
Note that view controller to be presented needs ot implement FlickTransitionDelegate to get interactive transition feature.

##Demo

Run the example projects, from the *workspace* to play with the library.
