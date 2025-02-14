import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding.enums 1.0

OnboardingPage {
    id: root

    required property int syncState // Onboarding.ProgressState.xxx

    signal loginToAppRequested()
    signal restartSyncRequested()
    signal loginWithSeedphraseRequested()

    states: [
        State {
            name: "inprogress"
            when: root.syncState === Onboarding.ProgressState.InProgress || root.syncState === Onboarding.ProgressState.Idle
            PropertyChanges {
                target: root
                title: qsTr("Profile sync in progress...")
            }
            PropertyChanges {
                target: subtitle
                text: qsTr("Your profile data is being synced to this device")
            }
            PropertyChanges {
                target: iconLoader
                sourceComponent: loadingIndicator
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/status_sync_progress")
            }
            PropertyChanges {
                target: subImageText
                text: qsTr("Please keep both devices switched on and connected to the same network until the sync is complete")
                visible: true
            }
        },
        State {
            name: "success"
            when: root.syncState === Onboarding.ProgressState.Success
            PropertyChanges {
                target: root
                title: qsTr("Profile synced")
            }
            PropertyChanges {
                target: subtitle
                text: qsTr("Your profile data has been synced to this device")
            }
            PropertyChanges {
                target: iconLoader
                sourceComponent: successIcon
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/status_sync_success")
            }
            PropertyChanges {
                target: loginButton
                visible: true
            }
        },
        State {
            name: "failed"
            when: root.syncState === Onboarding.ProgressState.Failed
            PropertyChanges {
                target: root
                title: "<font color='%1'>".arg(Theme.palette.dangerColor1) + qsTr("Failed to pair devices") + "</font>"
            }
            PropertyChanges {
                target: subtitle
                text: qsTr("Try again and double-check the instructions")
            }
            PropertyChanges {
                target: iconLoader
                sourceComponent: failedIcon
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/status_sync_failed")
            }
            PropertyChanges {
                target: tryAgainButton
                visible: true
            }
            PropertyChanges {
                target: loginWithSeedphraseButton
                visible: true
            }
            PropertyChanges {
                target: loginAnywayButton
                visible: true
            }
        }
    ]

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(400, root.availableWidth)
            spacing: Theme.halfPadding

            Loader {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                id: iconLoader
            }

            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                text: root.title
                horizontalAlignment: Text.AlignHCenter
            }
            StatusBaseText {
                id: subtitle
                Layout.fillWidth: true
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StatusImage {
                id: image
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(224, parent.width)
                Layout.preferredHeight: Math.min(214, height)
                Layout.topMargin: Theme.bigPadding
                Layout.bottomMargin: Theme.bigPadding
                source: Theme.png("onboarding/status_generate_keys")
                mipmap: true
            }

            StatusBaseText {
                id: subImageText
                Layout.fillWidth: true
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                visible: false
            }

            StatusButton {
                objectName: "btnLogin"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 240
                id: loginButton
                text: qsTr("Log in")
                visible: false
                onClicked: root.loginToAppRequested()
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 240
                id: tryAgainButton
                text: qsTr("Try to pair again")
                visible: false
                onClicked: root.restartSyncRequested()
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 240
                id: loginWithSeedphraseButton
                text: qsTr("Log in via recovery phrase")
                visible: false
                isOutline: true
                onClicked: root.loginWithSeedphraseRequested()
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 240
                id: loginAnywayButton
                text: qsTr("Log in anyway")
                visible: false
                isOutline: true
                onClicked: root.loginToAppRequested()
            }
        }
    }

    Component {
        id: loadingIndicator
        Rectangle {
            color: Theme.palette.baseColor2
            radius: width/2
            StatusDotsLoadingIndicator {
                anchors.centerIn: parent
            }
        }
    }

    Component {
        id: successIcon
        StatusRoundIcon {
            asset.name: "check-circle"
            asset.color: Theme.palette.successColor1
            asset.bgColor: Theme.palette.successColor2
        }
    }

    Component {
        id: failedIcon
        StatusRoundIcon {
            asset.name: "close-circle"
            asset.color: Theme.palette.dangerColor1
            asset.bgColor: Theme.palette.dangerColor3
        }
    }
}
