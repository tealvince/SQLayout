//
//  SQLayoutCalculators.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
//  (c)2023 All Rights Reserved
//

import UIKit

///
/// An assortment of useful reusable convenience frame calculators.
/// Can often be used instead of defining a custom calculator for an item.
///
@objcMembers
public class SQLayoutCalculators: NSObject {

    // MARK: - Options calculators

    // Convenience calculator that skips a view if it is hidden
    public static func skipLayoutIfViewHiddenOptionsCalculator(_ args: SQLayoutOptionsCalculatorArgs) -> SQLayoutOptions {
        guard let view = args.item.sq_rootItem as? UIView else { return SQLayoutOptions() }
        return SQLayoutOptions(shouldSkipLayout: view.isHidden)
    }

    // MARK: - Size calculators

    // Convenience calculator that returns a specific static size if hidden, else use default view size calculator
    public static func viewSizeCalculatorIfHidden(_ hiddenSize: CGSize) -> SQSizeCalculator {
        { args in
            guard let view = args.item.sq_rootItem as? UIView, !view.isHidden else { return hiddenSize }
            return viewSizeCalculator()(args)
        }
    }

    // Convenience calculator that return a specific static size if hidden, else use alternate static size
    public static func viewSizeCalculatorIfHidden(_ hiddenSize: CGSize, else normalSize: CGSize) -> SQSizeCalculator {
        { args in
            guard let view = args.item.sq_rootItem as? UIView, !view.isHidden else { return hiddenSize }
            return normalSize
        }
    }

    // Convenience view size calculator that applies common modifications
    // to the size returned by sizeThatFits(), avoiding the need to specify
    // a custom calculator closure in many cases.  Adds optional delta
    // values to width/height and/or minimum/maximum size/width/height values
    public static func viewSizeCalculator(addWidth: CGFloat = 0, addHeight: CGFloat = 0, minSize: CGSize? = nil, maxSize: CGSize? = nil, minWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, zeroIfHidden: Bool = false) -> SQSizeCalculator {
        { args in
            guard let view = args.item.sq_rootItem as? UIView, !(zeroIfHidden && view.isHidden) else { return .zero }
            var fittingSize = args.fittingSize
            let maxWidth  = maxWidth  ?? maxSize?.width  ?? CGFloat.greatestFiniteMagnitude
            let maxHeight = maxHeight ?? maxSize?.height ?? CGFloat.greatestFiniteMagnitude
            let minWidth  = minWidth  ?? minSize?.width  ?? 0
            let minHeight = minHeight ?? minSize?.height ?? 0

            // Apply modifications to "fitting size"
            fittingSize.width = min(maxWidth, fittingSize.width)
            fittingSize.height = min(maxHeight, fittingSize.height)

            fittingSize.width -= addWidth
            fittingSize.height -= addHeight

            var size: CGSize = .zero

            // Fix calculation of UILabel handle wrapping properly, as sizeToFit sometimes
            // returns a width that is a few pixels too short
            if let label = view as? UILabel, let text = label.text, let font = label.font {
                let maximumObservedLabelWidthRoundoff: CGFloat = 3
                var fitSize = text.boundingRect(with: fittingSize, options: [.usesLineFragmentOrigin], attributes: [.font: font], context: nil).size

                // Note: Revisit this if we need to support attributed text with variable line spacing
                if label.numberOfLines != 0 {
                    fitSize.height = min(fitSize.height, font.lineHeight * CGFloat(label.numberOfLines))
                }

                size = CGSizeMake(fitSize.width + maximumObservedLabelWidthRoundoff, fitSize.height)
            } else {
                size = view.sizeThatFits(fittingSize)
            }

            // Apply modifications to final size
            size.width += addWidth
            size.height += addHeight

            size.width  = max(minWidth,  size.width)
            size.height = max(minHeight, size.height)
            size.width  = min(maxWidth,  size.width)
            size.height = min(maxHeight, size.height)

            return size
        }
    }

    // MARK: - Frame calculators (Matching)

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
        let l = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left + args.padding.left
        let r = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right - args.padding.right
        let t = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top + args.padding.top
        let b = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom - args.padding.bottom

