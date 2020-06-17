import QtQuick 2.13
import QtQuick.Controls 2.13
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
        AddAccountWithSeed {
            id: addAccountWithSeedModal
        }
        AddAccountWithPrivateKey {
            id: addAccountWithPrivateKeydModal
        }
        AddWatchOnlyAccount {
            id: addWatchOnlyAccountModal
        }

        PopupMenu {
            id: newAccountMenu
            width: 280
            Action {
                text: qsTr("Generate an account")
                icon.source: "../../../img/generate_account.svg"
                onTriggered: {
                    generateAccountModal.open()
                }
            }
            Action {
                text: qsTr("Add a watch-only address")
                icon.source: "../../../img/add_watch_only.svg"
                onTriggered: {
                    addWatchOnlyAccountModal.open()
                }
            }
            Action {
                text: qsTr("Enter a seed phrase")
                icon.source: "../../../img/enter_seed_phrase.svg"
                onTriggered: {
                    addAccountWithSeedModal.open()
                }
            }
            Action {
                text: qsTr("Enter a private key")
                icon.source: "../../../img/enter_private_key.svg"
                onTriggered: {
                    addAccountWithPrivateKeydModal.open()
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
