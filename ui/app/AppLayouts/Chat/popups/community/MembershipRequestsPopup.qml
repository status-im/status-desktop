import QtQuick 2.12
import QtQuick.Controls 2.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1


import utils 1.0
import shared 1.0

StatusModal {
    id: popup
    property var store
    property var communitySectionModule
    property var communityData
    onOpened: {
        contentItem.errorText.text = ""
    }

    header.title: qsTr("Membership requests")
    header.subTitle: contentItem.membershipRequestList.count

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
                model: popup.communityData.pendingRequestsToJoin
                clip: true

                delegate: StatusListItem {
                    anchors.horizontalCenter: parent.horizontalCenter
                    property var contactDetails: Utils.getContactDetailsAsJson(model.pubKey)

                    property string displayName: contactDetails.displayName || popup.store.generateAlias(model.pubKey)
                    image.source: contactDetails.thumbnailImage
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
                                onClicked: communitySectionModule.acceptRequestToJoinCommunity(id)
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
                                onClicked: communitySectionModule.declineRequestToJoinCommunity(id)
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
