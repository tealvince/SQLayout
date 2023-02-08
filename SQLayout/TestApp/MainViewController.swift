//
//  MainViewController.swift
//  SQLayout
//
//  Created by Vince Lee on 2/5/23.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        // Define and add content view
        let contentView = SQLayoutView.contentView(addedTo: view, layoutGuide: view.safeAreaLayoutGuide, layoutInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))

        // Add an auto-sized wrapper
        let wrapper = SQLayoutView(layoutInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        wrapper.backgroundColor = UIColor.lightGray
        contentView.addArrangedItem(wrapper)
        
        func testView(_ s: String, _ col: UIColor) -> UIView {
            let view = UILabel()
            view.text = s
            view.backgroundColor = col
            return view
        }
        
        // Fill it with a bunch of arranged views to test various layout calculators
        let view1 = testView("container-center", UIColor.red)
        let view2 = testView("right-aligned", UIColor.green)
        let view3 = testView("left-aligned", UIColor.blue)
        let view4 = testView("center", UIColor.orange)
        let view5 = testView("container-right-aligned", UIColor.green)
        let view6 = testView("container-left-aligned", UIColor.blue)
        let view7 = testView("container-center", UIColor.orange)
        let view8 = testView("container full width", UIColor.purple)
        let view9 = testView("flow short", UIColor.magenta)
        let view10 = testView("flow longer", UIColor.magenta)
        let view11 = testView("flow longest", UIColor.magenta)
        let view12 = testView("flow middle", UIColor.magenta)
        let view13 = testView("hub", UIColor.yellow)
        let view14 = testView("leaf", UIColor.red)
        let view15 = testView("leaf", UIColor.red)
        let view16 = testView("leaf", UIColor.red)
        let view17 = testView("leaf", UIColor.red)
        let view18 = testView("leaf", UIColor.red)
        let view19 = testView("leaf", UIColor.red)
        let view20 = testView("leaf", UIColor.red)
        let view21 = testView("leaf", UIColor.red)
        let view22 = testView("bottom-left", UIColor.green)
        let view23 = testView("bottom-right", UIColor.green)

        wrapper.addArrangedItem(view1
            .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
        )
        wrapper.addArrangedItem(view2
            .withSQFrameCalculator(SQLayoutCalculators.rightAlignedVStack)
        )
        wrapper.addArrangedItem(view3
            .withSQFrameCalculator(SQLayoutCalculators.leftAlignedVStack)
        )
        wrapper.addArrangedItem(view4
            .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
        )
        wrapper.addArrangedItem(view5
            .withSQFrameCalculator(SQLayoutCalculators.containerRightAlignedVStack)
        )
        wrapper.addArrangedItem(view6
            .withSQFrameCalculator(SQLayoutCalculators.containerLeftAlignedVStack)
        )
        wrapper.addArrangedItem(view7
            .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
        )
        wrapper.addArrangedItem(view8
            .withSQFrameCalculator(SQLayoutCalculators.containerWidthVStack)
        )
        wrapper.addArrangedItem(view9
            .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
        )
        wrapper.addArrangedItem(view10
            .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
        )
        wrapper.addArrangedItem(view11
            .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
        )
        
        // Content spacing examples
        
        wrapper.addArrangedItem(view12
            .withSQFrameCalculator(SQLayoutCalculators.topAlignedFlow)
            .withSQContentSpacing(UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0))
        )
        wrapper.addArrangedItem(view13
            .withSQFrameCalculator(SQLayoutCalculators.containerCenterAlignedVStack)
            .withSQContentSpacing(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        )

        // NoPrevious option examples
        
        wrapper.addArrangedItem(view14
            .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStackUp)
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        wrapper.addArrangedItem(view15
            .withSQFrameCalculator(SQLayoutCalculators.centerAlignedVStack)
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        wrapper.addArrangedItem(view16
            .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStack)
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        wrapper.addArrangedItem(view17
            .withSQFrameCalculator(SQLayoutCalculators.centerAlignedHStackLeft)
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        
        // Frame calculator composition examples
        
        wrapper.addArrangedItem(view18
            .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), -40, 10) }
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        wrapper.addArrangedItem(view19
            .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStackUp(args), 40, 10) }
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        wrapper.addArrangedItem(view20
            .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), -40, -10) }
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        wrapper.addArrangedItem(view21
            .withSQFrameCalculator { args in CGRectOffset(SQLayoutCalculators.centerAlignedVStack(args), 40, -10) }
            .withSQLayoutOptions(SQLayoutOptions(saveAsPrevious: false))
        )
        wrapper.addArrangedItem(view22
            .withSQFrameCalculator(SQLayoutCalculators.containerBottomLeftAligned)
            .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
        )
        wrapper.addArrangedItem(view23
            .withSQFrameCalculator(SQLayoutCalculators.containerBottomRightAligned)
            .withSQLayoutOptions(SQLayoutOptions(shouldIgnoreWhenCalculatingSize: true))
        )
    }
}

