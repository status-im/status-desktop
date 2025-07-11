#!/usr/bin/env python3
"""
GitHub artifact discovery and selection utility.
Handles artifact naming collisions by using run metadata.
"""

import os
import sys
import argparse
import requests
import json
from datetime import datetime, timedelta
from typing import List, Dict, Optional


class GitHubArtifactDiscovery:
    def __init__(self, token: str, repo: str = "status-im/status-desktop"):
        self.token = token
        self.repo = repo
        self.headers = {
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json",
        }

    def list_artifacts(
        self,
        workflow_name: str = "Android Build APK",
        days_back: int = 30,
        per_page: int = 50,
    ) -> List[Dict]:
        """List artifacts from workflow runs with metadata."""

        # Get workflow runs first
        since_date = (datetime.now() - timedelta(days=days_back)).isoformat()

        runs_url = f"https://api.github.com/repos/{self.repo}/actions/workflows/{workflow_name.replace(' ', '-').lower()}.yml/runs"
        params = {
            "per_page": per_page,
            "status": "completed",
            "created": f">={since_date}",
        }

        response = requests.get(runs_url, headers=self.headers, params=params)
        if response.status_code != 200:
            # Try alternative workflow filename
            runs_url = f"https://api.github.com/repos/{self.repo}/actions/workflows/android-build.yml/runs"
            response = requests.get(runs_url, headers=self.headers, params=params)

        if response.status_code != 200:
            raise Exception(f"Failed to fetch workflow runs: {response.status_code}")

        runs = response.json()["workflow_runs"]

        # Get artifacts for each run
        artifacts_with_metadata = []
        for run in runs:
            artifacts_url = f"https://api.github.com/repos/{self.repo}/actions/runs/{run['id']}/artifacts"

            try:
                artifacts_response = requests.get(artifacts_url, headers=self.headers)
                if artifacts_response.status_code == 200:
                    artifacts = artifacts_response.json()["artifacts"]

                    for artifact in artifacts:
                        # Skip expired artifacts
                        if artifact["expired"]:
                            continue

                        # Extract architecture from name or run inputs
                        architecture = self._extract_architecture(artifact["name"], run)

                        artifacts_with_metadata.append(
                            {
                                "name": artifact["name"],
                                "id": artifact["id"],
                                "size_mb": round(
                                    artifact["size_in_bytes"] / 1024 / 1024, 1
                                ),
                                "created_at": artifact["created_at"],
                                "expires_at": artifact["expires_at"],
                                "run_id": run["id"],
                                "run_number": run["run_number"],
                                "branch": run["head_branch"],
                                "commit_sha": run["head_sha"][:8],
                                "commit_message": run["head_commit"]["message"].split(
                                    "\n"
                                )[0][:50],
                                "architecture": architecture,
                                "actor": run["actor"]["login"],
                                "workflow_name": run["name"],
                                "conclusion": run["conclusion"],
                            }
                        )
            except Exception as e:
                print(f"Warning: Failed to fetch artifacts for run {run['id']}: {e}")
                continue

        return sorted(
            artifacts_with_metadata, key=lambda x: x["created_at"], reverse=True
        )

    def _extract_architecture(self, artifact_name: str, run_data: Dict) -> str:
        """Extract architecture from artifact name or run metadata."""
        name_lower = artifact_name.lower()

        # Check artifact name for architecture hints
        if "x86_64" in name_lower or "x64" in name_lower:
            return "x86_64"
        elif "arm64" in name_lower or "aarch64" in name_lower:
            return "arm64"
        elif "arm" in name_lower and "arm64" not in name_lower:
            return "arm"
        elif "x86" in name_lower and "x86_64" not in name_lower:
            return "x86"

        # Check run inputs if available
        try:
            inputs = run_data.get("inputs", {})
            if "architecture" in inputs:
                return inputs["architecture"]
        except Exception:
            pass

        return "unknown"

    def find_latest_by_architecture(
        self, architecture: str = "x86_64", branch: str = None, days_back: int = 7
    ) -> Optional[Dict]:
        """Find the latest artifact for specified architecture."""
        artifacts = self.list_artifacts(days_back=days_back)

        # Filter by architecture
        matching = [a for a in artifacts if a["architecture"] == architecture]

        # Filter by branch if specified
        if branch:
            matching = [a for a in matching if a["branch"] == branch]

        # Return latest successful build
        for artifact in matching:
            if artifact["conclusion"] == "success":
                return artifact

        return None

    def search_artifacts(
        self,
        query: str = None,
        architecture: str = None,
        branch: str = None,
        days_back: int = 30,
    ) -> List[Dict]:
        """Search artifacts with flexible criteria."""
        artifacts = self.list_artifacts(days_back=days_back)

        results = artifacts

        if architecture:
            results = [a for a in results if a["architecture"] == architecture]

        if branch:
            results = [a for a in results if a["branch"] == branch]

        if query:
            query_lower = query.lower()
            results = [
                a
                for a in results
                if query_lower in a["name"].lower()
                or query_lower in a["commit_message"].lower()
                or query_lower in a["actor"].lower()
            ]

        return results

    def print_artifacts_table(self, artifacts: List[Dict], max_rows: int = 20):
        """Print artifacts in a readable table format."""
        if not artifacts:
            print("No artifacts found.")
            return

        print(
            f"\n📦 Found {len(artifacts)} artifacts (showing {min(len(artifacts), max_rows)}):\n"
        )

        # Table header
        print(
            f"{'Name':<25} {'Arch':<8} {'Branch':<15} {'Run#':<6} {'Size':<8} {'Age':<12} {'Actor':<12}"
        )
        print("-" * 95)

        for i, artifact in enumerate(artifacts[:max_rows]):
            age = self._format_age(artifact["created_at"])
            name = artifact["name"][:24]
            branch = artifact["branch"][:14] if artifact["branch"] else "unknown"

            print(
                f"{name:<25} {artifact['architecture']:<8} {branch:<15} "
                f"{artifact['run_number']:<6} {artifact['size_mb']}MB{'':<3} "
                f"{age:<12} {artifact['actor']:<12}"
            )

    def _format_age(self, created_at: str) -> str:
        """Format creation time as human-readable age."""
        created = datetime.fromisoformat(created_at.replace("Z", "+00:00"))
        now = datetime.now(created.tzinfo)
        delta = now - created

        if delta.days > 0:
            return f"{delta.days}d ago"
        elif delta.seconds > 3600:
            return f"{delta.seconds // 3600}h ago"
        else:
            return f"{delta.seconds // 60}m ago"


