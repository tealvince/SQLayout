# SQLayout

Sequential Layout Views for iOS
Vince Lee  

Created: Feb 7, 2023  
Updated: Feb 5, 2024

## What it is

Sequential Layout is container view for laying out UIKit views using a declarative syntax that is highly readable and encourages code reuse.  It breaks out the code normally used to manually size and layout views into blocks that are attached as decorators to arranged subviews.  These blocks retain all the flexibility of manual layout while encouraging reuse that simplifies and accelerates development.

## What it isn't

Sequential Layout isn't a typical layout "system" per-se, in that it does not define a fixed set of components or layout methods/options that a user must use.  Instead, it only defines a single flexible layout container view (SQLayoutView) which works with any UIView subviews (or itself as a subview within existing UIViews) and whose functionality is almost entirely defined via decorator blocks defined by the user.  While a large set of predefined blocks are provided for convenience, one is free to use them, compose them, or ignore them in favor of custom code.

## How it works

Typical layout code usually looks something like the following.  The views to layout are sized and laid out one at at time, with various running offsets carried forward to each successive view to allow views to accomodate each other.  While this works, the endless cycle of sizing, offsetting, and setting of each view's frame results tends to ends up with unmanageably long functions with a lot of duplicated, similar-looking code.

```
    override func layoutSubviews() {
        super.layoutSubviews

        let layoutBounds = self.contentView.bounds
        var x = 0
        var y = 0

        let titleSize = self.titleLabel.sizeThatFits(layoutBounds.size.width, CGFloat.max)
        self.titleLabel.frame = CGRectMake(x, y, titleSize.width, titleSize.height)
        y += titleSize.height + 20

        ....
    }
```

With Sequential Layout views, a container wrapper view (SQLayoutView) contains and manages one or more arrangedItems.  It enumerates over its arranged subviews when layoutSubviews is called, but unlike other container-based layout methods, the logic resides with code associated with each subview, not with the container.

Instead, each arranged subview defines its own behavior based on "calculator" blocks that decorate it.  Note that calculator blocks are specified when a subview is added to the layout container view, and thus don't require subclassing or modifying the subviews themselves.  These calculators define the layout, sizing, spacing, and insets of each view.  Since each calculator is passed the information it needs in a modular way, the calculators are usually reusable and can often replaced with a set of premade standard calculators defined in SQLayoutCalculators.  They can still be defined with custom code, however, or made by composing existing calculators to handle unique edge cases.

## Example

The following is a simple example of five subviews, two vertically stacked labels followed by three buttons laid out using a flow (reading order) layout:
```
    let contentView = SQLayoutView.contentView(addedTo: view, layoutGuide: view.safeAreaLayoutGuide)

    contentView.addArrangedItem(self.titleLabel
        .withSQFrameCalculator(SQLayoutCalculators.containerLeftAlignedVStack)
    )
    contentView.addArrangedItem(self.subtitleLabel
        .withSQFrameCalculator(SQLayoutCalculators.containerLeftAlignedVStack)
    )
    contentView.addArrangedItem(self.skipButton
        .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
        .withSQSpacing(UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    )
    contentView.addArrangedItem(self.moreButton
        .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
    )
    contentView.addArrangedItem(self.cancelButton
        .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
    )


   ┌────────────────────────────┐
   │  Title Label               │
   │  Subtitle Label            │
   │                            │
   │  ┌──────────┐ ┌─────────┐  │
   │  │   skip   │ │   more  │  │  <-- flow layout places as many on line as will fit, then wraps
   │  └──────────┘ └─────────┘  │
   │  ┌────────────┐            │
   │  │   cancel   │            │
   │  └────────────┘            │
   └────────────────────────────┘
```

The code above is all that is needed to add views that layout in the content view and for the content view to calculate a size to fit its contents.  In fact, since containerLeftAlignedVStack is the default frame calculator, this can be simplified using an optional "chaining" methods in SQLayoutView into a single statement:

```
    let contentView = SQLayoutView.contentView(addedTo: view, layoutGuide: view.safeAreaLayoutGuide)
        .containingArrangedItem(self.titleLabel)
        .containingArrangedItem(self.subtitleLabel)
        .containingArrangedItem(self.skipButton
            .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            .withSQSpacing(UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        )
        .containingArrangedItem(self.moreButton.withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow))
        .containingArrangedItem(self.cancelButton.withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow))
```


## Benefits

In addition to providing a readable alternative to manual layout, Sequential Layout views can be a useful tool to keep in the toolbox to solve some problems that existing layout methods don't handle well.

