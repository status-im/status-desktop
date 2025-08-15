#!/usr/bin/env python3
"""
Upload APK to LambdaTest and return the app URL.
Simple script for GitHub Actions integration.
"""

import os
import sys
import argparse
import requests
from pathlib import Path


def upload_apk_to_lambdatest(apk_path, app_name, username, access_key):
    """Upload APK to LambdaTest and return app URL."""

    if not Path(apk_path).exists():
        raise FileNotFoundError(f"APK file not found: {apk_path}")

    url = "https://manual-api.lambdatest.com/app/upload/virtualDevice"

    print(f"🚀 Uploading {apk_path} to LambdaTest...")
    print(f"   App name: {app_name}")

    with open(apk_path, "rb") as f:
        files = {
            "appFile": (
                Path(apk_path).name,
                f,
                "application/vnd.android.package-archive",
            )
        }

        data = {"name": app_name, "type": "android"}

        response = requests.post(
            url,
            files=files,
            data=data,
            auth=(username, access_key),
            timeout=300,  # 5 minutes timeout
        )

    if response.status_code == 200:
        result = response.json()
        app_url = result.get("app_url")
        if app_url:
            print("✅ Upload successful!")
            print(f"   App URL: {app_url}")
            print(f"   App ID: {result.get('app_id', 'N/A')}")

            # Output for GitHub Actions
            if os.getenv("GITHUB_ACTIONS"):
                with open(os.environ["GITHUB_OUTPUT"], "a") as f:
                    f.write(f"app_url={app_url}\n")
                    f.write(f"app_id={result.get('app_id', '')}\n")

            return app_url
        else:
            raise Exception("Upload succeeded but no app_url in response")
    else:
        try:
            error_details = response.json()
            error_msg = error_details.get("message", response.text)
        except Exception:
            error_msg = response.text
        raise Exception(f"Upload failed: {response.status_code} - {error_msg}")


def main():
    parser = argparse.ArgumentParser(description="Upload APK to LambdaTest")
    parser.add_argument("--apk-path", required=True, help="Path to APK file")
    parser.add_argument("--app-name", required=True, help="App name in LambdaTest")

    args = parser.parse_args()

    # Get credentials from environment
    username = os.getenv("LT_USERNAME")
    access_key = os.getenv("LT_ACCESS_KEY")

    if not username or not access_key:
        print("❌ Missing LambdaTest credentials (LT_USERNAME, LT_ACCESS_KEY)")
        sys.exit(1)

    try:
        app_url = upload_apk_to_lambdatest(
            args.apk_path, args.app_name, username, access_key
        )
        print(f"Success: {app_url}")
    except Exception as e:
        print(f"❌ Failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
