//
//  SQLayoutContainer.swift
//  SLKit
//
//  Created by Vince Lee on 2/6/23.
//

import UIKit

///
/// Class that performs layout for arranged items
///
@objc
public class SQLayoutContainer: NSObject {
    public var arrangedItems: [SQLayoutItem] = []

    // Lays out all arranged items and returns the bounding
    // rectangle that contains all of their content rects.
    @discardableResult
    public func layoutItems(in bounds: CGRect, with insets: UIEdgeInsets, forSizingOnly: Bool) -> CGRect {
        let container = SQContainerDescription(layoutBounds: bounds, layoutInsets: insets)
        var previous: SQPreviousItemDescription?
        var occupiedBounds = CGRect.zero
        
        for item in arrangedItems {
            let options = item.sq_layoutOptionsCalculator(SQLayoutOptionsCalculatorArgs(item: item, container: container))
            
            guard !options.shouldSkipLayout else { continue }
            
            let contentSpacing = item.sq_contentSpacingCalculator(SQContentSpacingCalculatorArgs(item: item, container: container))
            let contentPadding = item.sq_contentPaddingCalculator(SQContentPaddingCalculatorArgs(item: item, container: container))
            let frame = item.sq_frameCalculator(SQFrameCalculatorArgs(item: item, contentPadding: contentPadding, contentSpacing: contentSpacing, container: container, previous: previous, forSizingOnly: forSizingOnly))

            // Call layout observer with generated frame
            item.sq_layoutObserver(SQLayoutObserverArgs(item: item, frame: frame, forSizingOnly: forSizingOnly))
            
            // Update occupied bounds
            if !options.shouldIgnoreWhenCalculatingSize {
                if occupiedBounds.isEmpty {
                    occupiedBounds = frame
                } else if !frame.isEmpty {
                    occupiedBounds = CGRectUnion(occupiedBounds, frame)
                }
            }
            
            // Update previous
            if options.saveAsPrevious {
                previous = SQPreviousItemDescription(item: item, contentBounds: frame, contentSpacing: contentSpacing, contentPadding: contentPadding)
            }
        }

        return occupiedBounds
    }
}
