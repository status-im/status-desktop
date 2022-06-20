import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    //% "Primary username"
    title: qsTrId("ens-primary-username")

    property var ensUsernamesStore
    property string newUsername: ""

    onOpened: {
        for(var i in ensNames.contentItem.children){
            ensNames.contentItem.children[i].checked = ensNames.contentItem.children[i].text === popup.ensUsernamesStore.preferredUsername
        }
    }

    StyledText {
        id: lbl1
        text: popup.ensUsernamesStore.preferredUsername ?
              //% "Your messages are displayed to others with this username:"
              qsTrId("your-messages-are-displayed-to-others-with-this-username-")
              :
              //% "Once you select a username, you won’t be able to disable it afterwards. You will only be able choose a different username to display."
              qsTrId("once-you-select-a-username--you-won-t-be-able-to-disable-it-afterwards--you-will-only-be-able-choose-a-different-username-to-display-")
        font.pixelSize: Style.current.primaryTextFontSize
        wrapMode: Text.WordWrap
        width: parent.width
    }

    StyledText {
        id: lbl2
        anchors.top: lbl1.bottom
        anchors.topMargin: Style.current.padding
        text: popup.ensUsernamesStore.preferredUsername
        font.pixelSize: Style.dp(17)
        font.weight: Font.Bold
    }

    ScrollView {
        anchors.fill: parent
        anchors.top: lbl2.bottom
        anchors.topMargin: Style.dp(70)
        Layout.fillWidth: true
        Layout.fillHeight: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ensNames.contentHeight > ensNames.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            anchors.fill: parent
            model: root.ensUsernamesStore.ensUsernamesModel
            spacing: 0
            clip: true
            id: ensNames
            delegate: RadioDelegate {
                id: radioDelegate
                text: ensUsername
                checked: popup.ensUsernamesStore.preferredUsername === ensUsername

                contentItem: StyledText {
                    color: Style.current.textColor
                    text: radioDelegate.text
                    rightPadding: radioDelegate.indicator.width + radioDelegate.spacing
                    topPadding: Style.current.halfPadding
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        parent.checked = true
                        newUsername = ensUsername;
                    }
                }
            }
        }
    }

    onNewUsernameChanged: {
        btnSelectPreferred.state = newUsername === popup.ensUsernamesStore.preferredUsername ? "inactive" : "active"
    }

    footer: Item {
        width: parent.width
        height: btnSelectPreferred.height

        Button {
            id: btnSelectPreferred
            width: Style.dp(44)
            height: Style.dp(44)
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            state: "inactive"
            states: [
                State {
                    name: "inactive"
                    PropertyChanges {
                        target: btnContinue
                        source: Style.svg("arrow-right-btn-inactive")
                    }
                },
                State {
                    name: "active"
                    PropertyChanges {
                        target: btnContinue
                        source: Style.svg("arrow-right-btn-active")
                    }
                }
            ]

            SVGImage {
                id: btnContinue
                width: Style.dp(50)
                height: Style.dp(50)
            }
            background: Rectangle {
                color: "transparent"
            }
            MouseArea {
                cursorShape: btnSelectPreferred.state === "active" ? Qt.PointingHandCursor : Qt.ArrowCursor
                anchors.fill: parent
                onClicked : {
                    if(btnSelectPreferred.state === "active"){
                        popup.ensUsernamesStore.setPrefferedEnsUsername(newUsername);
                        newUsername = "";
                        popup.close();
                    }
                }
            }
        }
    }
}

