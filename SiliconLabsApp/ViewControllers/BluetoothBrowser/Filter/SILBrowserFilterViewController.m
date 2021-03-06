//
//  SILBrowserFilterViewController.m
//  BlueGecko
//
//  Created by Kamil Czajka on 14/01/2020.
//  Copyright © 2020 SiliconLabs. All rights reserved.
//

#import "SILBrowserFilterViewController.h"
#import "UIImage+SILImages.h"
#import "SILBrowserFilterViewModel.h"
#import "SILBluetoothBrowser+Constants.h"

@interface SILBrowserFilterViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UITextView *searchByDeviceNameTextView;
@property (weak, nonatomic) IBOutlet UIImageView *clearTextImageByDeviceName;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *beaconTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *minRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dBmValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *savedSearchesLabel;
@property (weak, nonatomic) IBOutlet UISlider *dBmSlider;
@property (weak, nonatomic) IBOutlet UIView *seachByDeviceNameView;
@property (weak, nonatomic) IBOutlet UILabel *favouriteAreaTitleLabel;
@property (weak, nonatomic) IBOutlet SILSwitch *favouriteSwitch;

@property (weak, nonatomic) IBOutlet UIButton *beaconTypeAreaButton;
@property (weak, nonatomic) IBOutlet UIButton *savedSearchesAreaButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *beaconTypeContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *savedSearchesContainerHeight;
@property (weak, nonatomic) IBOutlet UILabel *connectableTittleLabel;
@property (weak, nonatomic) IBOutlet SILSwitch *connectableSwitch;


@property (strong, nonatomic) SILBrowserFilterViewModel* viewModel;

@end

@implementation SILBrowserFilterViewController

NSString* const SearchByDeviceNamePlaceholder = @"Search by device name";
NSString* const DiscardKeybordText = @"\n";
NSInteger const ASCIICodeFor0 = 48;
NSInteger const ASCIICodeFor9 = 57;
NSInteger const ASCIICodeForA = 65;
NSInteger const ASCIICodeForF = 70;
NSInteger const FirstIndex = 0;
NSString* const StarterRSSIValue = @"-100 dBm";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
    [self setAppearanceForSeachingView];
    [self setAppearanceForRSSIView];
    [self setAppearanceForBeaconType];
    [self setAppearanceForFavouriteArea];
    [self setAppearanceForConnectableArea];
    [self setAppearanceForSavedSearches];
    [self setAppearanceForButtonInFooterView];
    self.viewModel = [SILBrowserFilterViewModel sharedInstance];
    [self updateFilterView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewModel = nil;
}

#pragma mark - Set Observers

- (void)addObservers {
    [self addObserverForReloadSavedSearchesTableView];
    [self addObserverForReloadFilterView];
    [self addObserverForKeyboardHide];
}

- (void)addObserverForReloadSavedSearchesTableView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeightForSavedSearchesContainer) name:SILNotificationReloadSavedSearchesViewHeight object:nil];
}

- (void)addObserverForReloadFilterView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFilterView) name:SILNotificationReloadFilterView object:nil];
}

- (void)addObserverForKeyboardHide {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - Appearance for Searching View

- (void)setAppearanceForSeachingView {
    [self setAppearanceForSearchingByDeviceName];
    [self setBackgroundAppearance];
    [self setupGesturesForClearImages];
    [self hideClearButtons];
}

- (void)setAppearanceForSearchingByDeviceName {
    _searchByDeviceNameTextView.textContainer.maximumNumberOfLines = 1;
    _searchByDeviceNameTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    [_searchByDeviceNameTextView setFont:[UIFont robotoMediumWithSize:[UIFont getMiddleFontSize]]];
    _searchByDeviceNameTextView.textColor = [UIColor sil_subtleTextColor];
    _searchByDeviceNameTextView.delegate = self;
    _searchByDeviceNameTextView.text = SearchByDeviceNamePlaceholder;
    _searchByDeviceNameTextView.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)setBackgroundAppearance {
    _seachByDeviceNameView.backgroundColor = [UIColor sil_backgroundColor];
    _seachByDeviceNameView.layer.cornerRadius = 10.0;
}

- (void)setupGesturesForClearImages {
    [self setupGestureForClearImageDeviceName];
}

- (void)setupGestureForClearImageDeviceName {
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performClearActionForDeviceNameView:)];
    [_clearTextImageByDeviceName addGestureRecognizer:tap];
}