def main():
    parser = argparse.ArgumentParser(
        description="Discover GitHub artifacts intelligently"
    )
    parser.add_argument("--token", help="GitHub token (or set GITHUB_TOKEN env var)")
    parser.add_argument("--repo", default="status-im/status-desktop", help="Repository")
    parser.add_argument(
        "--architecture",
        choices=["x86_64", "arm64", "arm", "x86"],
        help="Filter by architecture",
    )
    parser.add_argument("--branch", help="Filter by branch")
    parser.add_argument("--query", help="Search query (name, commit, actor)")
    parser.add_argument("--days", type=int, default=7, help="Days to look back")
    parser.add_argument(
        "--latest",
        action="store_true",
        help="Find latest successful artifact for architecture",
    )
    parser.add_argument(
        "--format",
        choices=["table", "json", "name"],
        default="table",
        help="Output format",
    )

    args = parser.parse_args()

    token = args.token or os.getenv("GITHUB_TOKEN")
    if not token:
        print("❌ GitHub token required (--token or GITHUB_TOKEN env var)")
        sys.exit(1)

    try:
        discovery = GitHubArtifactDiscovery(token, args.repo)

        if args.latest:
            artifact = discovery.find_latest_by_architecture(
                architecture=args.architecture or "x86_64",
                branch=args.branch,
                days_back=args.days,
            )
            if artifact:
                if args.format == "json":
                    print(json.dumps(artifact, indent=2))
                elif args.format == "name":
                    print(artifact["name"])
                else:
                    print(f"✅ Latest {artifact['architecture']} artifact:")
                    print(f"   Name: {artifact['name']}")
                    print(f"   Run: #{artifact['run_number']} ({artifact['run_id']})")
                    print(f"   Branch: {artifact['branch']}")
                    print(
                        f"   Commit: {artifact['commit_sha']} - {artifact['commit_message']}"
                    )
                    print(f"   Created: {artifact['created_at']}")
            else:
                print("❌ No matching artifacts found")
                sys.exit(1)
        else:
            artifacts = discovery.search_artifacts(
                query=args.query,
                architecture=args.architecture,
                branch=args.branch,
                days_back=args.days,
            )

            if args.format == "json":
                print(json.dumps(artifacts, indent=2))
            elif args.format == "name":
                for artifact in artifacts:
                    print(artifact["name"])
            else:
                discovery.print_artifacts_table(artifacts)

    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
