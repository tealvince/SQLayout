# SQLayout
Sequential Layout Classes and Demo App For iOS
Vince Lee
Feb 7, 2023

-- THIS IS A WORK IN PROGRESS --

Sequential Layout is system for laying out UIKit views using a declarative syntax that is highly readable and encourages code reuse.  It breaks out the code normally used to manually size and layout views into blocks that are attached as decorators to arranged subviews.  These blocks retain all the flexibility of manual layout while encouraging reuse that simplifies and accelerates development.

## How it works

Traditional layout code usually looks something like the following.  The views to layout are sequentially sized, then laid out, with a running offsets carried forward each successive view.  While this works, the endless cycle of sizing, offsetting, and setting of each view's frame ends up duplicating a lot of very similar code.

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

With Sequential Layout Views, a container wrapper view enumerates over its arranged subviews, which define their layout logic via "calculators" that are added as decorators of each view to define the layout, spacing, and insets.  Since layout logic is passed details about the container and the previous object laid out, they can usually be replaced with a set of premade standard calculators.  They can still be defined with custom code, however, or made by composing existing calculators.

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

The code above is all that is needed to add views that layout in the content view and for the content view to calculate a size to fit its contents.


## Use cases

Sequential layout views can be a useful tool to keep in the toolbox to solve some problems that existing layout methods don't handle well.  Unlike most container-based layout (stack views, etc), Sequential Layout Views let each view define for itself how to layout relative to its parent container and a previous item that has already been laid out.  

This allows for much more flexibility for a layout to change dynamically based on available space or external conditions.  For instance, unlike in Autolayout, implementing a flow (reading order) layout is trivial in Sequential Layout Views, as it simply involves composing a horizontal-stack layout and left-aligned vertical stack depending on available space (indeed, standard flow layout calculators are already provided).

Similarly, handling optional subviews that appear or disappear is simpler, as the calculators for laying out of most subviews are already isolated from each other via "previous" references passed down from the container view.

Lastly, defining spacing, sizing, and layouts via calculators allows greater flexibility to compute and adjust these parameters dynamically based on available space and external conditions, following a "set-it-and-forget-it" approach instead of having to recompute constraints when conditions change.





