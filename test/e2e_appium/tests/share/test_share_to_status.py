"""Content shared from another Android app reaches Status and the chats the user picks."""

import pytest

from pages.app import App
from pages.messaging.chat_page import ChatPage
from pages.messaging.group_chat_page import GroupChatPage
from pages.share_picker_page import SharePickerPage
from support import share_intents
from tests.messaging.peer_base import PeerChatBase


@pytest.mark.portrait
@pytest.mark.device_count(1)
@pytest.mark.timeout(1200)
class TestShareToStatus(PeerChatBase):
    """Shares arrive by intent, matched against Status's manifest filters as the
    system share sheet does; the peer is every chat's other member and confirms
    what was sent."""

    def share_page(self) -> SharePickerPage:
        return SharePickerPage(self.driver)

    def leave_the_chat(self) -> None:
        chat_page = self.open_chat_list()
        assert not chat_page.wait_for_message_input(timeout=3), "A chat is still open"

    def assert_open_chat_is_the_1to1(self, context: str = "") -> None:
        header = GroupChatPage(self.driver).get_group_name_from_header(timeout=15) or ""
        assert any(name in header for name in (self.peer.display_name, self.peer.alias)), (
            f"The open chat is {header!r}, not the 1:1 with the peer{context}"
        )

    @pytest.mark.spec("SC-SHARE-27")
    async def test_status_link_opened_with_status_keeps_its_deep_link_meaning(self) -> None:
        """A status.app link handed to Status as a web link opens the chat it names."""
        self.leave_the_chat()
        share_intents.open_link(self.driver, f"https://status.app/p/{self.peer.public_key}")
        assert ChatPage(self.driver).wait_for_message_input(timeout=30), "The link did not open a chat"
        self.assert_open_chat_is_the_1to1()

    @pytest.mark.spec("SC-SHARE-27")
    @pytest.mark.skip(
        reason="with UIAutomator2 attached the app stops answering once the link opens the "
        "browser (Samsung A36); the same link opened by hand works",
    )
    async def test_web_link_opened_with_status_shows_in_its_browser(self) -> None:
        """An http link handed to Status opens in its browser."""
        app = App(self.driver)
        share_intents.open_link(self.driver, "https://example.com/")
        assert app.wait_for_condition(lambda: app.active_section() == "browser", timeout=20), (
            f"Status is on {app.active_section()!r}, not in the browser"
        )
        address = self.share_page().browser_address()
        assert address and "example.com" in address, f"The address bar shows {address!r}"