- (void)performClearActionForDeviceNameView:(UIGestureRecognizer*)gestureRecognizer {
    _searchByDeviceNameTextView.text = EmptyText;
    _viewModel.searchByDeviceName = EmptyText;
    if ([_searchByDeviceNameTextView isFirstResponder] == false) {
        [self textViewDidEndEditing:_searchByDeviceNameTextView];
    }
    [self hideClearImageForDeviceName];
}

- (void)hideClearButtons {
    [self hideClearImageForDeviceName];
}

- (void)hideClearImageForDeviceName {
    [_clearTextImageByDeviceName setHidden:YES];
}

- (void)showClearImageForDeviceName {
    [_clearTextImageByDeviceName setHidden:NO];
}

# pragma mark - TextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self manageClearImageState:textView];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (text.length == 0) {
          return YES;
    }
    
    if ([text isEqualToString:DiscardKeybordText]) {
        [self updateSearchTextViewModels];
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView isEqual:_searchByDeviceNameTextView]) {
        [self discardPlaceholderIfNeededForDeviceNameTextView];
    }
    
    [self manageClearImageState:textView];
    [textView becomeFirstResponder];
}

- (void)manageClearImageState:(UITextView*)textView {
    if ([textView isEqual:_searchByDeviceNameTextView]) {
        [self manageClearImageStateForDeviceNameTextView];
    }
}

- (void)manageClearImageStateForDeviceNameTextView {
    if (([_searchByDeviceNameTextView.text isEqualToString:EmptyText] || [_searchByDeviceNameTextView.text isEqualToString:SearchByDeviceNamePlaceholder]) == false) {
        [self showClearImageForDeviceName];
    } else {
        [self hideClearImageForDeviceName];
    }
}

- (void)discardPlaceholderIfNeededForDeviceNameTextView {
    if ([_searchByDeviceNameTextView.text isEqualToString:SearchByDeviceNamePlaceholder]) {
         _searchByDeviceNameTextView.text = EmptyText;
     }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView isEqual:_searchByDeviceNameTextView]) {
        [self setPlaceholderIfNeededForDeviceNameTextView];
    }

    [textView resignFirstResponder];
}

- (void)setPlaceholderIfNeededForDeviceNameTextView {
    if ([_searchByDeviceNameTextView.text isEqualToString:EmptyText]) {
        _searchByDeviceNameTextView.text = SearchByDeviceNamePlaceholder;
    }
}

- (void)updateSearchTextViewModels {
    if ([self.searchByDeviceNameTextView.text isEqualToString:SearchByDeviceNamePlaceholder]) {
        self.viewModel.searchByDeviceName = EmptyText;
    } else {
        self.viewModel.searchByDeviceName = self.searchByDeviceNameTextView.text;
    }
}

- (void)keyboardDidHide:(NSNotification*)notification {
    [self updateSearchTextViewModels];
}

#pragma mark - Appearance for RSSI View

- (void)setAppearanceForRSSIView {
    [self setApperanceForRSSITitleLabel];
    [self setApperanceForDBMValueLabel];
    [self setApperanceForDBMSlider];
    [self setAppearanceForMinRangeLabel];
    [self setAppearanceForMaxRangeLabel];
    [self addGestureToSlider];
}

- (void)setApperanceForRSSITitleLabel {
    [_rssiLabel setFont:[UIFont robotoBoldWithSize:[UIFont getMiddleFontSize]]];
    _rssiLabel.textColor = [UIColor sil_primaryTextColor];
}

- (void)setApperanceForDBMValueLabel {
    [_dBmValueLabel setFont:[UIFont robotoBoldWithSize:[UIFont getSmallFontSize]]];
    _dBmValueLabel.textColor = [UIColor sil_regularBlueColor];
    _dBmValueLabel.text = StarterRSSIValue;
}

- (void)setApperanceForDBMSlider {
    _dBmSlider.tintColor = [UIColor sil_regularBlueColor];
    _dBmSlider.value = StarterDBMValue;
}

