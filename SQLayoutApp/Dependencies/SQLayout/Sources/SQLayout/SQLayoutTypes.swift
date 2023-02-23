//
//  SQLayoutTypes.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
//  (c)2023 All Rights Reserved
//

import UIKit

///
/// Calculator/Observer Arguments
///
/// Container classes for passing information to calculators and observers.  Defined as
/// classes for objective-c compatibility and to allow for easy future expansion without
/// modifying calculator definitions.
///

/// Describes options that affect layout
@objcMembers
public class SQLayoutOptions: NSObject {
    /// When true, this object is ignored during layout
    public let shouldSkipLayout: Bool

    /// If true, this object's bounds are ignored when finding the
    /// "occupied" bounds used to calculate a view size.  This is
    /// useful for ignoring background images and other decoration
    /// that is intended to overflow the bounds of a view
    public let shouldIgnoreWhenCalculatingSize: Bool

    /// If false, the next layout item will not see us as the "previous" item
    /// This option is useful to layout multiple leaves relative to a common previous node.
    public let saveAsPrevious: Bool
    public init(shouldSkipLayout: Bool = false, shouldIgnoreWhenCalculatingSize: Bool = false, saveAsPrevious: Bool = true) {
        self.shouldSkipLayout = shouldSkipLayout
        self.shouldIgnoreWhenCalculatingSize = shouldIgnoreWhenCalculatingSize
        self.saveAsPrevious = saveAsPrevious
    }
}

/// Describes the layout container that an item is being asked to layout inside
@objcMembers
public class SQContainerDescription: NSObject {
    public let layoutBounds: CGRect
    public let layoutInsets: UIEdgeInsets
    public init(layoutBounds: CGRect, layoutInsets: UIEdgeInsets) {
        self.layoutBounds = layoutBounds
        self.layoutInsets = layoutInsets
    }
}

/// Describes the previous item laid out during the sequential layout process
@objcMembers
public class SQPreviousItemDescription: NSObject {
    public let item: any SQLayoutItem
    public let contentBounds: CGRect
    public let spacing: UIEdgeInsets
    public let padding: UIEdgeInsets
    public init(item: any SQLayoutItem, contentBounds: CGRect, spacing: UIEdgeInsets, padding: UIEdgeInsets) {
        self.item = item
        self.contentBounds = contentBounds
        self.spacing = spacing
        self.padding = padding
    }
}

/// Arguments passed to size calculators
@objcMembers
public class SQSizeCalculatorArgs: NSObject {
    public let item: any SQLayoutItem
    public let container: SQContainerDescription
    public let fittingSize: CGSize
    public init(item: any SQLayoutItem, container: SQContainerDescription, fittingSize: CGSize) {
        self.item = item
        self.container = container
        self.fittingSize = fittingSize
    }
}

/// Arguments passed to frame calculators
@objcMembers
public class SQFrameCalculatorArgs: NSObject {
    public let item: any SQLayoutItem
    public let padding: UIEdgeInsets
    public let spacing: UIEdgeInsets
    public let container: SQContainerDescription
    public var previous: SQPreviousItemDescription?
    public var previousToPrevious: SQPreviousItemDescription?
    public let forSizingOnly: Bool
    public init(item: any SQLayoutItem, padding: UIEdgeInsets, spacing: UIEdgeInsets, container: SQContainerDescription, previous: SQPreviousItemDescription? = nil, previousToPrevious: SQPreviousItemDescription? = nil, forSizingOnly: Bool) {
        self.item = item
        self.padding = padding
        self.spacing = spacing
        self.container = container
        self.previous = previous
        self.forSizingOnly = forSizingOnly
    }
}

/// Arguments passed to Spacing calculators
@objcMembers
public class SQSpacingCalculatorArgs: NSObject {
    public let item: any SQLayoutItem
    public let container: SQContainerDescription
    public init(item: any SQLayoutItem, container: SQContainerDescription) {
        self.item = item
        self.container = container
    }
}

/// Arguments passed Padding calculators
@objcMembers
public class SQPaddingCalculatorArgs: NSObject {
    public let item: any SQLayoutItem
    public let container: SQContainerDescription
    public init(item: any SQLayoutItem, container: SQContainerDescription) {
        self.item = item
        self.container = container
    }
}

/// Arguments passed LayoutOptions calculators
@objcMembers
public class SQLayoutOptionsCalculatorArgs: NSObject {
    public let item: any SQLayoutItem
    public let container: SQContainerDescription
    public init(item: any SQLayoutItem, container: SQContainerDescription) {
        self.item = item
        self.container = container
    }
}

/// Arguments passed to Layout observers
@objcMembers
public class SQLayoutObserverArgs: NSObject {
    public let item: any SQLayoutItem
    public let frame: CGRect
    public let forSizingOnly: Bool
    public init(item: any SQLayoutItem, frame: CGRect, forSizingOnly: Bool) {
        self.item = item
        self.frame = frame
        self.forSizingOnly = forSizingOnly
    }
}

/// Called by frame calculators to calculate the ideal  size for an item given
/// a "fittingSize" to layout within.  Typical behavior for views is to return sizeThatFits:
public typealias SQSizeCalculator = (SQSizeCalculatorArgs) -> CGSize

/// Called during the layout or sizing process to calculate the frame of an item
/// when given information about the previous item laid out the enclosing container
public typealias SQFrameCalculator = (SQFrameCalculatorArgs) -> CGRect

/// Returns the minimum spacing requested for an item relative to the previous/next items
/// during sequential layout.  Use of this field depends on well-behaved frame calculators
public typealias SQSpacingCalculator = (SQSpacingCalculatorArgs) -> UIEdgeInsets

/// Returns adjustments frame calculators should make to the position of returned frame
/// to add or remove padding around the content of an item.  Use positive values to add
/// padding; negative values to ignore built-in whitespace in an item (borderless buttons,
/// text ascenders, etc) when laying out an item.  Unlike a spacing, padding
/// handling is handled internally in an item generally opaque from other items.
public typealias SQPaddingCalculator =  (SQPaddingCalculatorArgs) -> UIEdgeInsets

/// Returns options that fine-tune how this item is handled during layout
public typealias SQLayoutOptionsCalculator = (SQLayoutOptionsCalculatorArgs) -> SQLayoutOptions

/// Called after an item layout has occurred so the item can process the result
public typealias SQLayoutObserver = (SQLayoutObserverArgs) -> Void

