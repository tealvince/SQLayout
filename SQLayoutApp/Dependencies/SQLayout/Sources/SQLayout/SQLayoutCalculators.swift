//
//  SQLayoutCalculators.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
//

import UIKit

///
/// An assortment of useful reusable convenience frame calculators.
/// Can often be used instead of defining a custom calculator for an item.
///
@objcMembers
public class SQLayoutCalculators: NSObject {
    
    // MARK: - Public (origin)
    
    /// ````
    /// ┌────────┐───────────────────┐
    /// │ curr   │                   │
    /// └────────┘                   │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    ///  Place item at origin at size fit for container layout area
    ///
    public static func origin(_ args: SQFrameCalculatorArgs) -> CGRect {
        let fittingSize = itemFittingSizeForContainer(args.container, padding: args.contentPadding)
        let size = args.item.sq_sizeCalculator(SQSizeCalculatorArgs(item: args.item, container: args.container, fittingSize: fittingSize))
        
        return CGRectMake(0, 0, size.width, size.height)
    }
    
    // MARK: - Public (Container VStack)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌────────┐                │
    /// │  │ prev   │                │
    /// │  └────────┘                │
    /// │  ┌──────────────┐          │
    /// │  │ curr         │          │
    /// │  └──────────────┘          │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous along the left edge of the container bounds
    ///
    public static func containerLeftAlignedVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerLeft(args, rect: alignBelowPrevious(args, rect: origin(args)))
    }
    public static func containerLeftAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerLeft(args, rect: alignAbovePrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                ┌────────┐  │
    /// │                │ prev   │  │
    /// │                └────────┘  │
    /// │          ┌──────────────┐  │
    /// │          │ curr         │  │
    /// │          └──────────────┘  │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous along the right edge of the container bounds
    ///
    public static func containerRightAlignedVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerRight(args, rect: alignBelowPrevious(args, rect: origin(args)))
    }
    public static func containerRightAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerRight(args, rect: alignAbovePrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │         ┌────────┐         │
    /// │         │ prev   │         │
    /// │         └────────┘         │
    /// │      ┌──────────────┐      │
    /// │      │ curr         │      │
    /// │      └──────────────┘      │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous along the x centerline of the container bounds
    ///
    public static func containerCenterAlignedVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterX(args, rect: alignBelowPrevious(args, rect: origin(args)))
    }
    public static func containerCenterAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterX(args, rect: alignAbovePrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌──────────────────────┐  │
    /// │  │ prev                 │  │
    /// │  └──────────────────────┘  │
    /// │  ┌──────────────────────┐  │
    /// │  │ curr                 │  │
    /// │  └──────────────────────┘  │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous stretched to the full width of the container bounds
    ///
    public static func containerWidthVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerRight(args, rect: containerLeftAlignedVStack(args))
    }
    public static func containerWidthVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerRight(args, rect: containerLeftAlignedVStackUp(args))
    }
    
    // MARK: - Public (Previous VStack)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │         ┌────────┐         │
    /// │         │ prev   │         │
    /// │         └────────┘         │
    /// │         ┌──────────────┐   │
    /// │         │ curr         │   │
    /// │         └──────────────┘   │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous aligned on the left edge
    ///
    public static func leftAlignedVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousLeft(args, rect: alignBelowPrevious(args, rect: origin(args)))
    }
    public static func leftAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousLeft(args, rect: alignAbovePrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │         ┌────────┐         │
    /// │         │ prev   │         │
    /// │         └────────┘         │
    /// │   ┌──────────────┐         │
    /// │   │ curr         │         │
    /// │   └──────────────┘         │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous aligned on the right edge
    ///
    public static func rightAlignedVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousRight(args, rect: alignBelowPrevious(args, rect: origin(args)))
    }
    public static func rightAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousRight(args, rect: alignAbovePrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │       ┌────────┐           │
    /// │       │ prev   │           │
    /// │       └────────┘           │
    /// │    ┌──────────────┐        │
    /// │    │ curr         │        │
    /// │    └──────────────┘        │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous along their centerlines
    ///
    public static func centerAlignedVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterX(args, rect: alignBelowPrevious(args, rect: origin(args)))
    }
    public static func centerAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterX(args, rect: alignAbovePrevious(args, rect: origin(args)))
    }
    
    // MARK: - Public (Container HStack)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌───────┐ ┌───────┐       │
    /// │  │ prev  │ │ curr  │       │
    /// │  └───────┘ │       │       │
    /// │            └───────┘       │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item to right of the previous along the top edge of the container bounds
    ///
    public static func containerTopAlignedHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerTop(args, rect: alignRightOfPrevious(args, rect: origin(args)))
    }
    public static func containerTopAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerTop(args, rect: alignLeftOfPrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │            ┌───────┐       │
    /// │  ┌───────┐ │ curr  │       │
    /// │  │ prev  │ │       │       │
    /// │  └───────┘ └───────┘       │
    /// └────────────────────────────┘
    ///
    /// Place an item to right of the previous along the bottom edge of the container bounds
    ///
    public static func containerBottomAlignedHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerBottom(args, rect: alignRightOfPrevious(args, rect: origin(args)))
    }
    public static func containerBottomAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerBottom(args, rect: alignLeftOfPrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │            ┌───────┐       │
    /// │  ┌───────┐ │ curr  │       │
    /// │  │ prev  │ │       │       │
    /// │  └───────┘ │       │       │
    /// │            └───────┘       │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item to right of the previous along the centerline of the container bounds
    ///
    public static func containerCenterAlignedHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: alignRightOfPrevious(args, rect: origin(args)))
    }
    public static func containerCenterAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: alignLeftOfPrevious(args, rect: origin(args)))
    }
    
    // MARK: - Public (Previous HStack)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌───────┐ ┌───────┐       │
    /// │  │ prev  │ │ curr  │       │
    /// │  └───────┘ │       │       │
    /// │            └───────┘       │
    /// └────────────────────────────┘
    ///
    /// Place an item to right of the previous along their top edges
    ///
    public static func topAlignedHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: alignRightOfPrevious(args, rect: origin(args)))
    }
    public static func topAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: alignLeftOfPrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │            ┌───────┐       │
    /// │  ┌───────┐ │ curr  │       │
    /// │  │ prev  │ │       │       │
    /// │  └───────┘ └───────┘       │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item to right of the previous along the bottom edge of the container bounds
    ///
    public static func bottomAlignedHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: alignRightOfPrevious(args, rect: origin(args)))
    }
    public static func bottomAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: alignLeftOfPrevious(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │            ┌───────┐       │
    /// │  ┌───────┐ │ curr  │       │
    /// │  │ prev  │ │       │       │
    /// │  └───────┘ │       │       │
    /// │            └───────┘       │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item to right of the previous along the centerline of the container bounds
    ///
    public static func centerAlignedHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: alignRightOfPrevious(args, rect: origin(args)))
    }
    public static func centerAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: alignLeftOfPrevious(args, rect: origin(args)))
    }
    
    // MARK: - Public (Fill)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │   ┌───────┐ ┌───────────┐  │
    /// │   │ prev  │ │ curr      │  │
    /// │   └───────┘ │           │  │
    /// │             └───────────┘  │
    /// └────────────────────────────┘
    ///
    /// Place an item filling the space between the previous item and container edge
    ///
    public static func topAlignedFillToRight(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerRight(args, rect: alignToPreviousTop(args, rect: containerCroppedRightOfPrevious(args)))
    }
    public static func topAlignedFillToLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerLeft(args, rect: alignToPreviousTop(args, rect: containerCroppedLeftOfPrevious(args)))
    }
    public static func bottomAlignedFillToRight(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerRight(args, rect: alignToPreviousBottom(args, rect: containerCroppedRightOfPrevious(args)))
    }
    public static func bottomAlignedFillToLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerLeft(args, rect: alignToPreviousBottom(args, rect: containerCroppedLeftOfPrevious(args)))
    }
    public static func centerAlignedFillToRight(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerRight(args, rect: alignToPreviousCenterY(args, rect: containerCroppedRightOfPrevious(args)))
    }
    public static func centerAlignedFillToLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return extendToContainerLeft(args, rect: alignToPreviousCenterY(args, rect: containerCroppedLeftOfPrevious(args)))
    }

    // MARK: - Public (Match)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌──────────────────────┐  │
    /// │  │ curr                 │  │
    /// │  │                      │  │
    /// │  │                      │  │
    /// │  │                      │  │
    /// │  │                      │  │
    /// │  └──────────────────────┘  │
    /// └────────────────────────────┘
    ///
    /// Match container layout area
    ///
    public static func matchContainer(_ args: SQFrameCalculatorArgs) -> CGRect {
        let l = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left + args.contentPadding.left
        let r = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right - args.contentPadding.right
        let t = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top + args.contentPadding.top
        let b = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom - args.contentPadding.bottom
        
        return CGRect(x: l, y: t, width: r-l, height: b-t)
    }
    public static func matchContainerFullBleed(_ args: SQFrameCalculatorArgs) -> CGRect {
        let l = CGRectGetMinX(args.container.layoutBounds) + args.contentPadding.left
        let r = CGRectGetMaxX(args.container.layoutBounds) - args.contentPadding.right
        let t = CGRectGetMinY(args.container.layoutBounds) + args.contentPadding.top
        let b = CGRectGetMaxY(args.container.layoutBounds) - args.contentPadding.bottom
        
        return CGRect(x: l, y: t, width: r-l, height: b-t)
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌─────────────────┐       │
    /// │  │ prev == curr    │       │
    /// │  └─────────────────┘       │
    /// └────────────────────────────┘
    ///  Match previous item bounds
    public static func matchPrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        guard let previous = args.previous else { return matchContainer(args) }
        
        let l = CGRectGetMinX(previous.contentBounds) - previous.contentPadding.left + args.contentPadding.left
        let r = CGRectGetMaxX(previous.contentBounds) + previous.contentPadding.right - args.contentPadding.right
        let t = CGRectGetMinY(previous.contentBounds) - previous.contentPadding.top + args.contentPadding.top
        let b = CGRectGetMaxY(previous.contentBounds) + previous.contentPadding.bottom - args.contentPadding.bottom
        
        return CGRect(x: l, y: t, width: r-l, height: b-t)
    }
    
    // MARK: - Public (Corner/Center aligned)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │         ┌───────┐          │
    /// │         │ curr  │          │
    /// │         └───────┘          │
    /// │                            │
    /// └────────────────────────────┘
    public static func containerCenterAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: alignToContainerCenterX(args, rect: origin(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌───────┐                 │
    /// │  │ curr  │                 │
    /// │  └───────┘                 │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    public static func containerTopLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerTop(args, rect: alignToContainerLeft(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                 ┌───────┐  │
    /// │                 │ curr  │  │
    /// │                 └───────┘  │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    public static func containerTopRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerTop(args, rect: alignToContainerRight(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │                            │
    /// │  ┌───────┐                 │
    /// │  │ curr  │                 │
    /// │  └───────┘                 │
    /// └────────────────────────────┘
    public static func containerBottomLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerBottom(args, rect: alignToContainerLeft(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │                            │
    /// │                 ┌───────┐  │
    /// │                 │ curr  │  │
    /// │                 └───────┘  │
    /// └────────────────────────────┘
    public static func containerBottomRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerBottom(args, rect: alignToContainerRight(args, rect: origin(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌──────────┐              │
    /// │  │ ┌──────┐ │              │
    /// │  │ │ curr │ │              │
    /// │  │ └──────┘ │ prev         │
    /// │  └──────────┘              │
    /// │                            │
    /// └────────────────────────────┘
    public static func centerAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: alignToPreviousCenterX(args, rect: origin(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌───────┐─┐               │
    /// │  │ curr  │ │               │
    /// │  └───────┘ │               │
    /// │  │ prev    │               │
    /// │  └─────────┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func topLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: alignToPreviousLeft(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌─┌───────┐               │
    /// │  │ │ curr  │               │
    /// │  │ └───────┘               │
    /// │  │ prev    │               │
    /// │  └─────────┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func topRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: alignToPreviousRight(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌─────────┐               │
    /// │  │ prev    │               │
    /// │  ┌───────┐ │               │
    /// │  │ curr  │ │               │
    /// │  └───────┘─┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func bottomLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: alignToPreviousLeft(args, rect: origin(args)))
    }
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌─────────┐               │
    /// │  │ prev    │               │
    /// │  │ ┌───────┐               │
    /// │  │ │ curr  │               │
    /// │  └─└───────┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func bottomRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: alignToPreviousRight(args, rect: origin(args)))
    }
    
    // MARK: - Public (Flow)
    
    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌───────┐ ┌───────┐       │
    /// │  │ prev1 │ │ prev2 │       │
    /// │  └───────┘ └───────┘       │
    /// │  ┌──────────────┐          │
    /// │  │ curr         │          │
    /// │  └──────────────┘          │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Attempt to place item to right of previous, else below if it doesn't fit.
    /// Note: should be used primarily for items of similar or increasing heights
    ///
    public static func topAlignedFlow(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = topAlignedHStack(args)
        if CGRectGetMaxX(rect) + args.contentPadding.right > CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right {
            rect = containerLeftAlignedVStack(args)
        }
        return rect
    }
    public static func bottomAlignedFlow(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = bottomAlignedHStack(args)
        if CGRectGetMaxX(rect) + args.contentPadding.right > CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right {
            rect = containerLeftAlignedVStack(args)
        }
        return rect
    }
    public static func centerAlignedFlow(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = centerAlignedHStack(args)
        if CGRectGetMaxX(rect) + args.contentPadding.right > CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right {
            rect = containerLeftAlignedVStack(args)
        }
        return rect
    }
    
    // MARK: - Restricted to part of container on one side of previous

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌───────┐                 │
    /// │  │ curr  │ ┌───────┐       │
    /// │  │       │ │ prev  │       │
    /// │  │       │ └───────┘       │
    /// │  │       │                 │
    /// │  │       │                 │
    /// │  └───────┘                 │
    /// │                            │
    /// └────────────────────────────┘
    ///
    public static func containerCroppedLeftOfPrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        guard let previous = args.previous else { return matchContainer(args) }

        let l = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left
        let r = CGRectGetMinX(previous.contentBounds) - previous.contentPadding.left - max(previous.contentSpacing.left, args.contentSpacing.right)
        let t = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top
        let b = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom

        let fittingSize = itemFittingSizeForSize(CGSizeMake(r - l, b - t), padding: args.contentPadding)
        let size = args.item.sq_sizeCalculator(SQSizeCalculatorArgs(item: args.item, container: args.container, fittingSize: fittingSize))
        return CGRectMake(t + args.contentPadding.top, l + args.contentPadding.left, r - l - args.contentPadding.left - args.contentPadding.right, size.height)
    }

    public static func containerCroppedRightOfPrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        guard let previous = args.previous else { return matchContainer(args) }

        let l = CGRectGetMaxX(previous.contentBounds) + previous.contentPadding.right + max(previous.contentSpacing.right, args.contentSpacing.left)
        let r = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right
        let t = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top
        let b = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom

        let fittingSize = itemFittingSizeForSize(CGSizeMake(r - l, b - t), padding: args.contentPadding)
        let size = args.item.sq_sizeCalculator(SQSizeCalculatorArgs(item: args.item, container: args.container, fittingSize: fittingSize))
        return CGRectMake(t + args.contentPadding.top, l + args.contentPadding.left, r - l - args.contentPadding.left - args.contentPadding.right, size.height)
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌──────────────────────┐  │
    /// │  │                      │  │
    /// │  │       curr           │  │
    /// │  │                      │  │
    /// │  └──────────────────────┘  │
    /// │            ┌───────┐       │
    /// │            │ prev  │       │
    /// │            └───────┘       │
    /// └────────────────────────────┘
    ///
    public static func containerCroppedAbovePrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        guard let previous = args.previous else { return matchContainer(args) }

        let t = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top
        let b = CGRectGetMinY(previous.contentBounds) - previous.contentPadding.top - max(previous.contentSpacing.top, args.contentSpacing.bottom)
        let l = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left
        let r = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right

        let fittingSize = itemFittingSizeForSize(CGSizeMake(r - l, b - t), padding: args.contentPadding)
        let size = args.item.sq_sizeCalculator(SQSizeCalculatorArgs(item: args.item, container: args.container, fittingSize: fittingSize))
        return CGRectMake(t + args.contentPadding.top, l + args.contentPadding.left, size.width, b - t - args.contentPadding.top - args.contentPadding.bottom)
    }

    public static func containerCroppedBelowPrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        guard let previous = args.previous else { return matchContainer(args) }

        let t = CGRectGetMaxY(previous.contentBounds) + previous.contentPadding.bottom + max(previous.contentSpacing.bottom, args.contentSpacing.top)
        let b = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom
        let l = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left
        let r = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right

        let fittingSize = itemFittingSizeForSize(CGSizeMake(r - l, b - t), padding: args.contentPadding)
        let size = args.item.sq_sizeCalculator(SQSizeCalculatorArgs(item: args.item, container: args.container, fittingSize: fittingSize))
        return CGRectMake(t + args.contentPadding.top, l + args.contentPadding.left, size.width, b - t - args.contentPadding.top - args.contentPadding.bottom)
    }

    // MARK: - Private
    
    // Return the fitting size to be used when sizing items to fit in the container.
    // Inset by container and insets and any padding specified by the item so we have
    // space to add them back later.
    private static func itemFittingSizeForContainer(_ container: SQContainerDescription, padding: UIEdgeInsets) -> CGSize {
        let width = CGRectGetWidth(container.layoutBounds) - container.layoutInsets.left - container.layoutInsets.right
        let height = CGRectGetHeight(container.layoutBounds) - container.layoutInsets.top - container.layoutInsets.bottom
        
        return itemFittingSizeForSize(CGSizeMake(width, height), padding: padding)
    }
    
    private static func itemFittingSizeForSize(_ size: CGSize, padding: UIEdgeInsets) -> CGSize {
        let width = size.width - padding.left - padding.right
        let height = size.height - padding.top - padding.bottom
        
        return CGSizeMake(width, height)
    }
    
    // MARK: - Private (spacing relative to previous convenience utilities)
    
    private static func alignAbovePrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerBottom(args, rect: rect) }
        
        var rect = rect
        rect.origin.y = CGRectGetMinY(previous.contentBounds) - previous.contentPadding.top - max(previous.contentSpacing.top, args.contentSpacing.bottom) - args.contentPadding.bottom - CGRectGetHeight(rect)
        return rect
    }
    
    private static func alignBelowPrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerTop(args, rect: rect) }
        
        var rect = rect
        rect.origin.y = CGRectGetMaxY(previous.contentBounds) + previous.contentPadding.bottom + max(previous.contentSpacing.bottom, args.contentSpacing.top) + args.contentPadding.top
        return rect
    }
    
    private static func alignLeftOfPrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerRight(args, rect: rect) }
        
        var rect = rect
        rect.origin.x = CGRectGetMinX(previous.contentBounds) - previous.contentPadding.left - max(previous.contentSpacing.left, args.contentSpacing.right) - args.contentPadding.right - CGRectGetWidth(rect)
        return rect
    }
    
    private static func alignRightOfPrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerLeft(args, rect: rect) }
        
        var rect = rect
        rect.origin.x = CGRectGetMaxX(previous.contentBounds) + previous.contentPadding.right + max(previous.contentSpacing.right, args.contentSpacing.left) + args.contentPadding.left
        return rect
    }

    // MARK: - Private (re-alignment to container convenience utilities)
    
    private static func alignToContainerTop(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.y = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top + args.contentPadding.top
        return rect
    }
    
    private static func alignToContainerLeft(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.x = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left + args.contentPadding.left
        return rect
    }
    
    private static func alignToContainerBottom(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.y = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom - args.contentPadding.bottom - CGRectGetHeight(rect)
        return rect
    }
    
    private static func alignToContainerRight(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.x = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right - args.contentPadding.right - CGRectGetWidth(rect)
        return rect
    }
    
    private static func alignToContainerCenterX(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        let left = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left
        let right = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right
        let width = CGRectGetWidth(rect) + args.contentPadding.left + args.contentPadding.right
        
        rect.origin.x = (left + right)/2 - width/2 + args.contentPadding.left
        return rect
    }
    
    private static func alignToContainerCenterY(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        let top = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top
        let bottom = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom
        let height = CGRectGetHeight(rect) + args.contentPadding.top + args.contentPadding.bottom
        
        rect.origin.y = (top + bottom)/2 - height/2 + args.contentPadding.top
        return rect
    }
    
    // MARK: - Private (re-alignment to previous convenience utilities)
    
    private static func alignToPreviousTop(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerTop(args, rect: rect) }
        
        var rect = rect
        rect.origin.y = CGRectGetMinY(previous.contentBounds) - previous.contentPadding.top + args.contentPadding.top
        return rect
    }
    
    private static func alignToPreviousLeft(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerLeft(args, rect: rect) }
        
        var rect = rect
        rect.origin.x = CGRectGetMinX(previous.contentBounds) - previous.contentPadding.left + args.contentPadding.left
        return rect
    }
    
    private static func alignToPreviousBottom(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerBottom(args, rect: rect) }
        
        var rect = rect
        rect.origin.y = CGRectGetMaxY(previous.contentBounds) + previous.contentPadding.bottom - args.contentPadding.bottom - CGRectGetHeight(rect)
        return rect
    }
    
    private static func alignToPreviousRight(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerRight(args, rect: rect) }
        
        var rect = rect
        rect.origin.x = CGRectGetMaxX(previous.contentBounds) + previous.contentPadding.right - args.contentPadding.right - CGRectGetWidth(rect)
        return rect
    }
    
    private static func alignToPreviousCenterX(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerCenterX(args, rect: rect) }
        
        var rect = rect
        let left = CGRectGetMinX(previous.contentBounds) - args.contentPadding.left
        let right = CGRectGetMaxX(previous.contentBounds) + args.contentPadding.right
        let width = CGRectGetWidth(rect) + args.contentPadding.left + args.contentPadding.right
        
        rect.origin.x = (left + right)/2 - width/2 + args.contentPadding.left
        return rect
    }
    
    private static func alignToPreviousCenterY(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerCenterY(args, rect: rect) }
        
        var rect = rect
        let top = CGRectGetMinY(previous.contentBounds) - args.contentPadding.top
        let bottom = CGRectGetMaxY(previous.contentBounds) + args.contentPadding.bottom
        let height = CGRectGetHeight(rect) + args.contentPadding.top + args.contentPadding.bottom
        
        rect.origin.y = (top + bottom)/2 - height/2 + args.contentPadding.top
        return rect
    }

    // MARK: - Private (extend to container bounds)

    public static func extendToContainerRight(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        
        rect.size.width = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right - args.contentPadding.right - CGRectGetMinX(rect)
        return rect
    }

    private static func extendToContainerLeft(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        let diff = CGRectGetMinX(rect) - (CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left)
        
        rect.origin.x -= diff
        rect.size.width += diff
        return rect
    }
}

