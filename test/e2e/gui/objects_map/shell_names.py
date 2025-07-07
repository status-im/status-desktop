from gui.objects_map.names import statusDesktop_mainWindow
from objectmaphelper import *

# Map for shell screens, views locators

# HomePage Container
shell_container = {"container": statusDesktop_mainWindow, "objectName": "shellContainer", "type": "HomePage", "visible": True}
shell_search_field = {"container": statusDesktop_mainWindow, "objectName": "shellSearchField", "type": "HomePageSearchField", "visible": True}

# HomePage Grid
shell_grid = {"container": shell_container, "objectName": "shellGrid", "type": "HomePageGrid", "visible": True}
shell_grid_item = {"container": shell_grid, "type": "HomePageGridItem", "visible": True}
shell_grid_item_pin_button = {"container": shell_grid_item, "type": "HomePageToolButton", "visible": True}

# HomePage Grid Context Menu
shell_grid_item_context_menu = {"type": "StatusMenu", "visible": True}
shell_grid_item_pin_menu_action = {"container": shell_grid_item_context_menu, "text": "Pin", "type": "StatusMenuItem", "visible": True}
shell_grid_item_unpin_menu_action = {"container": shell_grid_item_context_menu, "text": "Unpin", "type": "StatusMenuItem", "visible": True}

# HomePage Dock
shell_dock = {"container": statusDesktop_mainWindow, "type": "ListView", "visible": True}

# Regular Dock Buttons
shell_regular_dock_button_wallet = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonWallet", "type": "HomePageDockButton", "visible": True}
shell_regular_dock_button_market = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonMarket", "type": "HomePageDockButton", "visible": True}
shell_regular_dock_button_messages = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonMessages", "type": "HomePageDockButton", "visible": True}
shell_regular_dock_button_communities = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonCommunities Portal", "type": "HomePageDockButton", "visible": True}
shell_regular_dock_button_settings = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonSettings", "type": "HomePageDockButton", "visible": True}

# TODO: Methods for pinned dock buttons https://github.com/status-im/status-desktop/issues/18239
shell_pinned_dock_button_ = {"container": statusDesktop_mainWindow, "objectName": "pinnedDockButton", "type": "HomePageDockButton", "visible": True}

# Generic Dock Button Locators
shell_any_regular_dock_button = {"container": statusDesktop_mainWindow, "type": "HomePageDockButton", "pinned": False, "visible": True}
shell_any_pinned_dock_button = {"container": statusDesktop_mainWindow, "type": "HomePageDockButton", "pinned": True, "visible": True}
shell_pinned_dock_button = {"container": statusDesktop_mainWindow, "type": "HomePageDockButton", "pinned": True, "visible": True}
shell_generic_dock_button = {"container": statusDesktop_mainWindow, "type": "HomePageDockButton", "visible": True}

# Dock Button Context Menu
shell_dock_button_context_menu = {"type": "StatusMenu", "visible": True}
shell_dock_button_unpin_menu_action = {"container": shell_dock_button_context_menu, "text": "Unpin", "type": "StatusAction", "visible": True}
shell_dock_button_disconnect_menu_action = {"container": shell_dock_button_context_menu, "text": "Disconnect", "type": "StatusAction", "visible": True}
