"""Multi-device pytest fixtures."""

from __future__ import annotations

from typing import Any, Dict, List, Optional

import pytest_asyncio

from config.logging_config import get_logger
from core.config_manager import ConfigurationManager
from core.device_context import DeviceContext
from core.multi_device_context import MultiDeviceContext
from core.session_pool import PoolConfig, SessionPool
from tests.multi_device_test_base import MultiDeviceTestBase


DEFAULT_DEVICE_COUNT = 2


def _resolve_count_marker(marker, *, default: int) -> int:
    if not marker:
        return default
    if marker.args:
        return int(marker.args[0])
    if "count" in marker.kwargs:
        return int(marker.kwargs["count"])
    if "value" in marker.kwargs:
        return int(marker.kwargs["value"])
    return default


def _resolve_minimum_marker(marker) -> Optional[int]:
    if not marker:
        return None
    if marker.args:
        return int(marker.args[0])
    if "count" in marker.kwargs:
        return int(marker.kwargs["count"])
    if "value" in marker.kwargs:
        return int(marker.kwargs["value"])
    return None


def _extract_marker_list(marker, key: str) -> Optional[List[Any]]:
    if not marker:
        return None
    if marker.args:
        return list(marker.args)
    value = marker.kwargs.get(key)
    if value is None:
        return None
    if isinstance(value, (list, tuple)):
        return list(value)
    return [value]


@pytest_asyncio.fixture(scope="function")
async def multi_device(request, test_environment):
    logger = get_logger("multi_device_fixture")

    count_marker = request.node.get_closest_marker("device_count")
    tags_marker = request.node.get_closest_marker("device_tags")
    overrides_marker = request.node.get_closest_marker("device_overrides")

    device_count = _resolve_count_marker(count_marker, default=DEFAULT_DEVICE_COUNT)
    device_tags = _extract_marker_list(tags_marker, "tags")
    device_overrides = _extract_marker_list(overrides_marker, "devices")

    if device_overrides:
        device_overrides = list(device_overrides)[:device_count]

    if device_tags and not device_overrides:
        cfg_mgr = ConfigurationManager()
        env_cfg = cfg_mgr.load_environment(test_environment)
        available = env_cfg.available_devices or []
        tag_filter = set(device_tags)
        device_overrides = [
            device for device in available if tag_filter.issubset(set(device.get("tags", [])))
        ][:device_count]

    overrides_by_index: Optional[List[Dict[str, Any]]] = None
    if device_overrides:
        overrides_by_index = list(device_overrides)

    logger.info(
        "Provisioning %d device(s) (raw) for environment %s",
        device_count,
        test_environment,
    )

    # Load environment config to read queue retry settings
    cfg_mgr = ConfigurationManager()
    env_cfg = cfg_mgr.load_environment(test_environment)

    pool_config = PoolConfig.from_environment(
        test_environment,
        env_config=env_cfg,
        device_overrides=overrides_by_index,
        device_tags=device_tags if not overrides_by_index else None,
    )
    pool = SessionPool(config=pool_config)
    drivers = await pool.create_sessions(
        count=device_count,
        test_nodeid=request.node.nodeid,
    )

    contexts = {
        name: DeviceContext(driver=driver, device_id=name)
        for name, driver in drivers.items()
    }

    multi_ctx = MultiDeviceContext(contexts)

    try:
        yield multi_ctx
    finally:
        await pool.cleanup()


@pytest_asyncio.fixture(scope="function")
async def onboarded_devices(request, test_environment):
    """Provision and onboard multiple devices using MultiDeviceTestBase helper."""

    logger = get_logger("onboarded_devices_fixture")

    count_marker = request.node.get_closest_marker("device_count")
    minimum_marker = request.node.get_closest_marker("minimum_required")
    tags_marker = request.node.get_closest_marker("device_tags")
    overrides_marker = request.node.get_closest_marker("device_overrides")

    device_count = _resolve_count_marker(count_marker, default=DEFAULT_DEVICE_COUNT)
    minimum_required = _resolve_minimum_marker(minimum_marker)

    device_tags = _extract_marker_list(tags_marker, "tags")
    device_overrides = _extract_marker_list(overrides_marker, "devices")

    if device_overrides:
        device_overrides = list(device_overrides)[:device_count]

    if device_tags and not device_overrides:
        cfg_mgr = ConfigurationManager()
        env_cfg = cfg_mgr.load_environment(test_environment)
        available = env_cfg.available_devices or []
        tag_filter = set(device_tags)
        device_overrides = [
            device for device in available if tag_filter.issubset(set(device.get("tags", [])))
        ][:device_count]

    base_test = request.instance if isinstance(request.instance, MultiDeviceTestBase) else None
    created_base = False
    if base_test is None:
        base_test = MultiDeviceTestBase()
        created_base = True

        method = getattr(request, "function", None)
        if method is None:
            method = type("_TempMethod", (), {"__name__": request.node.name})
        base_test.setup_method(method)

    logger.info(
        "Provisioning %d device(s) (minimum_required=%s) for environment %s",
        device_count,
        minimum_required if minimum_required is not None else device_count,
        test_environment,
    )

    try:
        async with base_test.onboarded_devices(
            request,
            test_environment,
            count=device_count,
            device_overrides=device_overrides,
            device_tags=device_tags,
            minimum_required=minimum_required,
        ) as contexts:
            yield contexts
    finally:
        if created_base:
            base_test.devices = None

