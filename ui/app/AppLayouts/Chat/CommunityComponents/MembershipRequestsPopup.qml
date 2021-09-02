import QtQuick 2.12
import QtQuick.Controls 2.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import "../../../../imports"
import "../../../../shared"

StatusModal {
    id: popup

    onOpened: {
        contentComponent.errorText.text = ""
    }

    //% "Membership requests"
    header.title: qsTrId("membership-requests")
    header.subTitle: contentComponent.membershipRequestList.count

    contentItem: Column {
        property alias errorText: errorText
        property alias membershipRequestList: membershipRequestList
        width: popup.width

        StatusBaseText {
            id: errorText
            visible: !!text
            height: visible ? implicitHeight : 0
            color: Theme.palette.dangerColor1
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            width: parent.width
        }

        Item {
            height: 8
            width: parent.width
        }

        ScrollView {
            width: parent.width
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            topPadding: 8
            bottomPadding: 8
            height: 300
            clip: true

            ListView {
                id: membershipRequestList
                anchors.fill: parent
                model: chatsModel.communities.activeCommunity.communityMembershipRequests
                clip: true

                delegate: StatusListItem {
                    anchors.horizontalCenter: parent.horizontalCenter

                    property int contactIndex: profileModel.contacts.list.getContactIndexByPubkey(model.publicKey)
                    property string nickname: appMain.getUserNickname(model.publicKey)
                    property string profileImage: contactIndex === -1 ? "" : profileModel.contacts.list.rowData(contactIndex, 'thumbnailImage') 
                    property string displayName: Utils.getDisplayName(publicKey, contactIndex)

                    image.isIdenticon: !profileImage && model.identicon
                    image.source: profileImage || model.identicon

                    title: displayName

                    components: [
                        StatusRoundIcon {
                            icon.name: "thumbs-up"
                            icon.color: Theme.palette.white
                            icon.background.width: 28
                            icon.background.height: 28
                            icon.background.color: Theme.palette.successColor1
                            MouseArea {
                                id: thumbsUpSensor
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    errorText.text = ""
                                    const error = chatsModel.communities.acceptRequestToJoinCommunity(id)
                                    if (error) {
                                        errorText.text = error
                                    }
                                }
                            }
                        },
                        StatusRoundIcon {
                            icon.name: "thumbs-down"
                            icon.color: Theme.palette.white
                            icon.background.width: 28
                            icon.background.height: 28
                            icon.background.color: Theme.palette.dangerColor1
                            MouseArea {
                                id: thumbsDownSensor
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    errorText.text = ""
                                    const error = chatsModel.communities.declineRequestToJoinCommunity(id)
                                    if (error) {
                                        errorText.text = error
                                    }
                                }
                            }
                        }
                    ]
                }
            }
        }
    }

    leftButtons: [
        StatusRoundButton {
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: popup.close()
        }
    ]
}
