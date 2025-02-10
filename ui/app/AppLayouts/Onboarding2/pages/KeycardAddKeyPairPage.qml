import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

OnboardingPage {
    id: root

    property bool inProgress

    title: qsTr("Adding key pair to Keycard")

    StateGroup {
        states: State {
            when: !root.inProgress

            PropertyChanges {
                target: root
                title: qsTr("Key pair added to Keycard")
            }
            PropertyChanges {
                target: iconLoader
                sourceComponent: successIcon
            }
            PropertyChanges {
                target: image
                source: Theme.png("onboarding/status_keycard_adding_keypair_success")
            }
            PropertyChanges {
                target: subImageText
                text: qsTr("You will now require this Keycard to log into Status\nand transact with accounts derived from this key pair")
            }
        }
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

            StatusImage {
                id: image

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(231, parent.width)
                Layout.preferredHeight: Math.min(211, height)
                Layout.topMargin: Theme.bigPadding
                Layout.bottomMargin: Theme.bigPadding
                source: Theme.png("onboarding/status_keycard_adding_keypair")
                mipmap: true
            }

            StatusBaseText {
                id: subImageText

                Layout.fillWidth: true

                text: qsTr("Please keep the Keycard plugged in until the migration\nis complete")
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
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
}
