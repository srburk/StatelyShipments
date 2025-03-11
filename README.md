![StateShipmentsUI](https://github.com/user-attachments/assets/c1d5587f-50d8-4597-a815-fa54154d3384)

# Stately Shipments

The objective of this project was to develop an iOS app in Objective-C with UIKit. It should take in 2 states as input and calculate the cheapest shipping route along the contiguous United States. The government has imposed a fee on crossing state borders that I allow the user to set, and the fuel cost from state to state can vary and requires a 3rd-party API to get access.

## Architecture Breakdown

### States

U.S. States were modeled in a simple Objective-C class `State`. Instances of this class stored information about the state, like its name, state code, coordinates, and references to neighboring states.

The `StatesLoader` utility class builds `State` objects from a local plist in the app bundle. The app's `StatesLoader` instance keeps references to all states in an alphabetically sorted array and a state-code indexed dictionary called `allStatesGraph`.

### ShippingCostService

The `ShippingCostService` class is responsible for finding the shortest path between 2 arbitrary `State` objects. We can view the problem as a weighted graph problem where `allStatesGraph` represents the graph organized in an adjacency list. We can use [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm) to solve these kinds of problems. I built a [Priority Queue](https://en.wikipedia.org/wiki/Priority_queue) using a [Min-Heap](https://en.wikipedia.org/wiki/Min-max_heap) data structure to achieve fast access times.

First, we need to get the weights, or fuel cost + state border crossing fee, from the API. We can access that information with this function defined in the problem statement:

`float FuelCostBetweenNeighborStates(State *stateA, State *stateB);`

Unfortunately, this is a blocking call with a 3-second response timeout. We can save some time by first calling the other given function to check if the road is usable:

`BOOL IsRoadUsableBetweenNeighborStates(State *stateA, State *stateB);`

If it's not usable, we can avoid fetching the fuel cost. We still need to get the cost for the usable roads, so calling the first function is unavoidable. Calling this on the main thread would freeze up the application and make it unresponsive. A better solution would be to use a threading model like [Grand Central Dispatch (GCD)](https://developer.apple.com/documentation/dispatch?language=objc). The entire implementation of Dijkstra's algorithm runs on a background thread to avoid blocking the main thread. 

To avoid data races on the cached fuel costs, the `ShippingCostService` defines a custom dispatch_group and dispatch_queue purely for cached fuel access. These reads and writes are carefully protected to preserve the correct app state.

The `ShippingCostService` instance needs to let the rest of the application know that a calculation has completed. To accomplish this, I defined a delegate protocol called `ShippingCostServiceDelegate`. Classes conforming to this protocol can respond to success and fail states presented by the `ShippingCostService`.

### MainCoordinator

The app uses the `MainCoordinator` class to manage global app state and view transitions. References to the selected `State` objects ViewControllers are invoked by the `MainCoordinator` and store a weak reference to it for method calls. Following the coordinator pattern allows for clear separation of business logic and user interface logic.

### UI Code

I opted for code-defined UI instead of storyboards to preserve git history and because I enjoy seeing immediately in Xcode's text editor why the renderer is drawing a view a certain way.
The app uses 4 ViewControllers for each of the distinct UIs:

* `MainViewController` is the root view controller and manages MKMapView management and modal navigation view presentation.
* `ShippingEntryViewController` provides UI for entering source/destination states and government fee input.
* `StatePickerViewController` is for searching and selecting `State` objects.
* `ShippingRouteViewController` is for presenting the completed route information from the `ShippingCostService`.

Keeping these separate ensures a clear separation of concerns and easier maintenance.

These views encapsulate specific UI elements to keep the view controllers lean: `GovernmentFeeInputView`, `StatePickerButton`, `ShippingRouteCellView`, `ShippingRouteHeaderView`

### Error Handling

Errors are primarily encountered in the `ShippingCostService` class and must be handled appropriately. The service halts operation and delivers a message to be displayed over the navigation drawer. This is delivered to the `MainCoordinator` with the delegate protocol of the `ShippingCostService`.

## Design

Because this is a simple app, I thought the UI shoud be kept simple and clean. A busy UI would distract from the primary purpose of the app.

![Simulator Screen Recording - iPhone 16 Pro - 2025-03-11 at 17 29 02](https://github.com/user-attachments/assets/328a80b3-cc80-4c95-a4bf-db752b58aff4)

## Development Process

### Tests

#TODO Finish this section
I built a "dummy" implementation of the 3rd-party API callers to give back random information throughout the testing process. 

I built tests externally using Python for loading.

### Wireframe UI

After brainstorming on UI layout, I built mockups with a new app I encountered called [frame0](https://frame0.app). Incorporating a MapView was important to me because it is a helpful visual communicator for an app that doesn't need a lot of space for its controls.

![wireframe](https://github.com/user-attachments/assets/8994d821-c958-4ab4-827b-0d5657ca5083)

## Work-In-Progress UI (3/6/25)

![screenshots](https://github.com/user-attachments/assets/8ed5a025-3e74-493c-a921-8270d8ff4089)
