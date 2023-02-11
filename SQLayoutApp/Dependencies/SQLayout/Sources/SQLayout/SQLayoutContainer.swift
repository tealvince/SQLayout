//
//  SQLayoutContainer.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
//

import UIKit

///
/// Class that performs layout for arranged items and returns the
/// "occupied bounds" of the laid out objects
///
/// ````
/// ┌──────────────────────────────┐
/// │  ┌────────────────────────┐  │
/// │  │ ┌────┐─────────────┐   │  │
/// │  │ │    │             │────────── Occupied bounds
/// │  │ │    │        ┌────┐   │  │
/// │  │ └────┘        │    │   │ ───── Layout insets
/// │  │ │             └────┘   │  │
/// │  │ │   ┌──────┐       │   │  │─── Layout bounds
/// │  │ └───└──────┘───────┘   │  │
/// │  │                        │  │
/// │  │                        │  │
/// │  └────────────────────────┘  │
/// └──────────────────────────────┘
///
@objcMembers
public class SQLayoutContainer: NSObject {
    static var nestLevel = 0
    public var arrangedItems: [SQLayoutItem] = []
    public let maxDimension: CGFloat = 10000    // clip fitting sizes to reasonable values to prevent overflows
    
    // Lays out all arranged items and returns the bounding
    // rectangle that contains all of their content rects.
    @discardableResult
    public func layoutItems(in bounds: CGRect, with insets: UIEdgeInsets, forSizingOnly: Bool) -> CGRect {
        var bounds = bounds

        bounds.size.width = min(maxDimension, bounds.width)
        bounds.size.height = min(maxDimension, bounds.height)

        let container = SQContainerDescription(layoutBounds: bounds, layoutInsets: insets)
        var previous: SQPreviousItemDescription?
        var occupiedBounds = CGRect.zero

        SQLayoutContainer.nestLevel += 1
        let debugPrefix = String(Array(repeating: " ", count: SQLayoutContainer.nestLevel * 3))
        print("\(debugPrefix)Layout container: bounds=\(bounds) inset=\(insets)")
        
        for item in arrangedItems {
            let options = item.sq_layoutOptionsCalculator(SQLayoutOptionsCalculatorArgs(item: item, container: container))
            
            guard !options.shouldSkipLayout else { continue }

            print("\(debugPrefix)   ┌─ item: \(String(describing: item.sq_rootItem))")
            SQLayoutContainer.nestLevel += 1

            let contentSpacing = item.sq_contentSpacingCalculator(SQContentSpacingCalculatorArgs(item: item, container: container))
            let contentPadding = item.sq_contentPaddingCalculator(SQContentPaddingCalculatorArgs(item: item, container: container))
            let frame = item.sq_frameCalculator(SQFrameCalculatorArgs(item: item, contentPadding: contentPadding, contentSpacing: contentSpacing, container: container, previous: previous, forSizingOnly: forSizingOnly))

            // Call layout observer with generated frame
            item.sq_layoutObserver(SQLayoutObserverArgs(item: item, frame: frame, forSizingOnly: forSizingOnly))

            // Update occupied bounds
            if !options.shouldIgnoreWhenCalculatingSize {
                let occupiedFrame = CGRectMake(
                    CGRectGetMinX(frame) - contentPadding.left,
                    CGRectGetMinY(frame) - contentPadding.top,
                    CGRectGetWidth(frame) + contentPadding.left + contentPadding.right,
                    CGRectGetHeight(frame) + contentPadding.top + contentPadding.bottom)
                if occupiedBounds.isEmpty {
                    occupiedBounds = occupiedFrame
                } else if !frame.isEmpty {
                    occupiedBounds = CGRectUnion(occupiedBounds, occupiedFrame)
                }
            }

            print("\(debugPrefix)   └─ frame: frame=\(frame) occupiedBounds=\(occupiedBounds)")
            SQLayoutContainer.nestLevel -= 1

            // Update previous
            if options.saveAsPrevious {
                previous = SQPreviousItemDescription(item: item, contentBounds: frame, contentSpacing: contentSpacing, contentPadding: contentPadding)
            }
        }
        SQLayoutContainer.nestLevel -= 1

        return occupiedBounds
    }
}
