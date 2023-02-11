//
//  SQLayoutItem.swift
//  SQLayout
//
//  Created by Vince Lee on 2/5/23.
//  (c)2023 All Rights Reserved
//

import UIKit

///
/// Represents an object that can perform sequential layout.
///
@objc
public protocol SQLayoutItem {
    // The real item if the current item is a proxy
    var sq_rootItem: NSObject? { get }
    
    // Closure decorations
    var sq_sizeCalculator: SQSizeCalculator? { get }
    var sq_frameCalculator: SQFrameCalculator? { get }
    var sq_sizingFrameCalculator: SQFrameCalculator? { get }
    var sq_spacingCalculator: SQSpacingCalculator? { get }
    var sq_paddingCalculator: SQPaddingCalculator? { get }
    var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? { get }
    var sq_layoutObserver: SQLayoutObserver? { get }
}

@objc
public protocol SQMutableLayoutItem: SQLayoutItem {
    // Mutable variables stored separately to avoid conflict with immutable property
    var mutable_sq_rootItem: NSObject? { get set }
    var mutable_sq_sizeCalculator: SQSizeCalculator? { get set }
    var mutable_sq_frameCalculator: SQFrameCalculator? { get set }
    var mutable_sq_sizingFrameCalculator: SQFrameCalculator? { get set }
    var mutable_sq_spacingCalculator: SQSpacingCalculator? { get set }
    var mutable_sq_paddingCalculator: SQPaddingCalculator? { get set }
    var mutable_sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? { get set }
    var mutable_sq_layoutObserver: SQLayoutObserver? { get set }
}

///
/// A wrapper object used to store mutable decorator customizations added to wrapped objects.
///
@objcMembers
public class SQMutableProxyLayoutItem: NSObject, SQMutableLayoutItem {
    
    // MARK: - Initializer
    init(rootItem: NSObject) {
        self.mutable_sq_rootItem = rootItem.sq_rootItem ?? rootItem
    }
    
    // MARK: - SQMutableLayoutItem
    public var mutable_sq_rootItem: NSObject?
    public var mutable_sq_sizeCalculator: SQSizeCalculator?
    public var mutable_sq_frameCalculator: SQFrameCalculator?
    public var mutable_sq_sizingFrameCalculator: SQFrameCalculator?
    public var mutable_sq_spacingCalculator: SQSpacingCalculator?
    public var mutable_sq_paddingCalculator: SQPaddingCalculator?
    public var mutable_sq_layoutOptionsCalculator: SQLayoutOptionsCalculator?
    public var mutable_sq_layoutObserver: SQLayoutObserver?
        
    // MARK: - SQLayoutItem
    override public var sq_rootItem: NSObject? { mutable_sq_rootItem }
    override public var sq_sizeCalculator: SQSizeCalculator?
        { mutable_sq_sizeCalculator ?? mutable_sq_rootItem?.sq_sizeCalculator }
    override public var sq_frameCalculator: SQFrameCalculator?
        { mutable_sq_frameCalculator ?? mutable_sq_rootItem?.sq_frameCalculator }
    override public var sq_sizingFrameCalculator: SQFrameCalculator?
        { mutable_sq_sizingFrameCalculator ?? mutable_sq_rootItem?.sq_sizingFrameCalculator }
    override public var sq_spacingCalculator: SQSpacingCalculator?
        { mutable_sq_spacingCalculator ?? mutable_sq_rootItem?.sq_spacingCalculator }
    override public var sq_paddingCalculator: SQPaddingCalculator?
        { mutable_sq_paddingCalculator ?? mutable_sq_rootItem?.sq_paddingCalculator }
    override public var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator?
        { mutable_sq_layoutOptionsCalculator ?? mutable_sq_rootItem?.sq_layoutOptionsCalculator }
    override public var sq_layoutObserver: SQLayoutObserver?
        { mutable_sq_layoutObserver ?? mutable_sq_rootItem?.sq_layoutObserver }
}

///
/// Extension that supports declaring custom calculators with handy .withXYZ chaining decorator
/// syntax, to customize functionality to an object when used as an arranged item e.g:
///
/// item = view
///     .withSQSizeCalculator({...})
///     .withSQSpacingCalculator({...})
///
@objc
public extension NSObject {

    // MARK: - Public Decorators (closures)
    func withSQSizeCalculator(_ c: @escaping SQSizeCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_sizeCalculator = c }
    }
    func withSQFrameCalculator(_ c: @escaping SQFrameCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_frameCalculator = c }
    }
    func withSQSizingFrameCalculator(_ c: @escaping SQFrameCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_sizingFrameCalculator = c }
    }
    func withSQSpacingCalculator(_ c: @escaping SQSpacingCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_spacingCalculator = c }
    }
    func withSQPaddingCalculator(_ c: @escaping SQPaddingCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_paddingCalculator = c }
    }
    func withSQLayoutOptionsCalculator(_ c: @escaping SQLayoutOptionsCalculator) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_layoutOptionsCalculator = c }
    }
    func withSQLayoutObserver(_ c: @escaping SQLayoutObserver) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_layoutObserver = c }
    }

    // MARK: - Public Decorator (conveniences for constant return values)
    func withSQSize(_ size: CGSize) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_sizeCalculator = {_ in size} }
    }
    func withSQFrame(_ frame: CGRect) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_frameCalculator = {_ in frame} }
    }
    func withSQSizingFrame(_ frame: CGRect) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_sizingFrameCalculator = {_ in frame} }
    }
    func withSQSpacing(_ spacing: UIEdgeInsets) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_spacingCalculator = {_ in spacing} }
    }
    func withSQPadding(_ padding: UIEdgeInsets) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_paddingCalculator = {_ in padding} }
    }
    func withSQLayoutOptions(_ options: SQLayoutOptions) -> NSObject & SQLayoutItem {
        return mutableLayoutItem() { $0.mutable_sq_layoutOptionsCalculator = {_ in options} }
    }
    
    // MARK: - Private
    private func mutableLayoutItem(_ initialization: @escaping (SQMutableLayoutItem) -> Void) -> NSObject & SQLayoutItem {
        // Return self if already a mutable proxy, else wrap it in one
        let item = self as? NSObject & SQMutableLayoutItem ?? SQMutableProxyLayoutItem(rootItem: self)
        initialization(item)
        return item
    }
}


///
/// Add default properties for layout items
///
@objc
extension NSObject: SQLayoutItem {

    // MARK: - SQLayoutItem
    public var sq_rootItem: NSObject? { return self }
    public var sq_sizeCalculator: SQSizeCalculator? { nil }
    public var sq_frameCalculator: SQFrameCalculator? { nil }
    public var sq_sizingFrameCalculator: SQFrameCalculator? { nil }
    public var sq_spacingCalculator: SQSpacingCalculator? { nil }
    public var sq_paddingCalculator: SQPaddingCalculator? { nil }
    public var sq_layoutOptionsCalculator: SQLayoutOptionsCalculator? { nil }
    public var sq_layoutObserver: SQLayoutObserver? { nil }
}
