from gui.objects_map.names import statusDesktop_mainWindow
from objectmaphelper import *

# Map for shell screens, views locators

# Shell Container
shell_container = {"container": statusDesktop_mainWindow, "objectName": "shellContainer", "type": "ShellContainer", "visible": True}
shell_search_field = {"container": statusDesktop_mainWindow, "objectName": "shellSearchField", "type": "ShellSearchField", "visible": True}

# Shell Grid
shell_grid = {"container": shell_container, "objectName": "shellGrid", "type": "ShellGrid", "visible": True}
shell_grid_item = {"container": shell_grid, "type": "ShellGridItem", "visible": True}
shell_grid_item_pin_button = {"container": shell_grid_item, "type": "ShellToolButton", "visible": True}

# Shell Grid Context Menu
shell_grid_item_context_menu = {"type": "StatusMenu", "visible": True}
shell_grid_item_pin_menu_action = {"container": shell_grid_item_context_menu, "text": "Pin", "type": "StatusMenuItem", "visible": True}
shell_grid_item_unpin_menu_action = {"container": shell_grid_item_context_menu, "text": "Unpin", "type": "StatusMenuItem", "visible": True}

# Shell Dock
shell_dock = {"container": statusDesktop_mainWindow, "type": "ListView", "visible": True}

# Regular Dock Buttons
shell_regular_dock_button_wallet = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonWallet", "type": "ShellDockButton", "visible": True}
shell_regular_dock_button_market = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonMarket", "type": "ShellDockButton", "visible": True}
shell_regular_dock_button_messages = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonMessages", "type": "ShellDockButton", "visible": True}
shell_regular_dock_button_communities = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonCommunities Portal", "type": "ShellDockButton", "visible": True}
shell_regular_dock_button_settings = {"container": statusDesktop_mainWindow, "objectName": "regularDockButtonSettings", "type": "ShellDockButton", "visible": True}

# TODO: Methods for pinned dock buttons
shell_pinned_dock_button_ = {"container": statusDesktop_mainWindow, "objectName": "pinnedDockButton", "type": "ShellDockButton", "visible": True}

# Generic Dock Button Locators
shell_any_regular_dock_button = {"container": statusDesktop_mainWindow, "type": "ShellDockButton", "pinned": False, "visible": True}
shell_any_pinned_dock_button = {"container": statusDesktop_mainWindow, "type": "ShellDockButton", "pinned": True, "visible": True}
shell_pinned_dock_button = {"container": statusDesktop_mainWindow, "type": "ShellDockButton", "pinned": True, "visible": True}
shell_generic_dock_button = {"container": statusDesktop_mainWindow, "type": "ShellDockButton", "visible": True}

# Dock Button Context Menu
shell_dock_button_context_menu = {"type": "StatusMenu", "visible": True}
shell_dock_button_unpin_menu_action = {"container": shell_dock_button_context_menu, "text": "Unpin", "type": "StatusAction", "visible": True}
shell_dock_button_disconnect_menu_action = {"container": shell_dock_button_context_menu, "text": "Disconnect", "type": "StatusAction", "visible": True}






