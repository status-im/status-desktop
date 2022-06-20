import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1


import utils 1.0
import shared 1.0

StatusModal {
    id: popup

    property var communitiesList
    signal setActiveCommunity(string id)
    signal setObservedCommunity(string id)

    onOpened: {
        contentItem.searchBox.input.text = "";
        contentItem.searchBox.input.forceActiveFocus(Qt.MouseFocusReason)
    }

    //% "Communities"
    header.title: qsTrId("communities")
    headerActionButton: StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: Style.dp(32)
        height: width
        icon.name: "more"

        onClicked: contextMenu.popup(-contextMenu.width+width, height + 4)

        StatusPopupMenu {
            id: contextMenu
            width: Style.dp(230)
            StatusMenuItem {
                icon.name: "download"
                //% "Access existing community"
                text: qsTrId("access-existing-community")
                onTriggered: Global.openPopup(importCommunitiesPopupComponent)
            }
        }
    }

    contentItem: Item {
        Column {
            id: contentItem
            anchors.horizontalCenter: parent.horizontalCenter
            property alias searchBox: searchBox

            Item {
                height: Style.dp(8)
                width: parent.width
            }

            StatusInput {
                id: searchBox
                anchors.horizontalCenter: parent.horizontalCenter
                input.placeholderText: qsTr("Search for communities or topics")
                input.icon.name: "search"
            }

            StatusModalDivider { topPadding: 8 }

            ScrollView {
                width: parent.width
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                topPadding: Style.current.halfPadding
                bottomPadding: Style.current.halfPadding
                height: Style.dp(400)
                clip: true

                ListView {
                    anchors.fill: parent
                    model: communitiesDelegateModel
                    spacing: Style.current.radius/2
                    clip: true
                    id: communitiesList

                    section.property: "name"
                    section.criteria: ViewSection.FirstCharacter
                    section.delegate: Column {

                        StatusBaseText {
                            anchors.left: parent.left
                            anchors.leftMargin: Style.current.padding
                            text: section.toUpperCase()
                            font.pixelSize: Style.current.primaryTextFontSize
                            font.weight: Font.Medium
                            color: Theme.palette.directColor1
                        }

                        StatusModalDivider {
                            bottomPadding: Style.current.halfPadding
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

                    model: popup.communitiesList
                    delegate: StatusListItem {
                        visible: {
                            if (!searchBox.input.text) {
                                return true
                            }
                            const lowerCaseSearchStr = searchBox.input.text.toLowerCase()
                            return model.name.toLowerCase().includes(lowerCaseSearchStr) || model.description.toLowerCase().includes(lowerCaseSearchStr)
                        }
                        height: visible ? implicitHeight : 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        title: model.name
                        subTitle: model.description
                        //% "%1 members"
                        tertiaryTitle: qsTrId("-1-members").arg(model.members.count)
                        statusListItemTitle.font.weight: Font.Bold
                        statusListItemTitle.font.pixelSize: 17
                        image.source: model.image
                        icon.isLetterIdenticon: !model.image
                        icon.background.color: model.color || Theme.palette.primaryColor1

                        sensor.onClicked: {
                            if (model.joined && model.isMember) {
                                popup.setActiveCommunity(model.id);
                            } else {
                                popup.setObservedCommunity(model.id);
                                Global.openPopup(communityDetailPopup)
                            }
                            popup.close()
                        }
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
                Global.openPopup(createCommunitiesPopupComponent)
                popup.close()
            }
        }
    ]
}

