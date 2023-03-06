# status-desktop-ui-test
UI test application for **Status Desktop**

* Test automation project that uses [Squish](https://www.froglogic.com/squish/) as a testing tool with [BDD](https://www.froglogic.com/squish/features/bdd-behavior-driven-development-testing/).
* Information about its architecture can be found in [wiki](https://hackmd.io/@status-desktop/B1MlJV5nd/%2Fm9D4p_y7ShOm3ooD7GAT0A).

![Screenshot 2022-02-25 at 10 22 45](https://user-images.githubusercontent.com/97019400/155689587-e933bbfa-519c-4f73-90a7-c019c0bb163f.png)


## Preparing the environment to develop and run tests
1) Install [Squish](https://doc.froglogic.com/squish/latest/) and run its IDE.
2) `File / Open Test Suite` and browse to `testSuites` directory.
3) Once the suite is open, click `Test Suite Settings` button to configure the **AUT** (Application Under test).
    * Select `AUT tab` and browse until the corresponding `status-desktop\bin\nim_status_client` binary is set.
    * Uncheck `Automatically start the AUT` option (if it is already checked).
    * Save changes.

Now you should be able to create new suites, test cases and run the existing ones just only by clicking `Run` buttons!!

[Here](https://hackmd.io/@status-desktop/S19eu_Baq) a more detailed **installation guide** specific for this project.

## Squish versions tested

| Status APP Qt version | Squish version | Squish Qt version | Local macOS Monterey 12.3.1 | CI  |
|---|---|---|---|---|
| 5.14.2 | 6.7.2 | 5.14 | OK | OK |
| 5.15.2 | 6.7.2 | 5.14 | OK | OK |
| 5.15.2 | 7.0.1 | 5.15 | KO | KO |
| 5.15.2 | 7.1.0 | 5.14 | KO | KO |
| 5.15.2 | 7.1.0 | 5.15 | KO | KO |
| 5.15.2 | 7.1.-20230222-1555 (SNAPSHOT) | 5.15 | OK | OK (manual extension removal*) |

*NOTE 1*: KO means the test execution hangs on `squish.waitForObject()` or `squish.findObject()`. Seen this behaviour particularly in `Onboarding / Create Password Screen`. 

*NOTE 2*: The `7.1-SNAPSHOT` version for `linux` needs a manual interaction (if not the app crashes when the test execution starts). It is needed to rename library in:

SQUISHDIR\lib\extensions

     squishqtwaylandcompositor.ext

to

     squishqtwaylandcompositor_off.ext


Last status app tested: Master branch - Commit: `d31acbfb48fe7027657a08c648836d9a8f11240c`