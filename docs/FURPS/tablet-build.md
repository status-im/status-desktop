# Tablet Build FURPS ([#17941](https://github.com/status-im/status-app/issues/17941))

## Functionality
- Partial feature parity with desktop app expected - no keycard, biometrics and dapps. To be added later.
- Use **light Waku client** instead of full node - TBD
- No tablet-exclusive features planned

## Usability
- Reuse current desktop layout; no tablet-specific design system
- UX is a **secondary goal** (strategic priority is Nim ecosystem reach)
- Virtual keyboard support
- No onboarding enhancements required

## Reliability
- Target crash-free rate: **90%**
- Crash logging behavior: use default platform handling (to be clarified)

## Performance
- Performance targets:
  - App startup: < **3s**
  - Community screen: < **2s**
  - Chat screen: < **1s**
- Device target: **Mid/high-end tablets** only
- Resource use: < **2.5 GB memory** with a heavy account
- Battery: **Medium consumption** (TBD exact metric)

## Supportability
- OS version targets (based on Qt6 defaults):
  - iOS: **16+**
  - Android: **9+**
- Test builds (TestFlight, Google Play)
- Development can be done on both emulators and real device
- The build system supports Qt6+