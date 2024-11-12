from allure_commons._allure import step

with step('Set testnet mode'):
    def enable_testnet_mode(main_window):
        wallet_settings = main_window.left_panel.open_settings().left_panel.open_wallet_settings()
        wallet_settings.open_networks().switch_testnet_mode_toggle().turn_on_button.click()


def enable_community_creation(main_screen):
    with step('Enable creation of community option'):
        settings = main_screen.left_panel.open_settings()
        settings.left_panel.open_advanced_settings().enable_creation_of_communities()
