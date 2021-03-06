//
//  MainViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import MediaPlayer

protocol MainViewControllerProtocol: BaseView {
    
}

class MainViewController : UIViewController, MainViewControllerProtocol {
    public static let DEFAULT_SELECTED_TAB: TabID = .Albums
    public static let TAB_SIZE = CGSize(width: 0, height: 60.0)
    
    var baseView: MainView? {
        return self.view as? MainView
    }
    
    private var audioStorage: AudioLibrary = AudioLibrary()
    
    private var _selectedTab: UIViewController?
    
    private var selectedTab: BaseView? {
        get {
            return _selectedTab as? BaseView
        }
    }
    
    private var selectedTabID: TabID = .None
    
    private var selectedTabIsFocused: Bool {
        get {
            if let vc = _selectedTab
            {
                return vc.children.count == 0
            }
            
            return false
        }
    }
    
    private var tabsCache: [TabID: BaseView] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralStorage.shared.initialize()
        AudioPlayerService.shared.start(audioInfo: audioStorage)
        QuickPlayerService.shared.initialize(audioPlayer: AudioPlayerService.shared)
        GeneralStorage.shared.restorePlayerState()
        GeneralStorage.shared.restorePlayerPlayHistoryState()
        
        GeneralStorage.shared.attach(observer: self)
        
        updateAppTheme()
        
        setup()
    }
    
    deinit {
        GeneralStorage.shared.detach(observer: self)
    }
    
    private func setup() {
        // Select default tab
        onTabItemSelected(getCurrentlySelectedTabFromStorage())
        
        // Button interaction
        var gesture = UITapGestureRecognizer(target: self, action: #selector(actionAlbumsMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.albumsButton.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(actionListsMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.listsButton.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(actionSearchMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.searchButton.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(actionSettingsMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.settingsButton.addGestureRecognizer(gesture)
    }
    
    private func getCurrentlySelectedTabFromStorage() -> TabID {
        if let tabID = GeneralStorage.shared.getCurrentlySelectedTab() {
            return tabID
        }
        
        return MainViewController.DEFAULT_SELECTED_TAB
    }
    
    private func onTabItemSelected(_ tabID: TabID) {
        if self.selectedTabID == tabID
        {
            if self.selectedTabIsFocused
            {
                return
            }
            
            navigateBackwards()
            return
        }
        
        cacheCurrentTab()
        
        deselectAllTabs()
        
        self.selectedTabID = tabID
        
        updateTabButtonsColor()
        
        switch tabID {
        case .Albums:
            selectAlbumsTab()
            break
        case .Lists:
            selectListsTab()
            break
        case .Search:
            selectSearchTab()
            break
        case .Settings:
            selectSettingsTab()
            break
        default:
            fatalError("Cannot select tab \(tabID.rawValue)")
            break
        }
        
        GeneralStorage.shared.saveCurrentlySelectedTab(tabID)
    }
    
    private func deselectAllTabs() {
        if let selectedTabVC = self._selectedTab
        {
            NavigationHelpers.removeVCChild(selectedTabVC)
            self._selectedTab = nil
        }
        
        self.selectedTabID = .None
        
        resetTabButtonsColor()
    }
    
    private func navigateBackwards() {
        self.selectedTab?.goBack()
    }
    
    private func cacheCurrentTab() {
        let cachingPolicy = GeneralStorage.shared.getCachingPolicy()
        
        switch self.selectedTabID {
        case .Albums:
            if cachingPolicy.canCacheAlbums()
            {
                tabsCache[TabID.Albums] = selectedTab!
            }
            break
        case .Lists:
            if cachingPolicy.canCacheLists()
            {
                tabsCache[TabID.Lists] = selectedTab!
            }
            break
        case .Search:
            if cachingPolicy.canCacheSearch()
            {
                tabsCache[TabID.Search] = selectedTab!
            }
            break
        case .Settings:
            if cachingPolicy.canCacheSettings()
            {
                tabsCache[TabID.Settings] = selectedTab!
            }
            break
        default:
            break
        }
    }
    
    private func selectAlbumsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Albums'")
        
        let vc = tabsCache[TabID.Albums]
        
        if vc == nil
        {
            let presenter = AlbumsPresenter(audioInfo: audioStorage)
            let albumsVC = AlbumsViewController(presenter: presenter)
            self._selectedTab = albumsVC
            presenter.delegate = albumsVC
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let albumsVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Albums view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: albumsVC)
        self.baseView?.embedViewIntoPrimaryArea(albumsVC.view)
    }
    
    private func selectListsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Lists'")
        
        let vc = tabsCache[TabID.Lists]
        
        if vc == nil
        {
            let presenter = ListsPresenter(audioInfo: audioStorage)
            let listsVC = ListsViewController(presenter: presenter)
            self._selectedTab = listsVC
            presenter.delegate = listsVC
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let albumsVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Lists view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: albumsVC)
        self.baseView?.embedViewIntoPrimaryArea(albumsVC.view)
    }
    
    private func selectSearchTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Search'")
        
        let vc = tabsCache[TabID.Search]
        
        if vc == nil
        {
            let presenter = SearchPresenter(audioInfo: audioStorage)
            let searchVC = SearchViewController(presenter: presenter)
            self._selectedTab = searchVC
            presenter.delegate = searchVC
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let searchVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Search view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: searchVC)
        self.baseView?.embedViewIntoPrimaryArea(searchVC.view)
    }
    
    private func selectSettingsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Settings'")
        
        let vc = tabsCache[TabID.Settings]
        
        if vc == nil
        {
            let presenter = SettingsPresenter()
            let settingsVC = SettingsViewController(presenter: presenter, rootView: self)
            self._selectedTab = settingsVC
            presenter.delegate = settingsVC
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let settingsVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Settings view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: settingsVC)
        self.baseView?.embedViewIntoPrimaryArea(settingsVC.view)
    }
    
    private func clearTabsCache() {
        Logging.log(MainViewController.self, "Clear tabs cache")
        
        tabsCache.removeAll()
    }
    
    private func updateAppTheme() {
        AppTheme.shared.setAppearance(theme: GeneralStorage.shared.getAppThemeValue())
    }
    
    // MainViewControllerProtocol
    
    func goBack() {
        
    }
}

