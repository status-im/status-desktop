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

        StatusScrollView {
            width: parent.width
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            topPadding: 8
            bottomPadding: 8
            height: 300

            StatusListView {
                id: membershipRequestList
                width: parent.width
                height: parent.height
                model: popup.communityData.pendingRequestsToJoin

                delegate: StatusListItem {
                    anchors.horizontalCenter: parent.horizontalCenter
                    property var contactDetails: Utils.getContactDetailsAsJson(model.pubKey)

                    property string displayName: contactDetails.displayName || popup.store.generateAlias(model.pubKey)
                    asset.name: contactDetails.thumbnailImage
                    asset.isImage: true
                    title: displayName

                    components: [
                        StatusRoundIcon {
                            asset.name: "thumbs-up"
                            asset.color: Theme.palette.white
                            asset.bgWidth: 28
                            asset.bgHeight: 28
                            asset.bgColor: Theme.palette.successColor1
                            MouseArea {
                                id: thumbsUpSensor
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: communitySectionModule.acceptRequestToJoinCommunity(id)
                            }
                        },
                        StatusRoundIcon {
                            asset.name: "thumbs-down"
                            asset.color: Theme.palette.white
                            asset.bgWidth: 28
                            asset.bgHeight: 28
                            asset.bgColor: Theme.palette.dangerColor1
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
        StatusBackButton {
            onClicked: popup.close()
        }
    ]
}
