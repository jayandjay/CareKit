//
//  OCKEvaluationTableViewController.m
//  CareKit
//
//  Created by Umer Khan on 2/2/16.
//  Copyright © 2016 carekit.org. All rights reserved.
//


#import "OCKEvaluationTableViewController.h"
#import "OCKEvaluationTableViewCell.h"
#import "OCKEvaluationTableViewHeader.h"
#import "OCKHelpers.h"
#import "OCKCarePlanStore_Internal.h"
#import "OCKWeekPageViewController.h"


const static CGFloat CellHeight = 85.0;
const static CGFloat HeaderViewHeight = 100.0;

@implementation OCKEvaluationTableViewController {
    OCKWeekPageViewController *_weekPageViewController;
    NSArray<NSArray<OCKCarePlanEvent *> *> *_evaluationEvents;
    OCKEvaluationTableViewHeader *_headerView;
    NSDateFormatter *_dateFormatter;
}

+ (instancetype)new {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)init {
    OCKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithCarePlanStore:(OCKCarePlanStore *)store
                             delegate:(id<OCKEvaluationTableViewDelegate>)delegate {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Evaluations";
        _store = store;
        _delegate = delegate;
        _lastSelectedEvaluationEvent = nil;
        _store.checkupsUIDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedDate = [[OCKCarePlanDay alloc] initWithDate:[NSDate date]
                                                calendar:[NSCalendar currentCalendar]];
    
    [self fetchEvaluationEvents];
    [self prepareView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    OCKCarePlanDay *newDate = [[OCKCarePlanDay alloc] initWithDate:[NSDate date]
                                                          calendar:[NSCalendar currentCalendar]];
    
    if ([newDate isLaterThan:_selectedDate]) {
        _selectedDate = newDate;
    }
}

- (void)prepareView {
    if (!_headerView) {
        _headerView = [[OCKEvaluationTableViewHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HeaderViewHeight)];
    }
    [self updateHeaderView];
    
    _weekPageViewController = [[OCKWeekPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                 options:nil];
    _weekPageViewController.dataSource = self;
    
    self.tableView.tableHeaderView = _weekPageViewController.view;
    self.tableView.tableFooterView = [UIView new];
}

- (void)setSelectedDate:(OCKCarePlanDay *)selectedDate {
    _selectedDate = selectedDate;

    [self fetchEvaluationEvents];
}


#pragma mark - Helpers

- (void)fetchEvaluationEvents {
    [_store eventsOfDay:_selectedDate
                   type:OCKCarePlanActivityTypeAssessment
             completion:^(NSArray<NSArray<OCKCarePlanEvent *> *> * _Nonnull eventsGroupedByActivity, NSError * _Nonnull error) {
                 _evaluationEvents = eventsGroupedByActivity;
                 NSAssert(!error, error.localizedDescription);
                 [self updateHeaderView];
                 [self.tableView reloadData];
             }];
}

- (void)updateHeaderView {
    _headerView.date = [NSDateFormatter localizedStringFromDate:[self dateFromCarePlanDay:_selectedDate]
                                                      dateStyle:NSDateFormatterLongStyle
                                                      timeStyle:NSDateFormatterNoStyle];
    
    NSInteger totalEvents = _evaluationEvents.count;
    NSInteger completedEvents = 0;
    for (NSArray<OCKCarePlanEvent *> *events in _evaluationEvents) {
        OCKCarePlanEvent *evaluationEvent = events.firstObject;
        if (evaluationEvent.state == OCKCarePlanEventStateCompleted) {
            completedEvents++;
        }
    }
    _headerView.progress = (totalEvents > 0) ? (float)completedEvents/totalEvents : 0;
    
    _headerView.text = [NSString stringWithFormat:@"%@ of %@", [@(completedEvents) stringValue], [@(totalEvents) stringValue]];
}

- (OCKCarePlanDay *)dateFromSelectedIndex:(NSInteger)index {
    NSDate *oldDate = [self dateFromCarePlanDay:_selectedDate];
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitYear | NSCalendarUnitMonth
                                                                   fromDate:oldDate];
    
    NSDateComponents *newComponents = [NSDateComponents new];
    newComponents.year = components.year;
    newComponents.month = components.month;
    newComponents.weekOfMonth = components.weekOfMonth;
    newComponents.weekday = index;
    
    NSDate *newDate = [[NSCalendar currentCalendar] dateFromComponents:newComponents];
    return [[OCKCarePlanDay alloc] initWithDate:newDate calendar:[NSCalendar currentCalendar]];
}

- (NSDate *)dateFromCarePlanDay:(OCKCarePlanDay *)day {
    NSDateComponents *components = [NSDateComponents new];
    components.year = _selectedDate.year;
    components.month = _selectedDate.month;
    components.day = _selectedDate.day;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}


#pragma mark - OCKCarePlanStoreDelegate

- (void)carePlanStore:(OCKCarePlanStore *)store didReceiveUpdateOfEvent:(OCKCarePlanEvent *)event {
    [self fetchEvaluationEvents];
}

- (void)carePlanStoreEvaluationListDidChange:(OCKCarePlanStore *)store {
    [self fetchEvaluationEvents];
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    // TO DO: implementation
    // Calculate the date one week before the selected date.
    
    // Set the new date as the selected date.
    
    return pageViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    // TO DO: implementation
    
    // Check if the selected date is from current week, if it is then don't do anything.
    
    // Calculate the date one week after the selected date.
    
    // Set the new date as the selected date.
    
    return pageViewController;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return HeaderViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OCKCarePlanEvent *selectedEvaluationEvent = _evaluationEvents[indexPath.row].firstObject;
    _lastSelectedEvaluationEvent = selectedEvaluationEvent;

    if (_delegate &&
        [_delegate respondsToSelector:@selector(tableViewDidSelectRowWithEvaluationEvent:)]) {
        [_delegate tableViewDidSelectRowWithEvaluationEvent:selectedEvaluationEvent];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldHighlight = YES;
    OCKCarePlanEvent *event = _evaluationEvents[indexPath.row].firstObject;
    if (event.state == OCKCarePlanEventStateCompleted && !event.activity.resultResettable) {
        shouldHighlight = NO;
    }
    return shouldHighlight;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _evaluationEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EvaluationCell";
    OCKEvaluationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[OCKEvaluationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CellIdentifier];
    }
    cell.evaluationEvent = _evaluationEvents[indexPath.row].firstObject;
    return cell;
}

@end