* Easily readable declarative format - designed for a set-it-and-forget-it approach

* UIKit Support - supports existing subclasses of UIView directly without adapters or additional view controllers or modifying views

* Objective C - supports Objective-C

* Handles wrapped text - passes down bounding sizes naturally in nested view hierarchies, avoiding the need to manually calculate and update preferredMaxLayoutWidth in order to support multiline text items.

* Dynamic calculation - All spacing, sizing, and insets are customizable with calculator blocks, not constants, allowing dynamic behavior to be setup in advance, avoiding the need to constantly recalculate contraints when conditions change.

* Modularity - Frame calculators are structured to maximize reusabilty, and indeed the framework includes a library of commonly used calculators that can be used directly or composed to handle most use cases.

* Flexibility - Unlike most container-based layout (stack views, etc), Sequential Layout views let each view customize how it is laid out, aligned, sized, and spaced relative to its parent container and a previous item.  Default calculators can still be specified for an enclosing layout view if one chooses, however.

* Decorator pattern - Using decorators applied to each arranged subview avoid the need to subclass or modify a view just to override its intrinsicContentSize or other properties.

* Encapsulation - Decorators allow most of the logic for a subview to be associated and grouped with the code defining the subview item itself, unlike constraints that tend to span multiple views making them difficult to read and maintain.

* Nesting - Layout views are designed to be nestable, allowing more complex layouts to be created.  Note that special attention should be given to setup nested views for automatic sizing.  More of this is described under advanced topics below.


## Decorators

Layout items (usually subviews) can be "decorated" by using a .withSQxxx() method to attach additional information about how the view should be laid out.  While layout items have default behavior and decorators are all optional, adding them allows one to customized the layout.  In addition, a .containingXXX() method can be set on a layout view to set default behavior for all its arranged items at once.

* Frame calculator - given information about the bounds of the containing view and the subview previously laid out, a frame calculator does the work of layout and returns the frame after layout.  For many use cases, a predefined calculator in SQLayoutCalculators can be used as is.

* Sizing frame calculator - for advanced layout cases, a separate frame calculator can be specified for sizing operations, particularly when laying out subviews with mixed alignments.  See advanced topics for more information.

* Size calculator - returns the size for a view given a size to fit into.  This is used by some frame calculators to get the intrinsic height, width, or both values for an item.  By default, view items call sizeThatFits, which is sufficient for most view types.

* Spacing calculator - returns the minimum spacing requested between the current object and previous/next objects during layout.  Defined as a UIEdgeInset, calculators use the appropriate pair of insets (e.g. top/bottom, left/right) between two views and adjust spacing so that both views get at least the minimum spacing between them in the relevant paired directions.

* Padding calculator - content padding simply informs calculators to adjust a frame's position so that extra empty space is added both from a previous/next object and container bounds.  Unlike content spacing, padding is always additive regardless of whether a previous/next object has its own padding.  Padding can be negative to eliminate empty space within a subview, such as the inset around a UITextView or borderless UIButton.  Properly written frame calculators also adjust for padding in the fittingSize passed to a size calculator.

* Options calculator - returns values to make adjusments to layout behavior, often in response to external conditions.  Values include shouldSkipLayout (item is ignored as if it wasn't an arranged item), shouldIgnoreWhenCalculatingSize (item is laid out but not counted in the "occupied bounds" check that determines the calculated size of the view container), or saveAsPrevious (if false, the "previous" reference passed to the next item during layout isn't updated to reflect the current item so the next item sees the same "previous" item as us).

* LayoutObserver - called when item layout has been performed on an arranged item.  For view-based items, the default implementation calls setFrame with the frame value passed in.  For sequential layout with non-view based items and containers, this can be used to store off a calculated view frame into a view model or other layoutState object for later use.


## Tutorial

The following example code demonstrates how to use sequential layout to create a simple prompt view.  Each of the sub-views is added to the layoutView one at-a-time.  While doing so, each can be decorated with a method call to customize how to place or size it relative to the container or the previous sub-view.
 
