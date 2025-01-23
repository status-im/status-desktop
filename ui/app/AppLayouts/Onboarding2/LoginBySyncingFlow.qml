import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Onboarding2.pages 1.0
import AppLayouts.Onboarding.enums 1.0

SQUtils.QObject {
    id: root

    required property StackView stackView
    required property var validateConnectionString
    required property int syncState

    signal syncProceedWithConnectionString(string connectionString)
    signal loginWithSeedphraseRequested
    signal finished

    function init() {
        root.stackView.push(loginBySyncPage)
    }

    Component {
        id: loginBySyncPage

        LoginBySyncingPage {
            validateConnectionString: root.validateConnectionString

            onSyncProceedWithConnectionString: {
                root.syncProceedWithConnectionString(connectionString)
                root.stackView.push(syncProgressPage)
            }
        }
    }

    Component {
        id: syncProgressPage

        SyncProgressPage {
            readonly property bool backAvailableHint:
                root.syncState === Onboarding.ProgressState.Failed

            syncState: root.syncState

            onLoginToAppRequested: root.finished()
            onRestartSyncRequested: root.stackView.pop()

            onLoginWithSeedphraseRequested: root.loginWithSeedphraseRequested()
        }
    }
}
