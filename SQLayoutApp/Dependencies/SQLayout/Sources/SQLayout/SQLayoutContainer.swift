//
//  SQLayoutContainer.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
//  (c)2023 All Rights Reserved
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

    public var arrangedItems: [SQLayoutItem] = []
    public let maxDimension: CGFloat = 10000    // clip fitting sizes to reasonable values to prevent overflows
    public static var debugEnabled = false
    private static var nestLevel = 0

    // Lays out all arranged items and returns the bounding
    // rectangle that contains all of their content rects.
    @discardableResult
    public func layoutItems(in bounds: CGRect, with insets: UIEdgeInsets, forSizingOnly: Bool) -> CGRect {
        var bounds = bounds

        bounds.size.width = min(maxDimension, bounds.width)
        bounds.size.height = min(maxDimension, bounds.height)

        let container = SQContainerDescription(layoutBounds: bounds, layoutInsets: insets)
        var previous: SQPreviousItemDescription?
        var previousToPrevious: SQPreviousItemDescription?
        var occupiedBounds = CGRect.zero
        var debugPrefix = ""

        // Print debug info if debugging enabled
        if SQLayoutContainer.debugEnabled {
            SQLayoutContainer.nestLevel += 1
            debugPrefix = String(Array(repeating: " ", count: SQLayoutContainer.nestLevel * 3))
            print("\(debugPrefix)Layout container: bounds=\(bounds) inset=\(insets) forSizing: \(forSizingOnly)")
        }

        //
        // Loop thru all arranged items
        //
        for item in arrangedItems {
            let options = item.sq_layoutOptionsCalculator?(SQLayoutOptionsCalculatorArgs(item: item, container: container)) ?? SQLayoutOptions()

            guard !options.shouldSkipLayout else { continue }

            if SQLayoutContainer.debugEnabled {
                print("\(debugPrefix)   ┌─ item: \(String(describing: item.sq_rootItem))")
                SQLayoutContainer.nestLevel += 1
            }

            // Calculate spacing, padding, frame
            let spacing = item.sq_spacingCalculator?(SQSpacingCalculatorArgs(item: item, container: container)) ?? .zero
            let padding = item.sq_paddingCalculator?(SQPaddingCalculatorArgs(item: item, container: container)) ?? .zero
            let frameCalculator = (forSizingOnly ? item.sq_sizingFrameCalculator : nil) ?? item.sq_frameCalculator ?? SQLayoutCalculators.containerLeftAlignedVStack
            let frame = frameCalculator(SQFrameCalculatorArgs(item: item, padding: padding, spacing: spacing, container: container, previous: previous, previousToPrevious: previousToPrevious, forSizingOnly: forSizingOnly))

            // Call layout observer with generated frame
            item.sq_layoutObserver?(SQLayoutObserverArgs(item: item, frame: frame, forSizingOnly: forSizingOnly))

            // Update occupied bounds
            if !options.shouldIgnoreWhenCalculatingSize {
                let occupiedFrame = CGRectMake(
                    CGRectGetMinX(frame) - padding.left,
                    CGRectGetMinY(frame) - padding.top,
                    CGRectGetWidth(frame) + padding.left + padding.right,
                    CGRectGetHeight(frame) + padding.top + padding.bottom)
                if occupiedBounds.isEmpty {
                    occupiedBounds = occupiedFrame
                } else if !frame.isEmpty {
                    occupiedBounds = CGRectUnion(occupiedBounds, occupiedFrame)
                }
            }

            if SQLayoutContainer.debugEnabled {
                print("\(debugPrefix)   └─ frame: frame=\(frame) occupiedBounds=\(occupiedBounds)")
                SQLayoutContainer.nestLevel -= 1
            }

            // Update "previous" variable for next item
            if options.saveAsPrevious {
                previousToPrevious = previous
                previous = SQPreviousItemDescription(item: item, contentBounds: frame, spacing: spacing, padding: padding)
            }
        }
        if SQLayoutContainer.debugEnabled {
            SQLayoutContainer.nestLevel -= 1
        }
        return occupiedBounds
    }
}
