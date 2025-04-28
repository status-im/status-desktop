
def enable_testnet_mode(main_window):
    wallet_settings = main_window.left_panel.open_settings().left_panel.open_wallet_settings()
    wallet_settings.open_networks().switch_testnet_mode_toggle().turn_on_button.click()


def enable_managing_communities_toggle(main_window):
    settings = main_window.left_panel.open_settings()
    settings.left_panel.open_advanced_settings().enable_manage_communities_on_testnet_toggle()

