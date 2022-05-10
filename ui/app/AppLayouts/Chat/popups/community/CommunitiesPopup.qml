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
    signal openCommunityDetail()
    signal importCommunityClicked()
    signal createCommunityClicked()

    onOpened: {
        contentItem.searchBox.input.text = "";
        contentItem.searchBox.input.forceActiveFocus(Qt.MouseFocusReason)
    }

    header.title: qsTr("Communities")
    headerActionButton: StatusFlatRoundButton {
        type: StatusFlatRoundButton.Type.Secondary
        width: 32
        height: 32
        icon.name: "more"

        onClicked: contextMenu.popup(-contextMenu.width+width, height + 4)

        StatusPopupMenu {
            id: contextMenu
            width: 230
            StatusMenuItem {
                icon.name: "download"
                text: qsTr("Access existing community")
                onTriggered: {
                    popup.importCommunityClicked();
                }
            }
        }
    }

    contentItem: Item {
        Column {
            id: contentItem
            anchors.horizontalCenter: parent.horizontalCenter
            property alias searchBox: searchBox

            Item {
                height: 8
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
                        tertiaryTitle: qsTr("%1 members").arg(model.members.count)
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
                                popup.openCommunityDetail();
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
            text: qsTr("Create a community")
            onClicked: {
                popup.createCommunityClicked();
                popup.close()
            }
        }
    ]
}

