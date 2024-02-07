//
//  SQLayoutItemsBuilder.swift
//  SQLayout
//
//  Created by Vince Lee on 2/6/24.
//

import Foundation

///
/// A convenience result builder to support defining a layout items builder using declarative syntax
///
@resultBuilder
public struct SQLayoutItemsBuilder {
    public static func buildBlock(_ parts: any SQLayoutItem...) -> [any SQLayoutItem] {
        return parts
    }

    public static func buildArray(_ components: [any SQLayoutItem]) -> [any SQLayoutItem] {
        return components
    }

    public static func buildEither(first component: SQLayoutItem) -> SQLayoutItem {
        return component
    }

    public static func buildEither(second component: SQLayoutItem) -> SQLayoutItem {
        return component
    }
}
