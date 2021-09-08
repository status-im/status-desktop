import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

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
        contentItem.searchBox.input.text = "";
        contentItem.searchBox.input.forceActiveFocus(Qt.MouseFocusReason)
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

    contentItem: Column {
        width: popup.width
        property alias searchBox: searchBox

        Item { 
            height: 8
            width: parent.width
        }

        StatusInput {
            id: searchBox
            input.placeholderText: qsTr("Search for communities or topics")
            input.icon.name: "search"
            input.height: 36
            input.topPadding: 9
        }

        StatusModalDivider { topPadding: 8 }

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

                    StatusModalDivider {
                        bottomPadding: 8
                    }
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
                        if (!searchBox.input.text) {
                            return true
                        }
                        const lowerCaseSearchStr = searchBox.input.text.toLowerCase()
                        return name.toLowerCase().includes(lowerCaseSearchStr) || description.toLowerCase().includes(lowerCaseSearchStr)
                    }
                    height: visible ? implicitHeight : 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: name
                    subTitle: description
                    //% "%1 members"
                    tertiaryTitle: qsTrId("-1-members").arg(nbMembers)
                    statusListItemTitle.font.weight: Font.Bold
                    statusListItemTitle.font.pixelSize: 17
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

