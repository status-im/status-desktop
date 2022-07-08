import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls.chat 1.0

import "../../layouts"

SettingsPageLayout {
    id: root

    property var membersModel

    property bool editable: true
    property int pendingRequests

    signal membershipRequestsClicked()
    signal userProfileClicked(string id)
    signal kickUserClicked(string id)
    signal banUserClicked(string id)

    title: qsTr("Members")

    content: ColumnLayout {
        spacing: 8

        StatusInput {
            id: memberSearch

            Layout.fillWidth: true

            leftPadding: 0
            rightPadding: 0
            input.placeholderText: qsTr("Member name")
        }

        StatusContactRequestsIndicatorListItem {
            id: memberRequestsButton

            Layout.fillWidth: true

            visible: root.editable && root.pendingRequests > 0
            title: qsTr("Membership requests")
            requestsCount: root.pendingRequests
            sensor.onClicked: root.membershipRequestsClicked()
        }

        Rectangle {
            Layout.fillWidth: true

            implicitHeight: 1
            visible: memberRequestsButton.visible
            color: Theme.palette.statusPopupMenu.separatorColor
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter

            visible: memberList.count === 0
            text: qsTr("Community members will appear here")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignHCenter

            visible: !!memberSearch.input.text && memberList.height == 0
            text: qsTr("No contacts found")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }

        ListView {
            id: memberList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: root.membersModel
            clip: true

            // TODO: use StatusMemberListItem (it does not behave correctly right now)
            delegate: StatusListItem {
                id: memberItem

                readonly property bool itsMe: model.pubKey.toLowerCase() === userProfile.pubKey.toLowerCase()
                readonly property bool isOnline: model.onlineStatus === Constants.onlineStatus.online

                width: memberList.width

                // FIXME: use QSortFilterProxyModel instead
                visible: memberSearch.input.text === "" || title.toLowerCase().includes(memberSearch.input.text.toLowerCase())
                height: visible ? implicitHeight : 0

                title: {
                    if (memberItem.itsMe) {
                        return qsTr("You")
                    }
                    return !model.displayName.endsWith(".eth") ? model.displayName : Utils.removeStatusEns(model.displayName)
                }
                subTitle: Utils.getElidedCompressedPk(model.pubKey)

                statusListItemIcon {
                    name: model.displayName
                    badge {
                        visible: true
                        color: memberItem.isOnline ? Theme.palette.successColor1 : Theme.palette.baseColor1
                    }
                }

                image {
                    width: 40
                    height: 40
                    source: model.icon
                }

                icon {
                    width: 40
                    height: 40
                    color: Utils.colorForPubkey(model.pubKey)
                    letterSize: Math.max(4, root.imageWidth / 2.4)
                    charactersLen: 2
                    isLetterIdenticon: true
                }

                ringSettings {
                    ringSpecModel: Utils.getColorHashAsJson(model.pubKey)
                    ringPxSize: Math.max(icon.width / 24.0)
                }

                onClicked: root.userProfileClicked(model.pubKey)

                components: [
                    StatusButton {
                        visible: root.editable && !memberItem.itsMe
                        text: qsTr("Ban")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Tiny

                        onClicked: root.banUserClicked(model.pubKey)
                    },

                    StatusButton {
                        visible: root.editable && !memberItem.itsMe
                        text: qsTr("Kick")
                        type: StatusBaseButton.Type.Danger
                        size: StatusBaseButton.Size.Tiny

                        onClicked: root.kickUserClicked(model.pubKey)
                    }
                ]
            }
        }
    }
}
