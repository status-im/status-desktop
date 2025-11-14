import asyncio

import pytest

from tests.multi_device_test_base import MultiDeviceTestBase


class TestMessaging1x1Chat(MultiDeviceTestBase):
    @pytest.mark.messaging
    @pytest.mark.smoke
    @pytest.mark.asyncio
    @pytest.mark.device_count(2)
    async def test_capture_profile_link_first(self):
        multi_ctx = getattr(self, "devices", None)
        assert multi_ctx is not None, "Multi-device context not attached"
        assert len(multi_ctx) >= 2, "Expected at least two onboarded devices"

        primary = multi_ctx["device_0"]
        secondary = multi_ctx["device_1"]

        async def capture_profile(device, description: str) -> str:
            async with self.async_device_step(device, description):
                loop = asyncio.get_running_loop()
                profile_link = await loop.run_in_executor(
                    None, device.capture_profile_link
                )
                assert profile_link, f"{device.device_id} did not return a profile link"
                assert device.user is not None, f"{device.device_id} has no onboarded user"
                assert getattr(device.user, "profile_link", None) == profile_link, (
                    f"Profile link not stored on {device.device_id} user state"
                )
                return profile_link

        primary_link, secondary_link = await asyncio.gather(
            capture_profile(primary, "Capture profile link from primary user"),
            capture_profile(secondary, "Capture profile link from secondary user"),
        )

        assert primary_link != "", "Primary profile link should not be empty"
        assert secondary_link != "", "Secondary profile link should not be empty"

        pytest.skip("Messaging contact request flow pending implementation.")

