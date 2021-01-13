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

    title: qsTr("Communities")

    SearchBox {
        id: searchBox
        placeholderText: qsTr("Search for communities or topics")
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
            model: chatsModel.communities
            spacing: 4
            clip: true
            id: communitiesList

            section.property: "name"
            section.criteria: ViewSection.FirstCharacter
            section.delegate: Column {
                width: parent.width
                height: childrenRect.height + Style.current.halfPadding
                StyledText {
                    text: section
                }
                Separator {
                    anchors.left: popup.left
                    anchors.right: popup.right
                }
            }

            delegate: Item {
                // TODO add the serach for the name and category once they exist
                visible: {
                    if (!searchBox.text) {
                        return true
                    }
                    const lowerCaseSearchStr = searchBox.text.toLowerCase()
                    return name.toLowerCase().includes(lowerCaseSearchStr) || description.toLowerCase().includes(lowerCaseSearchStr)
                }
                height: visible ? communityImage.height + Style.current.padding : 0
                width: parent.width

                RoundedImage {
                    id: communityImage
                    width: 40
                    height: 40
                    // TODO get the real image once it's available
                    source: "../../../img/ens-header-dark@2x.png"
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
                        if (joined) {
                            chatsModel.setActiveCommunity(id)
                        } else {
                            chatsModel.setObservedCommunity(id)
                            openPopup(communityDetailPopup)
                        }
                        popup.close()
                    }
                }
            }
        }
    }

    footer: Item {
        width: parent.width
        height: importBtn.height

        StatusButton {
            id: importBtn
            text: qsTr("Import a community")
            anchors.right: createBtn.left
            anchors.rightMargin: Style.current.smallPadding
            onClicked: {
                openPopup(importCommunitiesPopupComponent)
                popup.close()
            }
        }

        StatusButton {
            id: createBtn
            text: qsTr("Create a community")
            anchors.right: parent.right
            onClicked: {
                openPopup(createCommunitiesPopupComponent)
                popup.close()
            }
        }
    }
}

