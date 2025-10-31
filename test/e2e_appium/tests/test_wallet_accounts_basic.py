import pytest

from tests.base_test import BaseAppReadyTest, cloud_reporting
from pages.wallet.wallet_left_panel import WalletLeftPanel
from pages.app import App
from utils.generators import generate_account_name


class TestWalletAccountsBasic(BaseAppReadyTest):
    @pytest.mark.wallet
    @pytest.mark.smoke
    @cloud_reporting
    def test_add_and_delete_generated_account(self):
        panel = WalletLeftPanel(self.driver)
        app = App(self.driver)

        assert panel.is_loaded(timeout=20), "Wallet left panel not visible"

        before = len(panel.account_rows())

        current_user = self.ctx.user_service.current_user
        assert current_user, "No active user in context"
        user_password = current_user.password

        name = generate_account_name(16)
        assert panel.add_account(name, auth_password=user_password), (
            f"Failed to add account '{name}' via modal"
        )

        assert app.is_toast_present(timeout=5), "Expected toast after adding account"
        toast_text = app.get_toast_content_desc(timeout=10) or ""
        assert "successfully added" in toast_text.lower(), (
            f"Expected success toast after adding account '{name}'. Got: '{toast_text}'"
        )

        after_add = len(panel.account_rows())
        assert after_add >= before, (
            f"Account list did not grow after adding '{name}'. "
            f"Before: {before}, After: {after_add}"
        )

        panel.delete_latest_account_via_menu(auth_password=user_password)

        assert app.is_toast_present(timeout=5), "Expected toast after removing account"
        toast_text = app.get_toast_content_desc(timeout=10) or ""
        assert "successfully removed" in toast_text.lower(), (
            f"Expected removal toast after deleting account. Got: '{toast_text}'"
        )

        after_delete = len(panel.account_rows())
        assert after_delete <= after_add, (
            f"Account list did not shrink after deletion. "
            f"Before deletion: {after_add}, After deletion: {after_delete}"
        )