```
    // First, we create a layout view and add it as an autosized subview 
    // of our view.  We can do this manually, but here we use a convenience
    // method to create the layout view, add it as a subview, and set the 
    // appropriate layout constraints in a single method

    let layoutView = SQLayoutView.addAutosizedView(to: self.view, layoutInsets: .zero)

    // Assuming we have already created some subviews (titleLabel and subtitleLabel), we add
    // them to our layoutView.  The default frame calculator lays out items vertically aligned
    // at the left edge of the layoutView, so we can just add them to get this default
    // behavior.

    layoutView.addArrangedItem(titleLabel)
    layoutView.addArrangedItem(subtitleLabel)

    // Now we want to add an action button, but have it expanded to the full width 
    // of the content view instead of left-aligned at the intrinsic width.  So we
    // add it but append a decorator to specify an alternate frame calculator

    layoutView.addArrangedItem(actionButton
        .withSQFrameCalculator(SQLayoutCalculators.containerFullWidthVStack)
    )

    // Lastly, we'll add a footer label, centered in the parent view with some 
    // additional spacing on top

    layoutView.addArrangedItem(footerLabel
        .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
        .withSQSpacing(UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
    )

   ┌────────────────────────────┐
   │  Title Label               │
   │  Subtitle Label            │
   │  ┌──────────────────────┐  │
   │  │     action button    │  │
   │  └──────────────────────┘  │
   │                            │
   │        Footer Label        │
   └────────────────────────────┘
```

The code above is spaced out to describe each step individually.  Alternatively, we can use the containingArrangedItem() chaining method to simplify the above code. At the same time, let's say we want to space out the items vertically by 10 px, except for the space above the footer which we'll keep at 20.  We can do this with the containingDefaultSpacing() chaining method on the layoutView:

```
    let layoutView = SQLayoutView.addAutosizedView(to: self.view, layoutInsets: .zero)
        .containingArrangedItem(titleLabel)
        .containingArrangedItem(subtitleLabel)
        .containingArrangedItem(actionButton
            .withSQFrameCalculator(SQLayoutCalculators.containerFullWidthVStack)
        )
        .containingArrangedItem(footerLabel
            .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
            .withSQSpacing(UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        )
        .containingDefaultSpacing(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
```

Now let's say we want to support multiple action buttons, and have the row of them centered horizontally in the container view.  Since centering a group along the same axis we are adding them cannot be done sequentially, we can wrap the group in another layout view to accomplish this:

```
    let layoutView = SQLayoutView.addAutosizedView(to: self.view, layoutInsets: .zero)
        .containingArrangedItem(titleLabel)
        .containingArrangedItem(subtitleLabel)
        .containingArrangedItem(SQLayoutView()
            .containingArrangedItem(actionButton1)
            .containingArrangedItem(actionButton2)
            .containingArrangedItem(actionButton3)
            .containingDefaultFrameCalculator(SQLayoutCalculators.topAlignedHStack)
            .containingDefaultSpacing(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
            .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
        )
        .containingArrangedItem(footerLabel
            .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
            .withSQSpacing(UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        )
        .containingDefaultSpacing(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))

   ┌────────────────────────────┐
   │  Title Label               │
   │  Subtitle Label            │
   │    ┌────┐ ┌────┐ ┌────┐    │
   │    │act1│ │act2│ │act3│    │  <-- use nesting to center row of buttons together as a unit
   │    └────┘ └────┘ └────┘    │
   │                            │
   │        Footer Label        │
   └────────────────────────────┘
```

Note that the "with...()" decorator methods can be applied to any layoutItem and determine their layout inside an enclosing layoutView, while the "containing...()" methods only apply to the layoutView containers themselves and set defaults for all layoutItems inside.  In this example, the buttons are wrapped by a layoutView that is itself also a layoutItem, so it has both "with..." and "containing..." methods called on it.

## Advanced topics

### Autosizing

SQLayoutViews themselves support sizeThatFits, which in turn powers the default size calculator when the layout view is nested as an item inside another layout view.  To calculate size automatically, the layout view does a "dry" layout into the fitting bounds given and returns the size of the smallest bounds containing all the arranged subviews in the test layout.  

While this works for many use cases, it can break if the enclosed subviews can expand based on the size of the enclosing container.  For instance, if a layout contains both left-aligned and right-aligned members, the resulting calculated size will always grow to the full width of the fitting size passed in.  While this prevents proper autosizing to "minimum" bounds, it is not an issue when a layout view is set to known finite bounds (such as screen size) and laying out to use all available space is the desired effect.

To avoid support size calculation in the above case, one can optionally specify a different frame calculator for use only during sizing operations.  By keeping consistent alignment, automatic size calculation can still be used.  For example, consider a horizontal row of items that we want to be aligned by their vertical centers, but with one item that should be top-aligned:

