import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0
import utils 1.0

import "../popups"

Item {
    id: root

    property var ensUsernamesStore

    property int profileContentWidth

    signal addBtnClicked()
    signal selectEns(string username, string chainId)

    Component.onCompleted: {
        d.updateNumberOfPendingEnsUsernames()
    }

    QtObject {
        id: d

        property int numOfPendingEnsUsernames: 0
        readonly property bool hasConfirmedEnsUsernames: root.ensUsernamesStore.ensUsernamesModel.count > 0
                                                         && numOfPendingEnsUsernames !== root.ensUsernamesStore.ensUsernamesModel.count

        function updateNumberOfPendingEnsUsernames() {
            numOfPendingEnsUsernames = root.ensUsernamesStore.numOfPendingEnsUsernames()
        }
    }

    Connections {
        target: root.ensUsernamesStore.ensUsernamesModule
        function onUsernameConfirmed(username: string) {
            d.updateNumberOfPendingEnsUsernames()
            chatSettingsLabel.visible = true
        }
    }

    Item {
        anchors.top: parent.top
        width: profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter

        StatusBaseText {
            id: sectionTitle
            text: qsTr("ENS usernames")
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: parent.top
            anchors.topMargin: 24
            font.weight: Font.Bold
            font.pixelSize: 20
            color: Theme.palette.directColor1
        }

        Item {
            id: addUsername
            anchors.top: sectionTitle.bottom
            anchors.topMargin: Style.current.bigPadding
            width: addButton.width + usernameText.width + Style.current.padding
            height: addButton.height

            StatusRoundButton {
                id: addButton
                width: 40
                height: 40
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "add"
                type: StatusRoundButton.Type.Secondary
            }

            StatusBaseText {
                id: usernameText
                text: qsTr("Add username")
                color: Theme.palette.primaryColor1
                anchors.left: addButton.right
                anchors.leftMargin: Style.current.padding
                anchors.verticalCenter: addButton.verticalCenter
                font.pixelSize: 15
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: addBtnClicked()
            }
        }


        StatusBaseText {
            id: usernamesLabel
            text: qsTr("Your usernames")
            anchors.left: parent.left
            anchors.top: addUsername.bottom
            anchors.topMargin: 24
            font.pixelSize: 16
            color: Theme.palette.directColor1
        }

        Item {
            id: ensList
            anchors.top: usernamesLabel.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            height: 200

            StatusListView {
                id: lvEns
                anchors.fill: parent
                model: root.ensUsernamesStore.currentChainEnsUsernamesModel

                spacing: 10
                delegate: StatusListItem {
                    readonly property int indexOfDomainStart: model.ensUsername.indexOf(".")

                    width: ListView.view.width
                    title: model.ensUsername.substr(0, indexOfDomainStart)
                    subTitle: model.ensUsername.substr(indexOfDomainStart)
                    titleAsideText: model.isPending ? qsTr("(pending)") : ""

                    statusListItemTitle.font.pixelSize: 17
                    statusListItemTitle.font.bold: true

                    asset.isImage: false
                    asset.isLetterIdenticon: true
                    asset.bgColor: Theme.palette.primaryColor1
                    asset.width: 40
                    asset.height: 40

                    components: [
                        StatusIcon {
                            icon: "next"
                            color: Theme.palette.baseColor1
                        }
                    ]

                    onClicked: {
                        root.selectEns(model.ensUsername, model.chainId)
                    }
                }

            }
        }

        Separator {
            id: separator
            anchors.topMargin: Style.current.padding
            anchors.top: ensList.bottom
        }

        StatusBaseText {
            id: chatSettingsLabel
            visible: d.hasConfirmedEnsUsernames
            text: qsTr("Chat settings")
            anchors.left: parent.left
            anchors.top: ensList.bottom
            anchors.topMargin: 24
            font.pixelSize: 16
            color: Theme.palette.directColor1
        }

        Item {
            width: childrenRect.width
            height: childrenRect.height

            id: primaryUsernameItem
            anchors.left: parent.left
            anchors.top: chatSettingsLabel.bottom
            anchors.topMargin: 24

            StatusBaseText {
                id: usernameLabel
                visible: chatSettingsLabel.visible
                text: qsTr("Primary Username")
                font.pixelSize: 14
                font.weight: Font.Bold
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: usernameLabel2
                visible: chatSettingsLabel.visible
                text: root.ensUsernamesStore.preferredUsername || qsTr("None selected")
                anchors.left: usernameLabel.right
                anchors.leftMargin: Style.current.padding
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Global.openPopup(ensPopupComponent)
                }
            }
        }

        StatusMessage {
            id: messagesShownAs

            anchors.top: !visible ? separator.bottom : primaryUsernameItem.bottom
            anchors.topMargin: Style.current.padding * 2

            visible: d.hasConfirmedEnsUsernames
                     && root.ensUsernamesStore.preferredUsername !== ""

            timestamp: new Date().getTime()
            disableHover: true
            profileClickable: false

            messageDetails: StatusMessageDetails {
                contentType: StatusMessage.ContentType.Text
                messageText: qsTr("Hey!")
                amISender: false
                sender.displayName: root.ensUsernamesStore.preferredUsername
                sender.profileImage.assetSettings.isImage: true
                sender.profileImage.assetSettings.color: Utils.colorForPubkey(root.ensUsernamesStore.pubkey)
                sender.profileImage.name: root.ensUsernamesStore.icon
            }
        }

        StatusBaseText {
            anchors.top: messagesShownAs.bottom
            anchors.left: messagesShownAs.left
            anchors.topMargin: Style.current.padding
            text: qsTr("You’re displaying your ENS username in chats")
            font.pixelSize: 14
            color: Theme.palette.baseColor1
        }
    }

    Component {
        id: ensPopupComponent

        ENSPopup {
            ensUsernamesStore: root.ensUsernamesStore
            destroyOnClose: true
        }
    }
}
