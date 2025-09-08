from ...base_locators import BaseLocators

class WalletLocators(BaseLocators):

    WALLET_HEADER = BaseLocators.accessibility_id("Wallet")
    ASSETS_TAB = BaseLocators.text_contains("Assets")
    ACTIVITY_TAB = BaseLocators.text_contains("Activity")
    
    ACCOUNT_NAME_ANY = BaseLocators.xpath(
        "//*[contains(@resource-id, 'Account') or contains(@text, 'Account')]"
    )
    BALANCE_ANY = BaseLocators.xpath(
        "//*[contains(@text, 'ETH') or contains(@text, 'USD')]"
    )

    SAVED_ADDRESSES_BUTTON = BaseLocators.xpath(
        "//*[contains(@resource-id, 'savedAddressesBtn') or @content-desc='Saved addresses']"
    )
    ADD_NEW_ADDRESS_BUTTON = BaseLocators.xpath(
        "//*[contains(@resource-id, 'walletHeaderButton') or @content-desc='Add new address']"
    )
