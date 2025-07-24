from constants.dock_buttons import DockButtons


def enable_testnet_mode(main_window):
    main_window.home.open_from_dock(DockButtons.SETTINGS.value)
    wallet_settings = main_window.left_panel.open_settings().left_panel.open_wallet_settings()
    test_mode_popup = wallet_settings.open_networks().switch_testnet_mode_toggle()
    test_mode_popup.turn_on_testnet_mode()


def enable_managing_communities_toggle(main_window):
    settings = main_window.left_panel.open_settings()
    settings.left_panel.open_advanced_settings().enable_manage_communities_on_testnet_toggle()

