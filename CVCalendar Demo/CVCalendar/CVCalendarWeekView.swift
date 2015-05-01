//
//  CVCalendarWeekView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarWeekView: UIView {
    // MARK: - Non public properties
    private var interactiveView: UIView!
    
    override var frame: CGRect {
        didSet {
            if let calendarView = calendarView {
                if calendarView.calendarMode == CVCalendarViewMode.WeekView {
                    updateInteractiveView()
                }
            }
        }
    }
    
    private var touchController: CVCalendarTouchController {
        return CVCalendarTouchController.sharedTouchController
    }
    
    // MARK: - Public properties
    
    weak var monthView: CVCalendarMonthView!
    var dayViews: [CVCalendarDayView]!
    var index: Int!
    
    var weekdaysIn: [Int : [Int]]?
    var weekdaysOut: [Int : [Int]]?
    var utilizable = false /// Recovery service.
    
    weak var calendarView: CVCalendarView! {
        get {
            var calendarView: CVCalendarView!
            safeExecuteBlock({
                calendarView = self.monthView!.calendarView!
            }, collapsingOnNil: false, withObjects: monthView)
            
            return calendarView
        }
    }
    
    // MARK: - Initialization

    init(monthView: CVCalendarMonthView, frame: CGRect, index: Int) {
        super.init()
        
        self.monthView = monthView
        self.frame = frame
        self.index = index
        
        // Get weekdays in.
        let weeksIn = self.monthView!.weeksIn!
        self.weekdaysIn = weeksIn[self.index!]
        
        // Get weekdays out.
        if let weeksOut = self.monthView!.weeksOut {
            if self.weekdaysIn?.count < 7 {
                if weeksOut.count > 1 {
                    let daysOut = 7 - self.weekdaysIn!.count
                    
                    var result: [Int : [Int]]?
                    for weekdaysOut in weeksOut {
                        if weekdaysOut.count == daysOut {
                            let manager = CVCalendarManager.sharedManager
                            
                            
                            let key = weekdaysOut.keys.first!
                            let value = weekdaysOut[key]![0]
                            if value > 20 {
                                if self.index == 0 {
                                    result = weekdaysOut
                                    break
                                }
                            } else if value < 10 {
                                if self.index == manager.monthDateRange(self.monthView!.date!).countOfWeeks - 1 {
                                    result = weekdaysOut
                                    break
                                }
                            }
                        }
                    }
                    
                    self.weekdaysOut = result!
                } else {
                    self.weekdaysOut = weeksOut[0]
                }
                
            }
        }

        self.createDayViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Interactive view setup & management

extension CVCalendarWeekView {
    func updateInteractiveView() {
        safeExecuteBlock({
            
            let mode = self.monthView!.calendarView!.calendarMode!
            if mode == .WeekView {
                if let interactiveView = self.interactiveView {
                    interactiveView.frame = self.bounds
                    interactiveView.removeFromSuperview()
                    self.addSubview(interactiveView)
                } else {
                    self.interactiveView = UIView(frame: self.bounds)
                    self.interactiveView.backgroundColor = .clearColor()
                    
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTouchInteractiveView:")
                    let pressRecognizer = UILongPressGestureRecognizer(target: self, action: "didPressInteractiveView:")
                    pressRecognizer.minimumPressDuration = 0.3
                    
                    self.interactiveView.addGestureRecognizer(pressRecognizer)
                    self.interactiveView.addGestureRecognizer(tapRecognizer)
                    
                    self.addSubview(self.interactiveView)
                }
            }
            
            }, collapsingOnNil: false, withObjects: monthView, monthView?.calendarView)
    }
    
    func didPressInteractiveView(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        let state: UIGestureRecognizerState = recognizer.state
        
        switch state {
        case .Began:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Range(.Started))
        case .Changed:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Range(.Changed))
        case .Ended:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Range(.Ended))
            
        default: break
        }
    }
    
    func didTouchInteractiveView(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(self.interactiveView)
        touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .Single)
    }
}

// MARK: - Content fill & reload

extension CVCalendarWeekView {
    func createDayViews() {
        dayViews = [CVCalendarDayView]()
        let renderer = CVCalendarRenderer.sharedRenderer()
        for i in 1...7 {
            let frame = renderer.renderDayFrameForMonthView(self, dayIndex: i-1)
            let dayView = CVCalendarDayView(weekView: self, frame: frame, weekdayIndex: i)
            
            safeExecuteBlock({
                self.dayViews!.append(dayView)
                }, collapsingOnNil: true, withObjects: dayViews)
            
            addSubview(dayView)
        }
    }
    
    func reloadDayViews() {
        let renderer = CVCalendarRenderer.sharedRenderer()
        
        safeExecuteBlock({
            for (index, dayView) in enumerate(self.dayViews!) {
                let frame = renderer.renderDayFrameForMonthView(self, dayIndex: index)
                dayView.frame = frame
                dayView.reloadContent()
            }
        }, collapsingOnNil: true, withObjects: dayViews)
    }
}

// MARK: - Safe execution

extension CVCalendarWeekView {
    func safeExecuteBlock(block: Void -> Void, collapsingOnNil collapsing: Bool, withObjects objects: AnyObject?...) {
        for object in objects {
            if object == nil {
                if collapsing {
                    fatalError("Object { \(object) } must not be nil!")
                } else {
                    return
                }
            }
        }
        
        block()
    }
}