// Storage observer
extension MainViewController: GeneralStorageObserver {
    func onAppAppearanceChange() {
        Logging.log(MainViewController.self, "App appearance changed! Reloading current tab and wiping out the tabs cache...")
        
        // Update app theme value
        updateAppTheme()
        
        // Reload current tab
        let currentTab = selectedTabID
        deselectAllTabs()
        
        clearTabsCache()
        
        switch currentTab {
        case .Albums:
            selectAlbumsTab()
            break
        case .Lists:
            selectListsTab()
            break
        case .Search:
            selectSearchTab()
            break
        case .Settings:
            selectSettingsTab()
            break
        default:
            selectSettingsTab()
            break
        }
    }
    
    func onTabCachingPolicyChange(_ value: TabsCachingPolicy) {
        clearTabsCache()
    }
    
    func onKeybindChange(forInput: ApplicationInput) {
        
    }
    
    func onResetDefaultSettings() {
        clearTabsCache()
    }
}

// Actions
extension MainViewController {
    @objc func actionAlbumsMenuButtonTap(sender: Any) {
        onTabItemSelected(.Albums)
    }
    
    @objc func actionListsMenuButtonTap(sender: Any) {
        onTabItemSelected(.Lists)
    }
    
    @objc func actionSearchMenuButtonTap(sender: Any) {
        onTabItemSelected(.Search)
    }
    
    @objc func actionSettingsMenuButtonTap(sender: Any) {
        onTabItemSelected(.Settings)
    }
}

// Interface operations
extension MainViewController {
    private func resetTabButtonsColor() {
        self.baseView?.albumsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.listsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.searchButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.settingsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
    }
    
    private func updateTabButtonsColor() {
        resetTabButtonsColor()
        
        let color = AppTheme.shared.colorFor(.NAVIGATION_ITEM_SELECTION)
        
        switch self.selectedTabID {
        case .Albums:
            self.baseView?.albumsButton.tintColor = color
            break
        case .Lists:
            self.baseView?.listsButton.tintColor = color
            break
        case .Search:
            self.baseView?.searchButton.tintColor = color
            break
        case .Settings:
            self.baseView?.settingsButton.tintColor = color
            break
        default:
            break
        }
    }
}
