import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup

    onOpened: {
        searchBox.text = "";
        searchBox.forceActiveFocus(Qt.MouseFocusReason)
    }

    header: Item {
        height: childrenRect.height
        width: parent.width

        StyledText {
            id: groupName
            text: qsTr("Communities")
            anchors.top: parent.top
            anchors.left: parent.left
            font.bold: true
            font.pixelSize: 17
        }

        Rectangle {
            id: moreActionsBtnContainer
            width: 32
            height: 32
            radius: Style.current.radius
            color: Style.current.transparent
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.top: parent.top
            anchors.topMargin: -5

            StyledText {
                id: moreActionsBtn
                text: "..."
                font.letterSpacing: 0.5
                font.bold: true
                lineHeight: 1.4
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 25
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.color = Style.current.border
                }
                onExited: {
                    parent.color = Style.current.transparent
                }
                onClicked: contextMenu.popup(-contextMenu.width + moreActionsBtn.width, moreActionsBtn.height - Style.current.smallPadding)
            }

            PopupMenu {
                id: contextMenu
                Action {
                    icon.source: "../../../img/import.svg"
                    icon.width: 16
                    icon.height: 16
                    text: qsTr("Access exisitng community")
                    onTriggered: openPopup(importCommunitiesPopupComponent)
                }
            }
        }

        Separator {
            anchors.top: groupName.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            anchors.leftMargin: -Style.current.padding
        }
    }

    SearchBox {
        id: searchBox
        //% "Search for communities or topics"
        placeholderText: qsTrId("search-for-communities-or-topics")
        iconWidth: 17
        iconHeight: 17
        customHeight: 36
        fontPixelSize: 15
    }

    ScrollView {
        id: scrollView
        width: parent.width
        anchors.topMargin: Style.current.padding
        anchors.top: searchBox.bottom
        anchors.bottom: parent.bottom
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: communitiesList.contentHeight > communitiesList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            anchors.fill: parent
            model: communitiesDelegateModel
            spacing: 4
            clip: true
            id: communitiesList

            section.property: "name"
            section.criteria: ViewSection.FirstCharacter
            section.delegate: Column {
                width: parent.width
                height: childrenRect.height + Style.current.halfPadding
                StyledText {
                    text: section.toUpperCase()
                }
                Separator {
                    anchors.left: popup.left
                    anchors.right: popup.right
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
            delegate: Item {
                // TODO add the search for the name and category once they exist
                visible: {
                    if (!searchBox.text) {
                        return true
                    }
                    const lowerCaseSearchStr = searchBox.text.toLowerCase()
                    return name.toLowerCase().includes(lowerCaseSearchStr) || description.toLowerCase().includes(lowerCaseSearchStr)
                }
                height: visible ? communityImage.height + Style.current.padding : 0
                width: parent.width

                Loader {
                    id: communityImage
                    sourceComponent: !!thumbnailImage ? commmunityImgCmp : letterIdenticonCmp
                }

                Component {
                    id: commmunityImgCmp
                    RoundedImage {
                        source: thumbnailImage
                        width: 40
                        height: 40
                    }
                }

                Component {
                    id: letterIdenticonCmp
                    StatusLetterIdenticon {
                        width: 40
                        height: 40
                        chatName: name
                        color: communityColor || Style.current.blue
                    }
                }

                StyledText {
                    id: communityName
                    text: name
                    anchors.left: communityImage.right
                    anchors.leftMargin: Style.current.padding
                    font.pixelSize: 17
                    font.weight: Font.Bold
                }

                StyledText {
                    id: communityDesc
                    text: description
                    anchors.left: communityName.left
                    anchors.right: parent.right
                    anchors.top: communityName.bottom
                    font.pixelSize: 15
                    font.weight: Font.Thin
                    elide: Text.ElideRight
                }

                StyledText {
                    id: communityMembers
                    text: nbMembers === 1 ?
                              qsTr("1 member") :
                              qsTr("%1 members").arg(nbMembers)
                    anchors.left: communityDesc.left
                    anchors.right: parent.right
                    anchors.top: communityDesc.bottom
                    font.pixelSize: 13
                    color: Style.current.secondaryText
                    font.weight: Font.Thin
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
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

    footer: StatusButton {
        id: createBtn
        text: qsTr("Create a community")
        anchors.right: parent.right
        onClicked: {
            openPopup(createCommunitiesPopupComponent)
            popup.close()
        }
    }
}

