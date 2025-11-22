"""Multi-device test base with simplified reporting."""

from __future__ import annotations

import json
from contextlib import contextmanager, asynccontextmanager
from typing import Any, Dict, List, Optional, Union

import pytest_asyncio  # type: ignore[import]

from core.device_context import DeviceContext
from core.multi_device_context import MultiDeviceContext
from core.stash_keys import MULTI_DEVICE_MANAGERS_KEY
from core.session_pool import PoolConfig, SessionPool
from utils.generators import generate_account_name
from utils.exceptions import SessionManagementError

from config.logging_config import get_logger
from utils.test_name_formatter import format_test_name_for_browserstack


class MultiDeviceTestBase:
    """Base class for tests that coordinate multiple device sessions.

    Provides device step context managers for clearer error context and
    delegates live failure coordination to `MultiDeviceContext`.
    """

    devices = None
    device_names = []
    auto_use_onboarded_devices: bool = True

    def setup_method(self, method):  # pragma: no cover - pytest lifecycle
        self.logger = get_logger(self.__class__.__name__)
        self._session_pool = None
        self._attached = False
        self._test_method_name = method.__name__

    @pytest_asyncio.fixture(autouse=True)
    async def _auto_use_onboarded_devices(self, request, onboarded_devices):
        if request.instance is not self:
            yield None
            return

        if request.node.get_closest_marker("no_autouse_onboarded"):
            yield None
            return

        if not getattr(self, "auto_use_onboarded_devices", True):
            yield None
            return

        yield onboarded_devices

    def _resolve_device_name(self, device: Union[str, DeviceContext]) -> str:
        if isinstance(device, DeviceContext):
            return device.device_id
        return device

    @contextmanager
    def device_step(self, device: Union[str, DeviceContext], description: str):
        """Context manager for device-specific operations with error logging."""
        device_name = self._resolve_device_name(device)
        try:
            yield
        except Exception as exc:
            self.logger.error(
                "Device step failed [%s]: %s - %s",
                device_name,
                description,
                exc,
            )
            if self.devices and isinstance(self.devices, MultiDeviceContext):
                self.devices.mark_device_failed(device_name, str(exc))
            raise

    @asynccontextmanager
    async def async_device_step(self, device: Union[str, DeviceContext], description: str):
        """Async context manager for device-specific operations with error logging."""
        device_name = self._resolve_device_name(device)
        try:
            yield
        except Exception as exc:
            self.logger.error(
                "Device step failed [%s]: %s - %s",
                device_name,
                description,
                exc,
            )
            if self.devices and isinstance(self.devices, MultiDeviceContext):
                self.devices.mark_device_failed(device_name, str(exc))
            raise

    # Internal helpers used by fixtures

    def _clear_device_bindings(self) -> None:
        for index in range(len(self.device_names)):
            attr_name = f"device_{index}"
            if hasattr(self, attr_name):
                delattr(self, attr_name)
        self.devices = None

    def _attach_devices(self, multi_ctx, pool, request, *, force: bool = False) -> None:
        if self._attached and not force:
            return

        if force and self._attached:
            self._clear_device_bindings()

        self.devices = multi_ctx
        self.device_names = list(multi_ctx.contexts.keys())
        self._session_pool = pool
        self._attached = True

        for index, name in enumerate(self.device_names):
            device_ctx = multi_ctx.contexts[name]
            setattr(self, f"device_{index}", device_ctx)

            session_manager = pool.get_session_manager(name)
            if session_manager:
                # Session name already set during creation, but ensure metadata is synced
                # (in case it was updated elsewhere)
                if not session_manager.metadata.test_name:
                    session_manager.metadata.test_name = format_test_name_for_browserstack(
                        request.node.nodeid, device_name=name
                    )

            driver = pool.get_driver(name)
            if driver:
                # Session name already set during creation, but update if needed
                # (this is a no-op if name was already set correctly)
                try:
                    current_name = session_manager.metadata.test_name if session_manager else None
                    if not current_name:
                        clean_name = format_test_name_for_browserstack(
                            request.node.nodeid, device_name=name
                        )
                        payload = json.dumps(
                            {
                                "action": "setSessionName",
                                "arguments": {
                                    "name": clean_name
                                },
                            }
                        )
                        driver.execute_script(f"browserstack_executor: {payload}")
                except Exception as e:  # pragma: no cover - best effort
                    self.logger.debug("Failed to set BrowserStack session name for %s: %s", name, e)

    async def _finalize_devices(self, request, pool) -> None:
        """
        Prepare devices for deferred cleanup and reporting.
        
        Stores session managers and pool in pytest stash for the hook to handle
        final reporting and cleanup after the test completes.
        """
        self.logger.info(
            "_finalize_devices invoked (device_names=%s)",
            list(self.device_names),
        )

        session_managers = {}
        for name in self.device_names:
            session_manager = pool.get_session_manager(name)
            if not session_manager:
                continue
            session_managers[name] = session_manager

        # Store for deferred reporting and cleanup in pytest hook
        # Hook will report after test completes (when rep_call is available)
        # and handle cleanup with proper async handling
        if session_managers:
            self.logger.info(
                "_finalize_devices storing %d session manager(s) in stash",
                len(session_managers),
            )
            request.node.stash.setdefault(MULTI_DEVICE_MANAGERS_KEY, []).append(
                (session_managers, pool)
            )
        else:
            self.logger.info("_finalize_devices found no session managers; running cleanup")
            await pool.cleanup()

        self._attached = False

    @asynccontextmanager
    async def onboarded_devices(
        self,
        request,
        environment: str,
        count: int = 2,
        *,
        display_names: Optional[List[str]] = None,
        device_overrides: Optional[List[Dict[str, Any]]] = None,
        device_tags: Optional[List[str]] = None,
        minimum_required: Optional[int] = None,
    ):
        """
        Create and onboard multiple devices.

        Args:
            request: Pytest request object
            environment: Test environment name
            count: Total number of devices to create
            display_names: Optional list of display names
            device_overrides: Optional device configuration overrides
            device_tags: Optional device tags for selection
            minimum_required: Minimum number of successfully onboarded devices required.
                             Defaults to `count`, enforcing all devices succeed.
                             When less than `count`, allows partial success as long as the
                             threshold is met.

        Yields:
            MultiDeviceContext with all devices

        Raises:
            SessionManagementError: If fewer than minimum_required devices succeed
        """
        if count < 1:
            raise ValueError("count must be >= 1")

        if minimum_required is None:
            minimum_required = count
        elif minimum_required < 1 or minimum_required > count:
            raise ValueError(f"minimum_required must be between 1 and count ({count})")

        pool_config = PoolConfig.from_environment(
            environment,
            device_overrides=device_overrides,
            device_tags=device_tags if not device_overrides else None,
            parallel=True,
        )
        pool = SessionPool(config=pool_config)
        drivers = await pool.create_sessions(
            count=count,
            test_nodeid=request.node.nodeid,
        )

        contexts = {
            name: DeviceContext(driver=driver, device_id=name)
            for name, driver in drivers.items()
        }

        multi_ctx = MultiDeviceContext(contexts)
        self._attach_devices(multi_ctx, pool, request, force=True)

        names = display_names or [generate_account_name(12) for _ in range(count)]
        if len(names) != count:
            raise ValueError("display_names length must match count")

        require_all = minimum_required == count
        try:
            users = await multi_ctx.onboard_users_parallel(
                display_names=names, require_all=require_all
            )
            successful_count = sum(1 for u in users if u is not None)
            if successful_count < minimum_required:
                raise SessionManagementError(
                    f"Only {successful_count} device(s) onboarded successfully, "
                    f"but {minimum_required} required"
                )
        except Exception as exc:
            self.logger.error("Failed to onboard devices: %s", exc)
            raise

        try:
            yield multi_ctx
        finally:
            await self._finalize_devices(request, pool)


