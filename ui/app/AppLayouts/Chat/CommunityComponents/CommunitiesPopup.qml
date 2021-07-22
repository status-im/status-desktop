import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtGraphicalEffects 1.13

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
        searchBox.text = "";
        searchBox.forceActiveFocus(Qt.MouseFocusReason)
    }

    //% "Communities"
    header.title: qsTrId("communities")
    headerActionButton: StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32
        icon.name: "more"

        onClicked: contextMenu.popup(-contextMenu.width+width, height + 4)

        StatusPopupMenu {
            id: contextMenu
            StatusMenuItem {
                icon.name: "download"
                //% "Access existing community"
                text: qsTrId("access-existing-community")
                onTriggered: openPopup(importCommunitiesPopupComponent)
            }
        }
    }

    content: Column {
        width: popup.width

        Item {
            height: 68
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            SearchBox {
                id: searchBox
                anchors.verticalCenter: parent.verticalCenter
                //% "Search for communities or topics"
                placeholderText: qsTrId("search-for-communities-or-topics")
                iconWidth: 17
                iconHeight: 17
                customHeight: 36
                fontPixelSize: 15
            }
        }

        StatusModalDivider {}

        ScrollView {
            width: parent.width
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            topPadding: 8
            bottomPadding: 8
            height: 400
            clip: true

            ListView {
                anchors.fill: parent
                model: communitiesDelegateModel
                spacing: 4
                clip: true
                id: communitiesList

                section.property: "name"
                section.criteria: ViewSection.FirstCharacter
                section.delegate: Column {

                    StatusBaseText {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        text: section.toUpperCase()
                        font.pixelSize: 15
                        font.weight: Font.Medium
                        color: Theme.palette.directColor1
                    }

                    StatusModalDivider {}
                }
            }

            DelegateModelGeneralized {
                id: communitiesDelegateModel
                lessThan: [
                    function(left, right) {
                        return left.name.toLowerCase() < right.name.toLowerCase()
                    }
                ]

                model: chatsModel.communities.list
                delegate: StatusListItem {
                    visible: {
                        if (!searchBox.text) {
                            return true
                        }
                        const lowerCaseSearchStr = searchBox.text.toLowerCase()
                        return name.toLowerCase().includes(lowerCaseSearchStr) || description.toLowerCase().includes(lowerCaseSearchStr)
                    }
                    height: visible ? implicitHeight : 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: name
                    //% "%1 members"
                    subTitle: qsTrId("-1-members").arg(nbMembers)
                    image.source: thumbnailImage
                    icon.isLetterIdenticon: !!!thumbnailImage
                    icon.background.color: communityColor

                    sensor.onClicked: {
                        if (joined && isMember) {
                            chatsModel.communities.setActiveCommunity(id)
                        } else {
                            chatsModel.communities.setObservedCommunity(id)
                            openPopup(communityDetailPopup)
                        }
                        popup.close()
                    }
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            //% "Create a community"
            text: qsTrId("create-community")
            onClicked: {
                openPopup(createCommunitiesPopupComponent)
                popup.close()
            }
        }
    ]
}

