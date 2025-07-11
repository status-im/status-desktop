import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Controls

import AppLayouts.Onboarding.enums

OnboardingPage {
    id: root

    readonly property bool backAvailableHint: false
    required property int convertKeycardAccountState

    signal restartRequested()
    signal backToLoginRequested()

    StateGroup {
        states: [
            State {
                when: root.convertKeycardAccountState === Onboarding.ProgressState.InProgress

                PropertyChanges {
                    target: root
                    title: qsTr("Re-encrypting your profile data")
                }
                PropertyChanges {
                    target: iconLoader
                    sourceComponent: loadingIndicator
                }
                PropertyChanges {
                    target: subtitle
                    text: qsTr("Your data must be re-encrypted with your new password which may take some time.")
                }
                PropertyChanges {
                    target: warningText
                    visible: true
                }
                PropertyChanges {
                    target: btnQuit
                    visible: false
                }
                PropertyChanges {
                    target: btnTryAgain
                    visible: false
                }
            },
            State {
                when: root.convertKeycardAccountState === Onboarding.ProgressState.Success

                PropertyChanges {
                    target: root
                    title: qsTr("Re-encryption complete")
                }
                PropertyChanges {
                    target: iconLoader
                    sourceComponent: successIcon
                }
                PropertyChanges {
                    target: subtitle
                    text: qsTr("Your data was successfully re-encrypted with your new password. You can now restart Status and log in to your profile using the password you just created.")
                }
                PropertyChanges {
                    target: warningText
                    visible: false
                }
                PropertyChanges {
                    target: btnQuit
                    visible: true
                }
                PropertyChanges {
                    target: btnTryAgain
                    visible: false
                }
            },
            State {
                when: root.convertKeycardAccountState === Onboarding.ProgressState.Failed

                PropertyChanges {
                    target: root
                    title: qsTr("Re-encryption failed")
                }
                PropertyChanges {
                    target: iconLoader
                    sourceComponent: failedIcon
                }
                PropertyChanges {
                    target: subtitle
                    text: qsTr("Your data must be re-encrypted with your new password which may take some time.")
                }
                PropertyChanges {
                    target: warningText
                    visible: true
                }
                PropertyChanges {
                    target: btnQuit
                    visible: false
                }
                PropertyChanges {
                    target: btnTryAgain
                    visible: true
                }
            }
        ]
    }

    contentItem: Item {
        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            spacing: Theme.bigPadding

            Loader {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                id: iconLoader

                sourceComponent: Rectangle {
                    color: Theme.palette.baseColor2
                    radius: width/2
                    StatusDotsLoadingIndicator {
                        anchors.centerIn: parent
                    }
                }
            }

            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: Theme.fontSize22
                font.bold: true
                wrapMode: Text.WordWrap
                text: root.title
                horizontalAlignment: Text.AlignHCenter
            }

            StatusBaseText {
                id: subtitle
                Layout.fillWidth: true
                Layout.maximumWidth: 388
                Layout.alignment: Qt.AlignCenter
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                visible: !!text
            }

            StatusBaseText {
                id: warningText
                Layout.fillWidth: true
                Layout.maximumWidth: 388
                Layout.alignment: Qt.AlignCenter
                color: Theme.palette.dangerColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Do not quit Status or turn off your device. Doing so will lead to loss of profile and inability to restart the app.")
            }

            StatusButton {
                id: btnQuit

                visible: false
                isOutline: false
                text: qsTr("Restart Status and log in with new password")
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.restartRequested()
            }

            StatusButton {
                id: btnTryAgain

                visible: false
                isOutline: false
                text: qsTr("Back to login")
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.backToLoginRequested()
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
