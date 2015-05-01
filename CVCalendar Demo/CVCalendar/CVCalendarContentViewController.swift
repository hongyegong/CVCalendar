//
//  CVCalendarContentViewController.swift
//  CVCalendar Demo
//
//  Created by E. Mozharovsky on 1/28/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVCalendarContentViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Public Properties
    let calendarView: CalendarView!
    var presentedMonthView: MonthView!
    var bounds: CGRect {
        return scrollView.bounds
    }
    
    // MARK: - Private Properties
    private let scrollView: UIScrollView!
    private let delegate: ContentDelegate!

    // MARK: - Initialization 
    
    init(calendarView: CalendarView, frame: CGRect) {
        super.init()
        
        self.calendarView = calendarView
        self.scrollView = UIScrollView(frame: frame)
        
        // Setup Scroll View. 
        scrollView.contentSize = CGSizeMake(frame.width * 3, frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        
        presentedMonthView = MonthView(calendarView: calendarView, date: NSDate())
        
        if calendarView.calendarMode == CalendarMode.MonthView {
            delegate = MonthContentView(contentController: self)
        } else {
            delegate = WeekContentView(contentController: self)
        }
        
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Control 
    
    func preparedScrollView() -> UIScrollView {
        if let scrollView = self.scrollView {
            return scrollView
        } else {
            return UIScrollView()
        }
    }
    
    // MARK: - Appearance Update 
    
    func updateFrames(frame: CGRect) {
        presentedMonthView.updateAppearance(frame)
        
        scrollView.frame = frame
        scrollView.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height)
        
        delegate.updateFrames()
        
        calendarView.hidden = false
    }
    
    // MARK: - Scroll View Delegate 
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate.scrollViewDidScroll!(scrollView)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate.scrollViewWillBeginDragging!(scrollView)
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate.scrollViewDidEndDecelerating!(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate.scrollViewDidEndDragging!(scrollView, willDecelerate: decelerate)
    }
    
    // MARK: - Day View Selection
    
    func performedDayViewSelection(dayView: DayView) {
        delegate.performedDayViewSelection(dayView)
    }
    
    // MARK: - Toggle Date
    
    func togglePresentedDate(date: NSDate) {
        delegate.togglePresentedDate(date)
    }
    
    // MARK: - Paging 
    
    func presentNextView(dayView: DayView?) {
        delegate.presentNextView(dayView)
    }
    
    func presentPreviousView(dayView: DayView?) {
        delegate.presentPreviousView(dayView)
    }
    
    // MARK: - Days Out Showing
    
    func updateDayViews(hidden: Bool) {
        delegate.updateDayViews(hidden)
    }
}
