//
//  SQLayoutTypes.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/23.
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
    let shouldSkipLayout: Bool
    
    /// If true, this object's bounds are ignored when finding the
    /// "occupied" bounds used to calculate a view size.  This is
    /// useful for ignoring background images and other decoration
    /// that is intended to overflow the bounds of a view
    let shouldIgnoreWhenCalculatingSize: Bool

    /// If false, the next layout item will not see us as the "previous" item
    /// This option is useful to layout multiple leaves relative to a common previous node.
    let saveAsPrevious: Bool
    init(shouldSkipLayout: Bool = false, shouldIgnoreWhenCalculatingSize: Bool = false, saveAsPrevious: Bool = true) {
        self.shouldSkipLayout = shouldSkipLayout
        self.shouldIgnoreWhenCalculatingSize = shouldIgnoreWhenCalculatingSize
        self.saveAsPrevious = saveAsPrevious
    }
}

/// Describes the layout container that an item is being asked to layout inside
@objcMembers
public class SQContainerDescription: NSObject {
    let layoutBounds: CGRect
    let layoutInsets: UIEdgeInsets
    init(layoutBounds: CGRect, layoutInsets: UIEdgeInsets) {
        self.layoutBounds = layoutBounds
        self.layoutInsets = layoutInsets
    }
}

/// Describes the previous item laid out during the sequential layout process
@objcMembers
public class SQPreviousItemDescription: NSObject {
    let item: SQLayoutItem
    let contentBounds: CGRect
    let contentSpacing: UIEdgeInsets
    let contentPadding: UIEdgeInsets
    init(item: SQLayoutItem, contentBounds: CGRect, contentSpacing: UIEdgeInsets, contentPadding: UIEdgeInsets) {
        self.item = item
        self.contentBounds = contentBounds
        self.contentSpacing = contentSpacing
        self.contentPadding = contentPadding
    }
}

/// Arguments passed to size calculators
@objcMembers
public class SQSizeCalculatorArgs: NSObject {
    let item: SQLayoutItem
    let container: SQContainerDescription
    let fittingSize: CGSize
    init(item: SQLayoutItem, container: SQContainerDescription, fittingSize: CGSize) {
        self.item = item
        self.container = container
        self.fittingSize = fittingSize
    }
}

/// Arguments passed to frame calculators
@objcMembers
public class SQFrameCalculatorArgs: NSObject {
    let item: SQLayoutItem
    let contentPadding: UIEdgeInsets
    let contentSpacing: UIEdgeInsets
    let container: SQContainerDescription
    var previous: SQPreviousItemDescription?
    let forSizingOnly: Bool
    init(item: SQLayoutItem, contentPadding: UIEdgeInsets, contentSpacing: UIEdgeInsets, container: SQContainerDescription, previous: SQPreviousItemDescription? = nil, forSizingOnly: Bool) {
        self.item = item
        self.contentPadding = contentPadding
        self.contentSpacing = contentSpacing
        self.container = container
        self.previous = previous
        self.forSizingOnly = forSizingOnly
    }
}

/// Arguments passed to ContentSpacing calculators
@objcMembers
public class SQContentSpacingCalculatorArgs: NSObject {
    let item: SQLayoutItem
    let container: SQContainerDescription
    init(item: SQLayoutItem, container: SQContainerDescription) {
        self.item = item
        self.container = container
    }
}

/// Arguments passed ContentPadding calculators
@objcMembers
public class SQContentPaddingCalculatorArgs: NSObject {
    let item: SQLayoutItem
    let container: SQContainerDescription
    init(item: SQLayoutItem, container: SQContainerDescription) {
        self.item = item
        self.container = container
    }
}

/// Arguments passed LayoutOptions calculators
@objcMembers
public class SQLayoutOptionsCalculatorArgs: NSObject {
    let item: SQLayoutItem
    let container: SQContainerDescription
    init(item: SQLayoutItem, container: SQContainerDescription) {
        self.item = item
        self.container = container
    }
}

/// Arguments passed to Layout observers
@objcMembers
public class SQLayoutObserverArgs: NSObject {
    let item: SQLayoutItem
    let frame: CGRect
    let forSizingOnly: Bool
    init(item: SQLayoutItem, frame: CGRect, forSizingOnly: Bool) {
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
public typealias SQContentSpacingCalculator = (SQContentSpacingCalculatorArgs) -> UIEdgeInsets

/// Returns adjustments frame calculators should make to the position of returned frame
/// to add or remove padding around the content of an item.  Use positive values to add
/// padding; negative values to ignore built-in whitespace in an item (borderless buttons,
/// text ascenders, etc) when laying out an item.  Unlike a contentSpacing, contentPadding
/// handling is handled internally in an item generally opaque from other items.
public typealias SQContentPaddingCalculator =  (SQContentPaddingCalculatorArgs) -> UIEdgeInsets

/// Returns options that fine-tune how this item is handled during layout
public typealias SQLayoutOptionsCalculator = (SQLayoutOptionsCalculatorArgs) -> SQLayoutOptions

/// Called after an item layout has occurred so the item can process the result
public typealias SQLayoutObserver = (SQLayoutObserverArgs) -> Void

