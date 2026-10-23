"""Settings opens from the left nav button, not the profile sheet."""

from unittest.mock import MagicMock

import pytest

from pages.app import App


def test_already_in_settings_skips_nav(monkeypatch):
    app = App(MagicMock())
    monkeypatch.setattr(app, "is_element_visible", lambda *a, **k: True)

    def nav(**kwargs):
        raise AssertionError("nav should not be clicked")

    monkeypatch.setattr(app, "_click_drawer_nav_with_verify", nav)
    assert app.click_settings_button() is True


@pytest.mark.gate
@pytest.mark.component
def test_settings_button_uses_left_nav(monkeypatch):
    app = App(MagicMock())
    calls = {}
    monkeypatch.setattr(app, "is_element_visible", lambda *a, **k: False)
    monkeypatch.setattr(
        "support.screen_identity.dismiss_backup_modal", lambda *a, **k: False
    )

    def nav(**kwargs):
        calls.update(kwargs)
        return True

    monkeypatch.setattr(app, "_click_drawer_nav_with_verify", nav)
    assert app.click_settings_button() is True
    assert calls["nav_locator"] == app.locators.LEFT_NAV_SETTINGS
    assert calls["landmark_locator"] is not None
    assert calls["nav_name"] == "Settings"