- (void)setAppearanceForMinRangeLabel {
    [_minRangeLabel setFont:[UIFont robotoRegularWithSize:[UIFont getSmallFontSize]]];
    _minRangeLabel.textColor = [UIColor sil_subtleTextColor];
}

- (void)setAppearanceForMaxRangeLabel {
    [_maxRangeLabel setFont:[UIFont robotoRegularWithSize:[UIFont getSmallFontSize]]];
    _maxRangeLabel.textColor = [UIColor sil_subtleTextColor];
}

- (void)addGestureToSlider {
    [_dBmSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSInteger dBmInt = (long)sender.value;
    _dBmValueLabel.text = [self getDBMTextForValue:dBmInt];
    [self updateDBMValueViewModel:dBmInt];
}

- (NSString*)getDBMTextForValue:(NSInteger)dBmValue {
    NSMutableString* dBmString = [NSMutableString stringWithFormat:@"%li", (long)dBmValue];
    [dBmString appendString:AppendingDBM];
    return dBmString;
}

-  (void)updateDBMValueViewModel:(NSInteger)dBmValue {
    self.viewModel.dBmValue = dBmValue;
}

#pragma mark - Appearance for Beacon Type Area

- (void)setAppearanceForBeaconType {
    [self setAppearanceForBeaconTypeLabel];
    [self setImageForBeaconTypeButton];
    [self updateHeightForBeaconTypeContainer];
}

- (void)setAppearanceForBeaconTypeLabel {
    [_beaconTypeLabel setFont:[UIFont robotoBoldWithSize:[UIFont getMiddleFontSize]]];
    _beaconTypeLabel.textColor = [UIColor sil_primaryTextColor];
}

- (void)setImageForBeaconTypeButton {
    [_beaconTypeAreaButton setImage:[[UIImage imageNamed:SILImageChevronCollapsed] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
    [_beaconTypeAreaButton setImage:[[UIImage imageNamed:SILImageChevronExpanded] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    _beaconTypeAreaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (IBAction)beaconTypeAreaButtonTapped:(id)sender {
    [self updateBeaconTypeViewModel];
    [_beaconTypeAreaButton setSelected:self.viewModel.isBeaconTypeExpanded];
    [self updateHeightForBeaconTypeContainer];
}

- (void)updateBeaconTypeViewModel {
    self.viewModel.isBeaconTypeExpanded = !self.viewModel.isBeaconTypeExpanded;
}

- (void)updateHeightForBeaconTypeContainer {
    if (self.viewModel.isBeaconTypeExpanded) {
        _beaconTypeContainerHeight.constant = self.viewModel.beaconTypeTableViewHeight;
    } else {
        _beaconTypeContainerHeight.constant = CollapsedViewHeight;
    }
}

# pragma mark - Appearance for Favourite Area

- (void)setAppearanceForFavouriteArea {
    [self setAppearanceForFavouritesLabel];
    [self.favouriteSwitch setIsOn: NO];
    [self addGestureToFavouriteSwitch];
}

- (void)setAppearanceForFavouritesLabel {
    [_favouriteAreaTitleLabel setFont:[UIFont robotoRegularWithSize:[UIFont getSmallFontSize]]];
    _favouriteAreaTitleLabel.textColor = [UIColor sil_subtleTextColor];
}

- (void)addGestureToFavouriteSwitch {
    [_favouriteSwitch addTarget:self action:@selector(favouriteSwitchStateChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)favouriteSwitchStateChanged:(SILSwitch *)sender {
    self.viewModel.isFavouriteFilterSet = sender.isOn;
}

# pragma mark - Appearance for Connectable Area

- (void)setAppearanceForConnectableArea {
    [self setAppearanceForConnectableLabel];
    [self.connectableSwitch setIsOn: NO];
    [self addGestureToConnectableSwitch];
}

- (void)setAppearanceForConnectableLabel {
    [_connectableTittleLabel setFont:[UIFont robotoRegularWithSize:[UIFont getSmallFontSize]]];
    _connectableTittleLabel.textColor = [UIColor sil_subtleTextColor];
}

- (void)addGestureToConnectableSwitch {
    [_connectableSwitch addTarget:self action:@selector(connectableSwitchStateChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)connectableSwitchStateChanged:(SILSwitch *)sender {
    self.viewModel.isConnectableFilterSet = sender.isOn;
}

#pragma mark - Appearance for Saved Searches Area

- (void)setAppearanceForSavedSearches {
    [self setAppearanceForSavedSearchesLabel];
    [self setImageForSavedSearchesButton];
    [self updateHeightForSavedSearchesContainer];
}

- (void)setAppearanceForSavedSearchesLabel {
    [_savedSearchesLabel setFont:[UIFont robotoBoldWithSize:[UIFont getMiddleFontSize]]];
    _savedSearchesLabel.textColor = [UIColor sil_primaryTextColor];
}

- (void)setImageForSavedSearchesButton {
    [_savedSearchesAreaButton setImage:[[UIImage imageNamed:SILImageChevronCollapsed] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
    [_savedSearchesAreaButton setImage:[[UIImage imageNamed:SILImageChevronExpanded] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    _savedSearchesAreaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (IBAction)savedSearchesButtonTapped:(id)sender {
    [self updateSavedSearchesViewModel];
    [_savedSearchesAreaButton setSelected:self.viewModel.isSavedSearchesExpaned];
    [self updateHeightForSavedSearchesContainer];
}

- (void)updateSavedSearchesViewModel {
    self.viewModel.isSavedSearchesExpaned = !self.viewModel.isSavedSearchesExpaned;
}

- (void)updateHeightForSavedSearchesContainer {
    if (self.viewModel.isSavedSearchesExpaned) {
        _savedSearchesContainerHeight.constant = self.viewModel.savedSearchesTableViewHeight;
    } else {
        _savedSearchesContainerHeight.constant = CollapsedViewHeight;
    }
}

#pragma mark - Appearance for Footer View

- (void)setAppearanceForButtonInFooterView {
    [self setAppearanceForSearchButton];
    [self setAppearanceForSaveButton];
    [self setAppearanceForResetButton];
    [self setAppearanceForExitButton];
    [self addGestureRecognizerForBackImage];
}

- (void)setAppearanceForSearchButton {
    _searchButton.layer.cornerRadius = CornerRadiusForButtons;
    [_searchButton.titleLabel setFont:[UIFont robotoMediumWithSize:[UIFont getMiddleFontSize]]];
    _searchButton.titleLabel.textColor = [UIColor sil_backgroundColor];
}

- (void)setAppearanceForSaveButton {
    [_saveButton.titleLabel setFont:[UIFont robotoMediumWithSize:[UIFont getMiddleFontSize]]];
}

- (void)setAppearanceForResetButton {
    [_resetButton.titleLabel setFont:[UIFont robotoMediumWithSize:[UIFont getMiddleFontSize]]];
}

- (void)setAppearanceForExitButton {
    _backImage.image = [[UIImage imageNamed:SILImageExitView] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

# pragma mark - Handle tap gestures for buttons in Footer View

- (void)addGestureRecognizerForBackImage {
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackImage:)];
    [_backImage addGestureRecognizer:tap];
}

- (void)tappedBackImage:(UIGestureRecognizer *)gestureRecognizer {
    [_delegate backButtonWasTapped];
}

- (IBAction)searchButtonTapped:(id)sender {
    [_delegate searchButtonWasTapped:_viewModel];
}

- (IBAction)saveButtonTapped:(id)sender {
    [_viewModel saveCurrentFilterDataToSavedSearches];
}

- (IBAction)resetButtonTapped:(id)sender {
    [_viewModel clearViewModelData];
    [_delegate searchButtonWasTapped:_viewModel];
    [_delegate backButtonWasTapped];
}

# pragma mark - Update Filter Values

- (void)updateFilterView {
    [self updateFilterViewValues];
    _dBmValueLabel.text = [self getDBMTextForValue:_viewModel.dBmValue];
}

- (void)updateFilterViewValues {
    _searchByDeviceNameTextView.text = _viewModel.searchByDeviceName;
    _dBmSlider.value = _viewModel.dBmValue;
    [self.favouriteSwitch setIsOn: _viewModel.isFavouriteFilterSet];
    [self.connectableSwitch setIsOn: _viewModel.isConnectableFilterSet];
    [self textViewDidEndEditing:_searchByDeviceNameTextView];
    [self manageClearImageState:_searchByDeviceNameTextView];
}

@end
