import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding.enums 1.0
import AppLayouts.Onboarding2.controls 1.0

OnboardingPage {
    id: root

    required property int convertKeycardAccountState

    signal quitRequested()
    signal tryAgainRequested()

    StateGroup {
        states: [
            State {
                when: root.convertKeycardAccountState === Onboarding.ProgressState.InProgress

                PropertyChanges {
                    target: root
                    title: qsTr("Converting Keycard Account")
                }
                PropertyChanges {
                    target: iconLoader
                    sourceComponent: loadingIndicator
                }
                PropertyChanges {
                    target: subtitle
                    text: qsTr("in progress")
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
                    title: qsTr("Keycard account converted")
                }
                PropertyChanges {
                    target: iconLoader
                    sourceComponent: successIcon
                }
                PropertyChanges {
                    target: subtitle
                    text: qsTr("<done>")
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
                    title: qsTr("Failed to convert keycard account")
                }
                PropertyChanges {
                    target: iconLoader
                    sourceComponent: failedIcon
                }
                PropertyChanges {
                    target: subtitle
                    text: qsTr("<details>")
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
            spacing: Theme.halfPadding

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
                visible: !!text
            }

            Rectangle {
                id: image

                color: "red"
                implicitWidth: 231
                implicitHeight: 231
                radius: Math.max(width, height) / 2

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(231, parent.width)
                Layout.preferredHeight: Layout.preferredWidth
                Layout.topMargin: Theme.bigPadding
                Layout.bottomMargin: Theme.bigPadding + 100
            }

            MaybeOutlineButton {
                id: btnQuit

                visible: false
                isOutline: false
                text: qsTr("Quit and login with new password")
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.quitRequested()
            }

            MaybeOutlineButton {
                id: btnTryAgain

                visible: false
                isOutline: false
                text: qsTr("Try again")
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.tryAgainRequested()
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