```
    let rowLayoutView = SQLayoutView()
        .containingArrangedItem(iconImageView)
        .containingArrangedItem(titleLabel)
        .containingArrangedItem(actionButton)
        .containingArrangedItem(badgeIconView.withSQFrameCalculator(SQLayoutCalculators.topAlignedHStack))
        .containingDefaultFrameCalculator(SQLayoutCalculators.centerAlignedHStack)
```

In this case, the mixed top-aligned badge view and center-aligned other views would cause rowLayoutView to return a ridiculously tall height in response to rowLayoutView.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max)).  To fix this, we can add the following line to use a top-aligned calculator when sizing items in the row, which will still give the correct height for the layout view equal to the height of the tallest arranged item:

```
        .containingDefaultSizingFrameCalculator(SQLayoutCalculators.topAlignedHStack)
```

Another edge case can occur with decorative views that size automatically with the layout view.  For instance, if we add a background view that matches the container, the layoutView would always return the fittingSize passed into sizeThatFits:

```
        .containingArrangedItem(backgroundView.withSQFrameCalculator(SQLayoutCalculators.matchContainer))
```

To avoid this, we can add a decorator to specify the option to ignore the view's frame during container sizing operations:

```
        .containingArrangedItem(backgroundView
            .withSQFrameCalculator(SQLayoutCalculators.matchContainer)
            .withSQOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
        )
```

### Unpadding

A negative padding value can be used to ignore any whitespace built into an arranged subview when positioning it.  This is useful for views such as borderless text buttons where we want to position relative to the text inside rather than the invisible button bounds.  For more fine-tuned layout, we can also use negative padding to layout text labels to their baseline and upper capHeight rather than the invisible font container boundary.  To do so, set the padding equal to the negative value that each edge should be inset. 

### Save as previous

By default, views are laid out sequentially, with each view receiving the bounds of the previous one.  Sometimes, however, this is not useful.  For example, consider an avatar view that has a badge overlay in one corner.  It is natural to add the badge after the avatar view so it can size and layout relative to the avatar bounds, but it is unlikely that a view following the avatar would find the badge bounds to be useful.

```
        .containingArrangedItem(avatarView)
        .containingArrangedItem(badgeIconView
            .withSQFrameCalculator(SQLayoutCalculators.topRightAligned)
        )
        .containingArrangedItem(usernameLabel) // appears on top of avatar instead of below it
```

While wrapping the avatar and badge together in a nested layoutView could be used to work around this, disabling the saveAsPrevious flag can also be used.  When set on an arranged item, the next view to be laid out sees the same "previous" value as the flagged view.

```
        .containingArrangedItem(avatarView)
        .containingArrangedItem(badgeIconView
            .withSQFrameCalculator(SQLayoutCalculators.topRightAligned)
            .withSQOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        .containingArrangedItem(usernameLabel) // is now positioned below avatar view
```

### Non-view based layout

The Sequential Layout framework and calculators can also be used to calculate frames for non-UIView objects.  This can be used, for instance, to precalculate subview frames to be stored in "layoutState" objects before the views themselves have even been created.  To do this, use any appropriate NSObject representing each rectangle as the items, and add them directly to an instance of SQLayoutContainer.  Each calculator will get a reference to the item in the sq_rootItem property.  Attach a "layoutObserver" to each object to store off the frame values whenever they are calculated during layout, and call layoutItems() to start the layout process.

### Custom frame calculators

Frame calculators are just functions/closures that return a CGRect based on a SQFrameCalculatorArgs argument that describes the item, previous item, and layout container.  As such it is straightforward to write custom code to handle a unique situation not covered by a standard calculator.  The following best practices should be used observed to make a reusable calculator:

* Any spacing calculated relative to a previous object should observer the minimum spacing requested by the current object and previous object in the appropriate corresponding directions.  For instance, if placing a view below the previous item, the spacing used should be max(previous.spacing.bottom, current.spacing.top)

* To properly handle padding requested for an item, any fittingSize passed to the sizeCalculator for an item should first subtract off any the padding insets set on that item.  Then, when calculating the frame for an item, its position should be adjusted so that the requested padding exists between it and neighboring objects (padding is outside the frame of the view)

* Handle the absense of a previous item in a sensible way.  Often, this consists of laying out relative to the container.  For instance, if a frame calculator is intended to layout left of the previous item, it might make sense to place an item at the right edge of the container layout margin if it is the first item to be laid out.  This would allow the frame calculator to be used as the sole default frame calculator in a layoutView and still yield expected results when items are just added to it.

