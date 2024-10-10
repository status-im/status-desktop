from allure_commons._allure import step

with step('Set testnet mode'):
    def enable_testnet_mode(main_window):
        wallet_settings = main_window.left_panel.open_settings().left_panel.open_wallet_settings()
        wallet_settings.open_networks().switch_testnet_mode_toggle().turn_on_button.click()
