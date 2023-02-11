//
//  MainViewController.swift
//  SQLayout
//
//  Created by Vince Lee on 2/5/23.
//

import SQLayout
import UIKit

class MainViewController: UIViewController {

    // Create a label as a test view
    private func testView(_ s: String, _ col: UIColor) -> UIView {
        let view = UILabel()
        view.text = s
        view.backgroundColor = col
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        // Create and add content view
        let contentView = SQLayoutView.autosizedView(addedTo: view, layoutGuide: view.safeAreaLayoutGuide, layoutInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))

        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = "SQLayout Test"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)

        // Add as sequential layout item (defaults to left-aligned vstack layout)
        contentView.addArrangedItem(titleLabel)

        // Create wrapper
        let wrapper = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        wrapper.layer.cornerRadius = 10
        wrapper.backgroundColor = UIColor.lightGray
        
        // Add as auto-sized nested layout wrapper view
        // Fill it with a bunch of arranged views to test various layout calculators
        // Each line simply adds a test view, decorating it with any calculators to
        // define/customize its layout
        contentView.addArrangedItem(wrapper
            // Define arranged views here, chaining them for syntactic sugar (could also just add them individually)
            .containingArrangedItem(testView("container-center", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
            )
            .containingArrangedItem(testView("right-aligned", UIColor.darkGray)
                .withSQFrameCalculator(SQLayoutCalculators.rightAlignedVStack)
            )
            .containingArrangedItem(testView("left-aligned", UIColor.darkGray)
                .withSQFrameCalculator(SQLayoutCalculators.leftAlignedVStack)
            )
            .containingArrangedItem(testView("center", UIColor.darkGray)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
            )
            .containingArrangedItem(testView("container-right-aligned", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerRightAlignedVStack)
            )
            .containingArrangedItem(testView("container-left-aligned", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerLeftAlignedVStack)
            )
            .containingArrangedItem(testView("container-center", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
            )
            .containingArrangedItem(testView("container full width", UIColor.orange)
                .withSQFrameCalculator(SQLayoutCalculators.containerWidthVStack)
            )
            .containingArrangedItem(testView("flow short", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            )
            .containingArrangedItem(testView("flow longer", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            )
            .containingArrangedItem(testView("flow longest", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            )

            // Content spacing examples
            .containingArrangedItem(testView("flow middle", UIColor.green)
                .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
                .withSQSpacing(UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0))
            )
            .containingArrangedItem(testView("hub", UIColor.yellow)
                .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
                .withSQSpacing(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            )

            // NoPrevious option examples
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStackUp)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStack)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStackLeft)
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )

            // Frame calculator composition examples
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), -40, 10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), 40, 10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), -40, -10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("leaf", UIColor.red)
                .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), 40, -10) }
                .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
            )
            .containingArrangedItem(testView("bottom-left", UIColor.darkGray)
                .withSQFrameCalculator(SQLayoutCalculators.containerBottomLeftAligned)
                .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
            )
            .containingArrangedItem(testView("bottom-right", UIColor.darkGray)
                .withSQFrameCalculator(SQLayoutCalculators.containerBottomRightAligned)
                .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
            )
            // Add decorators for our wrapper view (must come after
            // addArrangedItem calls because it doesn't return a layoutView
            .withSQFrameCalculator(SQLayoutCalculators.containerCenterAligned)
        )
    }
}

