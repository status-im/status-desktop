import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

Rectangle {
    id: addAccount
    width: 36
    height: 36
    color: Theme.blue
    radius: 50
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.top: parent.top
    anchors.topMargin: 59

    Image {
        id: addAccountLbl
        fillMode: Image.PreserveAspectFit
        source: "../../../img/plusSign.svg"
        width: 14
        height: 14
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        state: "default"
        rotation: 0
        states: [
            State {
                name: "default"
                PropertyChanges {
                    target: addAccountLbl
                    rotation: 0
                }
            },
            State {
                name: "rotated"
                PropertyChanges {
                    target: addAccountLbl
                    rotation: 45
                }
            }
        ]

        transitions: [
            Transition {
                from: "default"
                to: "rotated"
                RotationAnimation {
                    duration: 150
                    direction: RotationAnimation.Clockwise
                    easing.type: Easing.InCubic
                }
            },
            Transition {
                from: "rotated"
                to: "default"
                RotationAnimation {
                    duration: 150
                    direction: RotationAnimation.Counterclockwise
                    easing.type: Easing.OutCubic
                }
            }
        ]
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            addAccountLbl.state = "rotated"
            let x = addAccountLbl.x + addAccountLbl.width / 2 - newAccountMenu.width / 2
            newAccountMenu.popup(x, addAccountLbl.height + 10)
        }

        GenerateAccountModal {
            id: generateAccountModal
        }

        PopupMenu {
            id: newAccountMenu
            width: 280
            QQC2.Action {
                text: qsTr("Generate an account")
                icon.source: "../../../img/generate_account.svg"
                onTriggered: {
                    generateAccountModal.open()
                }
            }
            QQC2.Action {
                text: qsTr("Add a watch-only address")
                icon.source: "../../../img/add_watch_only.svg"
                onTriggered: {
                    console.log("TODO: Add a watch-only address")
                }
            }
            QQC2.Action {
                text: qsTr("Enter a seed phrase")
                icon.source: "../../../img/enter_seed_phrase.svg"
                onTriggered: {
                    console.log("TODO: Enter a seed phrase")
                }
            }
            QQC2.Action {
                text: qsTr("Enter a private key")
                icon.source: "../../../img/enter_private_key.svg"
                onTriggered: {
                    console.log("TODO: Enter a private key")
                }
            }
            onAboutToHide: {
                addAccountLbl.state = "default"
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;height:36;width:36}
}
##^##*/
