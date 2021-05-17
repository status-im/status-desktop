import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"
import "../components"
import "./"
import "../ContactsColumn"
import "../CommunityComponents"
import QtQuick.Dialogs 1.2

Column {
    id: categoryListContent
    property var categoryModel
    property string categoryToDelete: ""
    height: childrenRect.height
    width: parent.width
    spacing: 2
    Repeater {
        model: categoryListContent.categoryModel
        delegate: Item {
            id: wrapper
            property bool showCategory: true
            property color color: {
                if (hhandler.hovered) {
                    return Style.current.menuBackgroundHover
                }
                return Style.current.transparent
            }
            height: showCategory ? categoryHeader.height + channelList.height : categoryHeader.height
            width: categoryListContent.width
            Rectangle {
                id: categoryHeader
                color: wrapper.color
                radius: 8
                height: 40
                width:  categoryListContent.width

                StyledText {
                    text: model.name
                    elide: Text.ElideRight
                    color: Style.current.textColor
                    font.weight: Font.Medium
                    font.pixelSize: 15
                    anchors.left: parent.left
                    anchors.leftMargin: Style.current.halfPadding
                    anchors.verticalCenter: parent.verticalCenter
                }

                StatusIconButton {
                    visible: hhandler.hovered && chatsModel.communities.activeCommunity.admin
                    id: addBtn
                    icon.name: "add-category"
                    width: 20
                    height: 20
                    anchors.right: moreBtn.left
                    anchors.rightMargin: Style.current.halfPadding
                    anchors.verticalCenter: parent.verticalCenter
                    iconColor: Style.current.textColor
                    highlightedIconColor: Style.current.textColor
                    hoveredIconColor: Style.current.textColor
                    highlightedBackgroundColor: Style.current.menuBackgroundHover
                    onClicked: {
                        openPopup(createChannelPopup, {communityId: chatsModel.communities.activeCommunity.id, categoryId: model.categoryId})
                    }
                    StatusToolTip {
                        visible: addBtn.hovered
                        text: qsTr("Add channel inside category")
                    }
                }

                StatusIconButton {
                    visible: hhandler.hovered
                    id: moreBtn
                    icon.name: "more"
                    width: 20
                    height: 20
                    anchors.right: showBtn.left
                    anchors.rightMargin: Style.current.halfPadding
                    anchors.verticalCenter: parent.verticalCenter
                    iconColor: Style.current.textColor
                    highlightedIconColor: Style.current.textColor
                    hoveredIconColor: Style.current.textColor
                    highlightedBackgroundColor: Style.current.menuBackgroundHover
                    onClicked: contextMenu.popup()

                    StatusToolTip {
                        visible: moreBtn.hovered
                        text: qsTr("More")
                    }

                    PopupMenu {
                        id: contextMenu

                        Action {
                            enabled: chatsModel.communities.activeCommunity.admin
                            text: qsTr("Edit category")
                            icon.source: "../../../img/edit.svg"
                            icon.width: 20
                            icon.height: 20
                            onTriggered: {
                                openPopup(createCategoryPopup, {
                                    communityId: chatsModel.communities.activeCommunity.id,
                                    isEdit: true,
                                    categoryId: model.categoryId,
                                    categoryName: model.name
                                })
                            }
                        }

                        Separator {
                            visible: chatsModel.communities.activeCommunity.admin
                        }

                        Action {
                            text: qsTr("Delete category")
                            enabled: chatsModel.communities.activeCommunity.admin
                            icon.source: "../../../img/delete.svg"
                            icon.color: Style.current.red
                            icon.width: 20
                            icon.height: 20
                            onTriggered: {
                                categoryToDelete = model.categoryId
                                openPopup(deleteCategoryConfirmationDialogComponent, {
                                    title: qsTr("Delete %1 category").arg(model.name),
                                    confirmationText: qsTr("Are you sure you want to delete %1 category? Channels inside the category won’t be deleted.").arg(model.name)
                                    
                                })
                            }
                        }
                    }
                }

                StatusIconButton {
                    visible: hhandler.hovered
                    id: showBtn
                    icon.name: showCategory ? "hide-category" : "show-category"
                    width: 20
                    height: 20
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.halfPadding
                    anchors.verticalCenter: parent.verticalCenter
                    iconColor: Style.current.textColor
                    highlightedIconColor: Style.current.textColor
                    hoveredIconColor: Style.current.textColor
                    highlightedBackgroundColor: Style.current.menuBackgroundHover
                    onClicked: {
                        showCategory = !showCategory
                    }
                }

                HoverHandler {
                    id: hhandler
                }
            }

            ChannelList {
                id: channelList
                searchStr: ""
                categoryId: model.categoryId
                visible: showCategory
                height: showCategory ? channelList.childrenRect.height : 0
                anchors.top: categoryHeader.bottom
                width: categoryListContent.width
                channelModel: chatsModel.communities.activeCommunity.chats
            }

            MessageDialog {
                id: deleteError
                title: qsTr("Error deleting the category")
                icon: StandardIcon.Critical
                standardButtons: StandardButton.Ok
            }
            

            Component {
                id: deleteCategoryConfirmationDialogComponent
                ConfirmationDialog {
                    btnType: "warn"
                    height: 216
                    showCancelButton: true
                    onClosed: {
                        destroy()
                    }
                    onCancelButtonClicked: {
                        close();
                    }
                    onConfirmButtonClicked: function(){
                        const error = chatsModel.communities.deleteCommunityCategory(chatsModel.communities.activeCommunity.id, categoryToDelete)
                        if (error) {
                            creatingError.text = error
                            return creatingError.open()
                        }
                        close();
                    }
                }
            }
        }
    }
}