        return CGRect(x: l, y: t, width: r-l, height: b-t)
    }
    public static func matchContainerFullBleed(_ args: SQFrameCalculatorArgs) -> CGRect {
        let l = CGRectGetMinX(args.container.layoutBounds) + args.padding.left
        let r = CGRectGetMaxX(args.container.layoutBounds) - args.padding.right
        let t = CGRectGetMinY(args.container.layoutBounds) + args.padding.top
        let b = CGRectGetMaxY(args.container.layoutBounds) - args.padding.bottom

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

        let l = CGRectGetMinX(previous.contentBounds) - previous.padding.left + args.padding.left
        let r = CGRectGetMaxX(previous.contentBounds) + previous.padding.right - args.padding.right
        let t = CGRectGetMinY(previous.contentBounds) - previous.padding.top + args.padding.top
        let b = CGRectGetMaxY(previous.contentBounds) + previous.padding.bottom - args.padding.bottom

        return CGRect(x: l, y: t, width: r-l, height: b-t)
    }

    // MARK: - Frame calculators (Corner/Center aligned)

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │         ┌───────┐          │
    /// │         │ curr  │          │
    /// │         └───────┘          │
    /// │                            │
    /// └────────────────────────────┘
    public static func containerCenterAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: alignToContainerCenterX(args, rect: containerTopLeftAligned(args)))
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
        return sizedToFit(args, rect: matchContainer(args))
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
        return alignToContainerRight(args, rect: containerTopLeftAligned(args))
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
        return alignToContainerBottom(args, rect: containerTopLeftAligned(args))
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
        return alignToContainerBottom(args, rect: alignToContainerRight(args, rect: containerTopLeftAligned(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌───────┐                 │
    /// │  │ curr  │                 │
    /// │  └───────┘                 │
    /// │                            │
    /// └────────────────────────────┘
    public static func containerCenterLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: sizedToFit(args, rect: matchContainer(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │                 ┌───────┐  │
    /// │                 │ curr  │  │
    /// │                 └───────┘  │
    /// │                            │
    /// └────────────────────────────┘
    public static func containerCenterRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: alignToContainerRight(args, rect: containerTopLeftAligned(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │         ┌───────┐          │
    /// │         │ curr  │          │
    /// │         └───────┘          │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    public static func containerCenterTopAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterX(args, rect: containerTopLeftAligned(args))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │                            │
    /// │         ┌───────┐          │
    /// │         │ curr  │          │
    /// │         └───────┘          │
    /// └────────────────────────────┘
    public static func containerCenterBottomAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerBottom(args, rect: alignToContainerCenterX(args, rect: containerTopLeftAligned(args)))
    }


    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌──────────────────────┐  │
    /// │  │ curr                 │  │
    /// │  └──────────────────────┘  │
    /// │                            │
    /// │                            │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘

    public static func containerWidthTopAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return sizedToFitVertically(args, rect: matchContainer(args))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │                            │
    /// │                            │
    /// │                            │
    /// │  ┌──────────────────────┐  │
    /// │  │ curr                 │  │
    /// │  └──────────────────────┘  │
    /// └────────────────────────────┘

    public static func containerWidthBottomAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerBottom(args, rect: sizedToFitVertically(args, rect: matchContainer(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │                            │
    /// │  ┌──────────────────────┐  │
    /// │  │ curr                 │  │
    /// │  └──────────────────────┘  │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘

    public static func containerWidthCenterAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: sizedToFitVertically(args, rect: matchContainer(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌───────┐                 │
    /// │  │       │                 │
    /// │  │       │                 │
    /// │  │ curr  │                 │
    /// │  │       │                 │
    /// │  │       │                 │
    /// │  └───────┘                 │
    /// └────────────────────────────┘
    public static func containerHeightLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return sizedToFitHorizontally(args, rect: matchContainer(args))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                 ┌───────┐  │
    /// │                 │       │  │
    /// │                 │       │  │
    /// │                 │ curr  │  │
    /// │                 │       │  │
    /// │                 │       │  │
    /// │                 └───────┘  │
    /// └────────────────────────────┘
    public static func containerHeightRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerRight(args, rect: sizedToFitHorizontally(args, rect: matchContainer(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │         ┌───────┐          │
    /// │         │       │          │
    /// │         │       │          │
    /// │         │ curr  │          │
    /// │         │       │          │
    /// │         │       │          │
    /// │         └───────┘          │
    /// └────────────────────────────┘
    public static func containerHeightCenterAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterX(args, rect: sizedToFitHorizontally(args, rect: matchContainer(args)))
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
        return alignToPreviousCenterY(args, rect: alignToPreviousCenterX(args, rect: containerTopLeftAligned(args)))
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
        return alignToPreviousTop(args, rect: alignToPreviousLeft(args, rect: containerTopLeftAligned(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌┌───────┐┐               │
    /// │  │| curr  ││               │
    /// │  |└───────┘│               │
    /// │  │ prev    │               │
    /// │  └─────────┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func centerTopAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: alignToPreviousCenterX(args, rect: containerTopLeftAligned(args)))
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
        return alignToPreviousTop(args, rect: alignToPreviousRight(args, rect: containerTopLeftAligned(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌─────────┐               │
    /// │  | ┌───────┐               │
    /// │  │ │ curr  │               │
    /// │  │ └───────┘               │
    /// │  └─────────┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func centerRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: alignToPreviousRight(args, rect: containerTopLeftAligned(args)))
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
        return alignToPreviousBottom(args, rect: alignToPreviousRight(args, rect: containerTopLeftAligned(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌─────────┐               │
    /// │  │ prev    │               │
    /// │  │┌───────┐|               │
    /// │  ││ curr  │|               │
    /// │  └└───────┘┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func centerBottomAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: alignToPreviousCenterX(args, rect: containerTopLeftAligned(args)))
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
        return alignToPreviousBottom(args, rect: alignToPreviousLeft(args, rect: containerTopLeftAligned(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │  ┌─────────┐               │
    /// │  ┌───────┐ │               │
    /// │  │ curr  │ │               │
    /// │  └───────┘ │               │
    /// │  └─────────┘               │
    /// │                            │
    /// └────────────────────────────┘
    public static func centerLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: alignToPreviousLeft(args, rect: containerTopLeftAligned(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌──────────┐              │
    /// │  │   curr   │              │
    /// │  └──────────┘              │
    /// │  │   prev   │              │
    /// │  └──────────┘              │
    /// │                            │
    /// └────────────────────────────┘
    public static func widthTopAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return sizedToFitVertically(args, rect: matchPrevious(args))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌──────────┐              │
    /// │  │   prev   │              │
    /// │  ┌──────────┐              │
    /// │  │   curr   │              │
    /// │  └──────────┘              │
    /// │                            │
    /// └────────────────────────────┘
    public static func widthBottomAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: sizedToFitVertically(args, rect: matchPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌──────────┐              │
    /// │  ┌──────────┐              │
    /// │  │   curr   │              │
    /// │  └──────────┘              │
    /// │  └──────────┘ prev         │
    /// │                            │
    /// └────────────────────────────┘
    public static func widthCenterAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: sizedToFitVertically(args, rect: matchPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌──────┐───┐              │
    /// │  |      │   |              │
    /// │  │ curr │   │              │
    /// │  |      │   | prev         │
    /// │  └──────┘───┘              │
    /// │                            │
    /// └────────────────────────────┘
    public static func heightLeftAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return sizedToFitHorizontally(args, rect: matchPrevious(args))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌───┌──────┐              │
    /// │  |   |      |              │
    /// │  │   | curr │              │
    /// │  |   |      |              │
    /// │  └───└──────┘              │
    /// │  prev                      │
    /// └────────────────────────────┘
    public static func heightRightAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousRight(args , rect: sizedToFitHorizontally(args, rect: matchPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │  ┌─┌──────┐─┐              │
    /// │  │ |      │ |              │
    /// │  │ │ curr │ │              │
    /// │  │ |      │ | prev         │
    /// │  └─└──────┘─┘              │
    /// │                            │
    /// └────────────────────────────┘
    public static func heightCenterAligned(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterX(args, rect: sizedToFitHorizontally(args, rect: matchPrevious(args)))
    }

    // MARK: - Frame calculators (Container VStack)

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
        return alignBelowPrevious(args, rect: containerTopLeftAligned(args))
    }
    public static func containerLeftAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignAbovePrevious(args, rect: containerTopLeftAligned(args))
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
        return alignToContainerRight(args, rect: alignBelowPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func containerRightAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerRight(args, rect: alignAbovePrevious(args, rect: containerTopLeftAligned(args)))
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
        return alignToContainerCenterX(args, rect: alignBelowPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func containerCenterAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterX(args, rect: alignAbovePrevious(args, rect: containerTopLeftAligned(args)))
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
        return alignBelowPrevious(args, rect: sizedToFitVertically(args, rect: matchContainer(args)))
    }
    public static func containerWidthVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignAbovePrevious(args, rect: sizedToFitVertically(args, rect: matchContainer(args)))
    }

    // MARK: - Frame calculators (Previous VStack)

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
        let rect1 = alignToPreviousLeft(args, rect: alignBelowPrevious(args, rect: containerTopLeftAligned(args)))
        return cropToContainer(args, rect: rect1) { rect2 in
            sizedToFitVertically(args, rect: rect2)
        }
    }
    public static func leftAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignAbovePrevious(args, rect: leftAlignedVStack(args))
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
        let rect1 = alignToPreviousRight(args, rect: alignBelowPrevious(args, rect: containerTopLeftAligned(args)))
        return cropToContainer(args, rect: rect1) { rect2 in
            sizedToFitVertically(args, rect: rect2)
        }
    }
    public static func rightAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignAbovePrevious(args, rect: rightAlignedVStack(args))
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
        let rect1 = alignToPreviousCenterX(args, rect: alignBelowPrevious(args, rect: containerTopLeftAligned(args)))
        return cropToContainer(args, rect: rect1) { rect2 in
            var rect2 = rect2
            let dLeft = rect2.minX - rect1.minX
            let dRight = rect1.maxX - rect2.maxX

            // Make sure both sides shrunk equally by whichever was largest
            if dLeft > dRight {
                rect2.size.width -= dLeft - dRight
            } else {
                rect2.origin.x += dRight - dLeft
                rect2.size.width -= dRight - dLeft
            }
            return sizedToFitVertically(args, rect: rect2)
        }
    }
    public static func centerAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignAbovePrevious(args, rect: centerAlignedVStack(args))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │       ┌────────┐           │
    /// │       │ prev   │           │
    /// │       └────────┘           │
    /// │       ┌────────┐           │
    /// │       │ curr   │           │
    /// │       └────────┘           │
    /// │                            │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous matching width
    ///
    public static func widthAlignedVStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignBelowPrevious(args, rect: sizedToFitVertically(args, rect: matchPrevious(args)))
    }
    public static func widthAlignedVStackUp(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignAbovePrevious(args, rect: sizedToFitVertically(args, rect: matchPrevious(args)))
    }

    // MARK: - Frame calculators (Container HStack)

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
        return alignRightOfPrevious(args, rect: containerTopLeftAligned(args))
    }
    public static func containerTopAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignLeftOfPrevious(args, rect: containerTopLeftAligned(args))
    }
    public static func containerTopAlignedHStackCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = containerTopAlignedHStack(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true)
        }
    }
    public static func containerTopAlignedHStackLeftCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = containerTopAlignedHStackLeft(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignLeftOfPrevious(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true))
        }
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
        return alignToContainerBottom(args, rect: alignRightOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func containerBottomAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerBottom(args, rect: alignLeftOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func containerBottomAlignedHStackCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = containerBottomAlignedHStack(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignToContainerBottom(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true))
        }
    }
    public static func containerBottomAlignedHStackLeftCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = containerBottomAlignedHStackLeft(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignLeftOfPrevious(args, rect: alignToContainerBottom(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true)))
        }
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
        return alignToContainerCenterY(args, rect: alignRightOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func containerCenterAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToContainerCenterY(args, rect: alignLeftOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func containerCenterAlignedHStackCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = containerCenterAlignedHStack(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignToContainerCenterY(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true))
        }
    }
    public static func containerCenterAlignedHStackLeftCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = containerCenterAlignedHStackLeft(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignLeftOfPrevious(args, rect: alignToContainerCenterY(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true)))
        }
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │   ┌───────┐ ┌───────┐      │
    /// │   │ prev  │ │ curr  │      │
    /// │   │       │ │       │      │
    /// │   │       │ │       │      │
    /// │   │       │ │       │      │
    /// │   │       │ │       │      │
    /// │   └───────┘ └───────┘      │
    /// └────────────────────────────┘
    public static func containerHeightHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignRightOfPrevious(args, rect: sizedToFitHorizontally(args, rect: matchContainer(args)))
    }
    public static func containerHeightHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignLeftOfPrevious(args, rect: sizedToFitHorizontally(args, rect: matchContainer(args)))
    }


    // MARK: - Frame calculators (Previous HStack)

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
        return alignToPreviousTop(args, rect: alignRightOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func topAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: alignLeftOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func topAlignedHStackCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = topAlignedHStack(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true)
        }
    }
    public static func topAlignedHStackLeftCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = topAlignedHStackLeft(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignLeftOfPrevious(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true))
        }
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
        return alignToPreviousBottom(args, rect: alignRightOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func bottomAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: alignLeftOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func bottomAlignedHStackCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = bottomAlignedHStack(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignToPreviousBottom(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true))
        }
    }
    public static func bottomAlignedHStackLeftCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = bottomAlignedHStackLeft(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignLeftOfPrevious(args, rect: alignToPreviousBottom(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true)))
        }
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
        return alignToPreviousCenterY(args, rect: alignRightOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func centerAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: alignLeftOfPrevious(args, rect: containerTopLeftAligned(args)))
    }
    public static func centerAlignedHStackCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = centerAlignedHStack(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignToPreviousCenterY(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true))
        }
    }
    public static func centerAlignedHStackLeftCropped(_ args: SQFrameCalculatorArgs) -> CGRect {
        let rect1 = centerAlignedHStackLeft(args)
        return cropToContainer(args, rect: rect1) { rect2 in
            alignLeftOfPrevious(args, rect: alignToPreviousCenterY(args, rect: sizedToFitVertically(args, rect: rect2, canShrinkHorizontally: true)))
        }
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │   ┌───────┐ ┌───────────┐  │
    /// │   │ prev  │ │ curr      │  │
    /// │   └───────┘ └───────────┘  │
    /// │                            │
    /// └────────────────────────────┘
    ///
    /// Place an item below the previous matching width
    ///
    public static func heightAlignedHStack(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignRightOfPrevious(args, rect: sizedToFitHorizontally(args, rect: matchPrevious(args)))
    }
    public static func heightAlignedHStackLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignLeftOfPrevious(args, rect: sizedToFitHorizontally(args, rect: matchPrevious(args)))
    }

    // MARK: - Frame calculators (Fill)

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │   ┌───────┐ ┌────────────┐ │
    /// │   │ prev  │ │ curr       │ │
    /// │   └───────┘ │            │ │
    /// │             └────────────┘ │
    /// └────────────────────────────┘
    ///
    /// Place an item filling the space between the previous item and container edge
    ///
    public static func topAlignedFillToRight(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: sizedToFitVertically(args, rect: containerRightOfPrevious(args)))
    }
    public static func topAlignedFillToLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: sizedToFitVertically(args, rect: containerLeftOfPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │             ┌────────────┐ │
    /// │   ┌───────┐ │ curr       | |
    /// │   │ prev  │ │            │ │
    /// │   └───────┘ └────────────┘ │
    /// │                            │
    /// └────────────────────────────┘
    ///
    public static func bottomAlignedFillToRight(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: sizedToFitVertically(args, rect: containerRightOfPrevious(args)))
    }
    public static func bottomAlignedFillToLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousBottom(args, rect: sizedToFitVertically(args, rect: containerLeftOfPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │             ┌────────────┐ │
    /// │   ┌───────┐ │ curr       | |
    /// │   │ prev  │ │            │ │
    /// │   └───────┘ │            │ │
    /// │             └────────────┘ │
    /// └────────────────────────────┘
    ///
    public static func centerAlignedFillToRight(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: sizedToFitVertically(args, rect: containerRightOfPrevious(args)))
    }
    public static func centerAlignedFillToLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterY(args, rect: sizedToFitVertically(args, rect: containerLeftOfPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │   ┌───────┐ ┌────────────┐ │
    /// │   │ prev  │ │ curr       │ │
    /// │   └───────┘ └────────────┘ │
    /// │                            │
    /// └────────────────────────────┘
    ///
    public static func heightAlignedFillToRight(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: cropToPreviousHeight(args, rect: containerRightOfPrevious(args)))
    }
    public static func heightAlignedFillToLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousTop(args, rect: cropToPreviousHeight(args, rect: containerLeftOfPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │    ┌──────────────┐        │
    /// │    │ curr         │        │
    /// │    │              │        │
    /// │    │              │        │
    /// │    └──────────────┘        │
    /// │    ┌────────┐              │
    /// │    │ prev   │              │
    /// │    └────────┘              │
    /// │                            │
    /// └────────────────────────────┘
    ///
    public static func leftAlignedFillToTop(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousLeft(args, rect: sizedToFitHorizontally(args, rect: containerAbovePrevious(args)))
    }
    public static func rightAlignedFillToTop(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousRight(args, rect: sizedToFitHorizontally(args, rect: containerAbovePrevious(args)))
    }
    public static func centerAlignedFillToTop(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterX(args, rect: sizedToFitHorizontally(args, rect: containerAbovePrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │    ┌────────┐              │
    /// │    │ prev   │              │
    /// │    └────────┘              │
    /// │    ┌──────────────┐        │
    /// │    │ curr         │        │
    /// │    │              │        │
    /// │    │              │        │
    /// │    └──────────────┘        │
    /// └────────────────────────────┘
    ///
    public static func leftAlignedFillToBottom(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousLeft(args, rect: sizedToFitHorizontally(args, rect: containerBelowPrevious(args)))
    }
    public static func rightAlignedFillToBottom(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousRight(args, rect: sizedToFitHorizontally(args, rect: containerBelowPrevious(args)))
    }
    public static func centerAlignedFillToBottom(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousCenterX(args, rect: sizedToFitHorizontally(args, rect: containerBelowPrevious(args)))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │                            │
    /// │    ┌────────┐              │
    /// │    │ prev   │              │
    /// │    └────────┘              │
    /// │    ┌────────┐              │
    /// │    │ curr   │              │
    /// │    │        │              │
    /// │    │        │              │
    /// │    └────────┘              │
    /// └────────────────────────────┘
    ///
    public static func widthAlignedFillToTop(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousLeft(args, rect: cropToPreviousWidth(args, rect: containerAbovePrevious(args)))
    }
    public static func widthAlignedFillToBottom(_ args: SQFrameCalculatorArgs) -> CGRect {
        return alignToPreviousLeft(args, rect: cropToPreviousWidth(args, rect: containerBelowPrevious(args)))
    }


    // MARK: - Frame calculators (Flow)

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
        if CGRectGetMaxX(rect) + args.padding.right > CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right {
            rect = containerLeftAlignedVStack(args)
        }
        return rect
    }
    public static func bottomAlignedFlow(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = bottomAlignedHStack(args)
        if CGRectGetMaxX(rect) + args.padding.right > CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right {
            rect = containerLeftAlignedVStack(args)
        }
        return rect
    }
    public static func centerAlignedFlow(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = centerAlignedHStack(args)
        if CGRectGetMaxX(rect) + args.padding.right > CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right {
            rect = containerLeftAlignedVStack(args)
        }
        return rect
    }
    public static func heightAlignedFlow(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = heightAlignedHStack(args)
        if CGRectGetMaxX(rect) + args.padding.right > CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right {
            rect = cropToPreviousHeight(args, rect: containerLeftAlignedVStack(args))
        }
        return rect
    }
    public static func topAlignedFlowLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = topAlignedHStackLeft(args)
        if CGRectGetMinX(rect) - args.padding.right < CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left {
            rect = containerRightAlignedVStack(args)
        }
        return rect
    }
    public static func bottomAlignedFlowLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = bottomAlignedHStackLeft(args)
        if CGRectGetMinX(rect) - args.padding.right < CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left {
            rect = containerRightAlignedVStack(args)
        }
        return rect
    }
    public static func centerAlignedFlowLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = centerAlignedHStackLeft(args)
        if CGRectGetMinX(rect) - args.padding.right < CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left {
            rect = containerRightAlignedVStack(args)
        }
        return rect
    }
    public static func heightAlignedFlowLeft(_ args: SQFrameCalculatorArgs) -> CGRect {
        var rect = heightAlignedHStackLeft(args)
        if CGRectGetMinX(rect) - args.padding.right < CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left {
            rect = cropToPreviousHeight(args, rect: containerRightAlignedVStack(args))
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
    /// └────────────────────────────┘
    ///
    public static func containerLeftOfPrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        let baseRect = matchContainer(args)
        if args.previous == nil {
            return baseRect
        }
        let shiftedRect = alignLeftOfPrevious(args, rect: baseRect)

        return CGRectMake(CGRectGetMinX(baseRect), CGRectGetMinY(baseRect), CGRectGetMaxX(shiftedRect) - CGRectGetMinX(baseRect), CGRectGetHeight(baseRect))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │            ┌────────────┐  │
    /// │  ┌───────┐ │ curr       │  │
    /// │  │ prev  │ │            │  │
    /// │  └───────┘ │            │  │
    /// │            │            │  │
    /// │            │            │  │
    /// │            └────────────┘  │
    /// └────────────────────────────┘
    ///
    public static func containerRightOfPrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        let baseRect = matchContainer(args)
        if args.previous == nil {
            return baseRect
        }
        let shiftedRect = alignRightOfPrevious(args, rect: baseRect)

        return CGRectMake(CGRectGetMinX(shiftedRect), CGRectGetMinY(baseRect), CGRectGetMaxX(baseRect) - CGRectGetMinX(shiftedRect), CGRectGetHeight(baseRect))
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
    public static func containerAbovePrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        let baseRect = matchContainer(args)
        if args.previous == nil {
            return baseRect
        }
        let shiftedRect = alignAbovePrevious(args, rect: baseRect)

        return CGRectMake(CGRectGetMinX(baseRect), CGRectGetMinY(baseRect), CGRectGetWidth(baseRect), CGRectGetMaxY(shiftedRect) - CGRectGetMinY(baseRect))
    }

    /// ````
    /// ┌────────────────────────────┐
    /// │            ┌───────┐       │
    /// │            │ prev  │       │
    /// │            └───────┘       │
    /// │  ┌──────────────────────┐  │
    /// │  │                      │  │
    /// │  │       curr           │  │
    /// │  │                      │  │
    /// │  └──────────────────────┘  │
    /// └────────────────────────────┘
    ///
    public static func containerBelowPrevious(_ args: SQFrameCalculatorArgs) -> CGRect {
        let baseRect = matchContainer(args)
        if args.previous == nil {
            return baseRect
        }
        let shiftedRect = alignBelowPrevious(args, rect: baseRect)

        return CGRectMake(CGRectGetMinX(baseRect), CGRectGetMinY(shiftedRect), CGRectGetWidth(baseRect), CGRectGetMaxY(baseRect) - CGRectGetMinY(shiftedRect))
    }
}

///
/// Methods that transform item frames to help make custom frame calculator variations
///
extension SQLayoutCalculators {

    // MARK: - Sizing to fit

    // Return bounds for item sized to fit within given bounds (which have already been
    // adjusted for padding)
    public static func sizedToFit(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        let size = args.item.sq_sizeCalculator?(SQSizeCalculatorArgs(item: args.item, container: args.container, fittingSize: rect.size)) ?? .zero

        // Constrain vertically and horizontally but allow to contract within
        return CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height)
    }

    public static func sizedToFitVertically(_ args: SQFrameCalculatorArgs, rect: CGRect, canShrinkHorizontally: Bool = false) -> CGRect {
        var sizedRect = sizedToFit(args, rect: CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, CGFloat.greatestFiniteMagnitude))

        // Constrain horizontally but allow to expand vertically
        sizedRect.size.width = canShrinkHorizontally ? min(rect.size.width, sizedRect.size.width) : rect.size.width
        return sizedRect
    }

    public static func sizedToFitHorizontally(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var sizedRect = sizedToFit(args, rect: CGRectMake(rect.origin.x, rect.origin.y, CGFloat.greatestFiniteMagnitude, rect.size.height))

        // Constrain vertically but allow to expand horizontally
        sizedRect.size.height = rect.size.height
        return sizedRect
    }

    // MARK: - Aligning next to previous

    public static func alignAbovePrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerBottom(args, rect: rect) }

        var rect = rect
        rect.origin.y = CGRectGetMinY(previous.contentBounds) - previous.padding.top - max(previous.spacing.top, args.spacing.bottom) - args.padding.bottom - CGRectGetHeight(rect)
        return rect
    }

    public static func alignBelowPrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerTop(args, rect: rect) }

        var rect = rect
        rect.origin.y = CGRectGetMaxY(previous.contentBounds) + previous.padding.bottom + max(previous.spacing.bottom, args.spacing.top) + args.padding.top
        return rect
    }

    public static func alignLeftOfPrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerRight(args, rect: rect) }

        var rect = rect
        rect.origin.x = CGRectGetMinX(previous.contentBounds) - previous.padding.left - max(previous.spacing.left, args.spacing.right) - args.padding.right - CGRectGetWidth(rect)
        return rect
    }

    public static func alignRightOfPrevious(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerLeft(args, rect: rect) }

        var rect = rect
        rect.origin.x = CGRectGetMaxX(previous.contentBounds) + previous.padding.right + max(previous.spacing.right, args.spacing.left) + args.padding.left
        return rect
    }

    // MARK: - Aligning to container edges

    public static func alignToContainerTop(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.y = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top + args.padding.top
        return rect
    }

    public static func alignToContainerLeft(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.x = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left + args.padding.left
        return rect
    }

    public static func alignToContainerBottom(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.y = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom - args.padding.bottom - CGRectGetHeight(rect)
        return rect
    }

    public static func alignToContainerRight(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        rect.origin.x = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right - args.padding.right - CGRectGetWidth(rect)
        return rect
    }

    public static func alignToContainerCenterX(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        let left = CGRectGetMinX(args.container.layoutBounds) + args.container.layoutInsets.left
        let right = CGRectGetMaxX(args.container.layoutBounds) - args.container.layoutInsets.right
        let width = CGRectGetWidth(rect) + args.padding.left + args.padding.right

        rect.origin.x = (left + right)/2 - width/2 + args.padding.left
        return rect
    }

    public static func alignToContainerCenterY(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        var rect = rect
        let top = CGRectGetMinY(args.container.layoutBounds) + args.container.layoutInsets.top
        let bottom = CGRectGetMaxY(args.container.layoutBounds) - args.container.layoutInsets.bottom
        let height = CGRectGetHeight(rect) + args.padding.top + args.padding.bottom

        rect.origin.y = (top + bottom)/2 - height/2 + args.padding.top
        return rect
    }

    // MARK: - Aligning to previous edges

    public static func alignToPreviousTop(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerTop(args, rect: rect) }

        var rect = rect
        rect.origin.y = CGRectGetMinY(previous.contentBounds) - previous.padding.top + args.padding.top
        return rect
    }

    public static func alignToPreviousLeft(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerLeft(args, rect: rect) }

        var rect = rect
        rect.origin.x = CGRectGetMinX(previous.contentBounds) - previous.padding.left + args.padding.left
        return rect
    }

    public static func alignToPreviousBottom(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerBottom(args, rect: rect) }

        var rect = rect
        rect.origin.y = CGRectGetMaxY(previous.contentBounds) + previous.padding.bottom - args.padding.bottom - CGRectGetHeight(rect)
        return rect
    }

    public static func alignToPreviousRight(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerRight(args, rect: rect) }

        var rect = rect
        rect.origin.x = CGRectGetMaxX(previous.contentBounds) + previous.padding.right - args.padding.right - CGRectGetWidth(rect)
        return rect
    }

    public static func alignToPreviousCenterX(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerCenterX(args, rect: rect) }

        var rect = rect
        let left = CGRectGetMinX(previous.contentBounds)
        let right = CGRectGetMaxX(previous.contentBounds)
        let width = CGRectGetWidth(rect) + args.padding.left + args.padding.right

        rect.origin.x = (left + right)/2 - width/2 + args.padding.left
        return rect
    }

    public static func alignToPreviousCenterY(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return alignToContainerCenterY(args, rect: rect) }

        var rect = rect
        let top = CGRectGetMinY(previous.contentBounds)
        let bottom = CGRectGetMaxY(previous.contentBounds)
        let height = CGRectGetHeight(rect) + args.padding.top + args.padding.bottom

        rect.origin.y = (top + bottom)/2 - height/2 + args.padding.top
        return rect
    }

    // MARK: - Cropping

    public static func cropToPreviousHeight(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return rect }

        var rect = rect
        rect.size.height = CGRectGetHeight(previous.contentBounds) + previous.padding.top + previous.padding.bottom - args.padding.top - args.padding.bottom
        return rect
    }

    public static func cropToPreviousWidth(_ args: SQFrameCalculatorArgs, rect: CGRect) -> CGRect {
        guard let previous = args.previous else { return rect }

        var rect = rect
        rect.size.width = CGRectGetWidth(previous.contentBounds) + previous.padding.left + previous.padding.right - args.padding.left - args.padding.right
        return rect
    }

    public static func cropToContainer(_ args: SQFrameCalculatorArgs, rect: CGRect, cleanup: ((CGRect) -> CGRect)? = nil) -> CGRect {
        let oldRect = rect
        var rect = rect
        let cRect = args.container.layoutBounds
        let cInsets = args.container.layoutInsets
        let dL = cRect.minX + cInsets.left - (rect.minX - args.padding.left)
        let dT = cRect.minY + cInsets.top  - (rect.minY - args.padding.top)

        if dL > 0 {
            rect.origin.x += dL
            rect.size.width -= dL
        }
        if dT > 0 {
            rect.origin.y += dT
            rect.size.height -= dT
        }

        let dR = (rect.maxX + args.padding.right)  - (cRect.maxX - cInsets.right)
        let dB = (rect.maxY + args.padding.bottom) - (cRect.maxY - cInsets.bottom)

        if dR > 0 {
            rect.size.width -= dR
        }
        if dB > 0 {
            rect.size.height -= dB
        }
        if let cleanup = cleanup, rect != oldRect {
            return cleanup(rect)
        }
        return rect
    }
}

