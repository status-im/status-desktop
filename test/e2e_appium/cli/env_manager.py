#!/usr/bin/env python3

import sys
import argparse
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from core import EnvironmentSwitcher, ConfigurationError


def list_environments() -> None:
    switcher = EnvironmentSwitcher()
    environments = switcher.config_manager.list_available_environments()

    print("Available environments:")
    for env in environments:
        print(f"  • {env}")


def validate_environment(environment: str) -> bool:
    try:
        switcher = EnvironmentSwitcher()
        config = switcher.switch_to(environment)
        print(f"✅ Environment '{environment}' is valid")

        print("\nConfiguration Summary:")
        print(f"  Device: {config.device_name}")
        print(f"  Platform: {config.platform_name} {config.platform_version}")
        print(f"  App Source: {config.app_source['source_type']}")
        print(f"  Appium Server: {config.get_appium_server_url()}")

        return True

    except ConfigurationError as e:
        print(f"❌ Environment '{environment}' is invalid: {e}")
        return False


def switch_environment(environment: str) -> bool:
    try:
        switcher = EnvironmentSwitcher()
        config = switcher.switch_to(environment)
        print(f"✅ Switched to environment: {environment}")
        print(f"Run: export CURRENT_TEST_ENVIRONMENT={environment}")
        return True

    except ConfigurationError as e:
        print(f"❌ Failed to switch: {e}")
        return False


def auto_detect() -> str:
    switcher = EnvironmentSwitcher()
    environment = switcher.auto_detect_environment()
    print(f"🔍 Auto-detected environment: {environment}")
    return environment


def main() -> None:
    parser = argparse.ArgumentParser(description="Environment management CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    subparsers.add_parser("list", help="List available environments")

    validate_parser = subparsers.add_parser(
        "validate", help="Validate environment configuration"
    )
    validate_parser.add_argument("environment", help="Environment to validate")

    switch_parser = subparsers.add_parser("switch", help="Switch to environment")
    switch_parser.add_argument("environment", help="Environment to switch to")

    subparsers.add_parser("auto-detect", help="Auto-detect best environment")

    validate_all_parser = subparsers.add_parser(
        "validate-all", help="Validate all environments"
    )

    args = parser.parse_args()

    if args.command == "list":
        list_environments()
    elif args.command == "validate":
        validate_environment(args.environment)
    elif args.command == "switch":
        switch_environment(args.environment)
    elif args.command == "auto-detect":
        auto_detect()
    elif args.command == "validate-all":
        switcher = EnvironmentSwitcher()
        environments = switcher.config_manager.list_available_environments()
        all_valid = True
        for env in environments:
            if not validate_environment(env):
                all_valid = False
            print()

        if all_valid:
            print("✅ All environments are valid")
        else:
            print("❌ Some environments have issues")
            sys.exit(1)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
