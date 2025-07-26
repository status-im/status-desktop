# Workflow Quick Reference

Simple reference for running E2E tests using GitHub Actions.

## Prerequisites (One Time Setup)

**GitHub Secrets** (Repository Admin):
- `LT_USERNAME` - Your LambdaTest username
- `LT_ACCESS_KEY` - Your LambdaTest access key

## Standard Workflow

### 1. Build APK
**Workflow**: `android-build.yml`
- Architecture: **x86_64** (required for LambdaTest)
- Output: `Status-tablet-x86_64` artifact

### 2. Run E2E Tests  
**Workflow**: `e2e-appium-android.yml`
- APK source: `Status-tablet-x86_64`
- Test target: `onboarding` (default)
- Device: Galaxy Tab S8 (default)

## Workflow Inputs Reference

| Input | Options | Default | Notes |
|-------|---------|---------|--------|
| **APK source type** | `github_artifact`, `direct_url`, `lambdatest_app_id` | `github_artifact` | How to get the APK |
| **APK source** | Artifact name, URL, or app ID | `Status-tablet-x86_64` | The actual APK location |
| **Build run ID** | GitHub run number | (optional) | For cross-repo artifacts |
| **Test selection type** | `marker`, `specific_test`, `test_file`, `custom` | `marker` | How to select tests |
| **Test target** | Test name or marker | `onboarding` | What to test |
| **Test environment** | `lambdatest`, `local` | `lambdatest` | Where to run |
| **Device config** | `default`, `pixel_tablet`, `galaxy_tab_a` | `default` | Device type |
| **Parallel execution** | `true`, `false` | `false` | Run tests in parallel |
| **Enable GitHub reporting** | `true`, `false` | `true` | GitHub test reports |

## Common Configurations

### Standard Onboarding Test
```yaml
APK source type: github_artifact
APK source: Status-tablet-x86_64  
Test target: onboarding
Device config: default
```

### Smoke Tests on Pixel Tablet
```yaml
APK source type: github_artifact
APK source: Status-tablet-x86_64
Test selection type: marker
Test target: smoke
Device config: pixel_tablet
```

### External APK Testing
```yaml
APK source type: direct_url
APK source: https://example.com/app.apk
Test target: critical
```

### Local Environment Testing
```yaml
APK source type: github_artifact
APK source: Status-tablet-arm64
Test environment: local
Test target: onboarding
```

## Test Markers

| Marker | Purpose |
|--------|---------|
| `onboarding` | Onboarding  flow |
| `smoke` | Quick critical functionality tests |
| `critical` | Essential features that must pass |

## Device Options

| Config | Device | Android Version |
|--------|---------|-----------------|
| `default` | Galaxy Tab S8 | 14 |
| `pixel_tablet` | Google Pixel Tablet | 14 |
| `galaxy_tab_a` | Samsung Galaxy Tab A | 13 |

## Results & Artifacts

**GitHub Actions UI**:
- ✅/❌ Pass/fail status
- Test summary with execution details

**Download Artifacts**:
- Dynamic name: `e2e-results-TIMESTAMP-TARGET-DEVICE`
- Contains: HTML report, screenshots, logs

**LambdaTest Dashboard**:
- Build name: `Status-Desktop-E2E-{run_number}`
- Live video and device logs

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| APK artifact not found | Verify exact name: `Status-tablet-x86_64` |
| LambdaTest upload fails | Check x86_64 architecture, verify secrets |
| Test execution fails | Download artifacts, check HTML report |
| GitHub reporting fails | Results still in downloadable artifacts |

## Important Notes

- **LambdaTest requires x86_64 APKs** - ARM builds won't work
- **Artifact names are case-sensitive** - Use exact match
- **Build run ID optional** - Only needed for cross-repo artifacts
- **Local testing requires** - Appium setup and ARM64 APKs

## Quick Commands

**Verify GitHub secrets**:
```bash
# Repository Settings → Secrets and variables → Actions
# Verify LT_USERNAME and LT_ACCESS_KEY exist
```

**Check artifact names**:
```bash
# Go to Android Build workflow run
# Check "Artifacts" section for exact name
```

**View results**:
```bash
# Download artifact: e2e-results-TIMESTAMP-TARGET-DEVICE.zip
# Open: e2e-results.html
```

For detailed guides, see:
- `docs/github-actions.md` - Complete workflow guide
- `docs/LOCAL_SETUP.md` - Local testing setup
- `docs/QUICK_START.md` - 5-minute local setup 