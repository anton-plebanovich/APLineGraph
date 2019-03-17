//
//  GraphVerticalAxis.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/16/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


private extension Constants {
    static let verticalGap: CGFloat = 8
    static let distanceToHelperView: CGFloat = 2
}


public extension Graph {
public final class VerticalAxis: Axis {
    
    // ******************************* MARK: - Public Properties
    
    var range: RelativeRange { didSet { update() } }
    
    // ******************************* MARK: - Private Properties
    
    private let minMaxRanges: [MinMaxRange]
    private let configuration: Graph.Configuration
    
    private lazy var helperViewsReuseController: ReuseController<UIView> = ReuseController<UIView> { [weak self] in
        guard let self = self else { return UIView() }
        
        let frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 1)
        let view = UIView(frame: frame)
        view.backgroundColor = self.configuration.helpLinesColor
        view.autoresizingMask = [.flexibleWidth]
        
        return view
    }
    
    private lazy var maxLabelSize: CGSize = {
        let height = Axis.labelFont.lineHeight
        let minValueStringWidth = minMaxRanges.map { $0.min }.min()?.asString.oneLineWidth(font: Axis.labelFont) ?? 0
        let maxValueStringWidth = minMaxRanges.map { $0.max }.max()?.asString.oneLineWidth(font: Axis.labelFont) ?? 0
        let width = Swift.max(minValueStringWidth, maxValueStringWidth)
        
        return CGSize(width: width, height: height)
    }()
    
    // ******************************* MARK: - Initialization and Setup
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(minMaxRanges: [MinMaxRange], configuration: Graph.Configuration) {
        self.minMaxRanges = minMaxRanges
        self.configuration = configuration
        self.range = .full
        
        super.init(frame: UIScreen.main.bounds)
        
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = false
    }
    
    // ******************************* MARK: - Axis Overrides
    
    override public func update() {
        queueAllLabels()
        helperViewsReuseController.queueAll()
        
        // TODO: It's hard to read need to do something with it
        let height = bounds.height
        
        let maxIndex = minMaxRanges.count.asCGFloat - 1
        let minRangeIndex = (maxIndex * range.from).rounded(.up).asInt
        let maxRangeIndex = (maxIndex * range.to).rounded(.down).asInt
        let selectedMinMaxRanges = minMaxRanges[minRangeIndex...maxRangeIndex]
        var min = selectedMinMaxRanges.map { $0.min }.min() ?? 0
        var max = selectedMinMaxRanges.map { $0.max }.max() ?? 0
        var size = max - min
        
        // Adjust min and max to match bottom and top gap
        let additionalSize = size / (1 - 2 * configuration.verticalPercentGap) - size
        min -= additionalSize / 2
        max += additionalSize / 2
        size += additionalSize
        
        let elementHeight = maxLabelSize.height + c.verticalGap
        let elementsCount = height / elementHeight
        let step = size / elementsCount
        
        // Choice divide mode with minimum step
        // Example:
        // min = 12
        // max = 278
        // elementsCount = 20.334
        // size = 266
        // step = 13.082
        
        // by10:
        // initialValue = 100
        // roundedStep = 100
        // values: [100, 200]
        
        let roundedStep = configuration.verticalAxisRegionDivideModes
            .map { $0.getRoundedStep(step: step) }
            .min() ?? step
        
        let initialValue = (min / roundedStep).rounded(.up) * roundedStep
        let values = stride(from: initialValue, to: max, by: roundedStep).map { $0 }
        var formattedValues = ValuesFormatter.shared.strings(from: values)
        
        values.forEach { value in
            let centerY = height * (1 - (value - min) / size)
            
            let label = dequeueLabel(text: formattedValues.removeFirst())
            label.center.y = centerY - maxLabelSize.height / 2 - c.distanceToHelperView
            addSubview(label)
            
            let view = helperViewsReuseController.dequeue()
            view.center.y = centerY
            addSubview(view)
        }
    }
}
}
