import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3

import utils 1.0
import "../../../../../shared"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    property string communityId
    property string categoryId
    property string categoryName: ""
    property var channels: []

    property bool isEdit: false

    readonly property int maxCategoryNameLength: 30
    readonly property var categoryNameValidator: Utils.Validate.NoEmpty
                                                 | Utils.Validate.TextLength

    id: popup

    onOpened: {
        if(isEdit){
            popup.contentItem.categoryName.input.text = categoryName
            channels = JSON.parse(chatsModel.communities.activeCommunity.getChatIdsByCategory(categoryId))
        }
        popup.contentItem.categoryName.input.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: destroy()

    function isFormValid() {
        return contentItem.categoryName.valid
    }

    header.title: isEdit ?
            //% "Edit category"
            qsTrId("edit-category") : 
            //% "New category"
            qsTrId("new-category")

    contentItem: Column {
                
        width: popup.width
        property alias categoryName: nameInput

        StatusInput {
            id: nameInput
            charLimit: maxCategoryNameLength
            input.placeholderText: qsTr("Category title")
            validators: [StatusMinLengthValidator {
                minLength: 1
                errorMessage: Utils.getErrorMessage(errors, qsTr("category name"))
            }]
        }

        StatusModalDivider {
            topPadding: 8
            bottomPadding: 8
        }

        ScrollView {
            id: scrollView

            width: popup.width
            height: Math.min(content.height, 300)
            anchors.horizontalCenter: parent.horizontalCenter

            property ScrollBar vScrollBar: ScrollBar.vertical

            contentHeight: content.height
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            clip: true

            function scrollBackUp() {
                vScrollBar.setPosition(0)
            }

            Item {
                id: content
                width: parent.width
                height: channelsLabel.height + communityChannelList.height

                Item {
                    id: channelsLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 32
                    height: 34
                    StatusBaseText {
                        //% "Channels"
                        text: qsTrId("channels")
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        font.pixelSize: 15
                        color: Theme.palette.baseColor1
                    }
                }

                ListView {
                    id: communityChannelList

                    anchors.top: channelsLabel.bottom
                    height: childrenRect.height
                    width: parent.width
                    model: chatsModel.communities.activeCommunity.chats
                    interactive: false
                    clip: true

                    delegate: StatusListItem {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: popup.isEdit ? 
                            model.categoryId === popup.categoryId || model.categoryId === "" : 
                            model.categoryId === ""
                        height: visible ? implicitHeight : 0
                        title: "#" + model.name
                        icon.isLetterIdenticon: true
                        icon.background.color: model.color
                        sensor.onClicked: channelItemCheckbox.checked = !channelItemCheckbox.checked

                        components: [
                            StatusCheckBox {
                                id: channelItemCheckbox
                                checked: popup.isEdit ? popup.channels.indexOf(model.id) > - 1 : false
                                onCheckedChanged: {
                                    var idx = popup.channels.indexOf(model.id)
                                    if(checked){
                                        if(idx === -1){
                                            popup.channels.push(model.id)
                                        }
                                    } else {
                                        if(idx > -1){
                                            popup.channels.splice(idx, 1);
                                        }
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        }

        StatusModalDivider {
            visible: deleteCategoryButton.visible
            topPadding: 8
            bottomPadding: 8
        }

        StatusListItem {
            id: deleteCategoryButton
            anchors.horizontalCenter: parent.horizontalCenter
            visible: isEdit

            //% "Delete category"
            title: qsTrId("delete-category")
            icon.name: "delete"
            type: StatusListItem.Type.Danger
            sensor.onClicked: {
                openPopup(deleteCategoryConfirmationDialogComponent, {
                    //% "Delete %1 category"
                    title: qsTrId("delete--1-category").arg(popup.contentItem.categoryName.input.text),
                    //% "Are you sure you want to delete %1 category? Channels inside the category won’t be deleted."
                    confirmationText: qsTrId("are-you-sure-you-want-to-delete--1-category--channels-inside-the-category-won-t-be-deleted-").arg(popup.contentItem.categoryName.input.text)
                    
                })
            }
        }

        Item {
            height: 8
            width: parent.width
        }

        Component {
            id: deleteCategoryConfirmationDialogComponent
            ConfirmationDialog {
                btnType: "warn"
                showCancelButton: true
                onClosed: {
                    destroy()
                }
                onCancelButtonClicked: {
                    close();
                }
                onConfirmButtonClicked: function(){
                    const error = chatsModel.communities.deleteCommunityCategory(chatsModel.communities.activeCommunity.id, popup.categoryId)
                    if (error) {
                        creatingError.text = error
                        return creatingError.open()
                    }
                    close();
                    popup.close()
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            enabled: isFormValid()
            text: isEdit ?
                //% "Save"
                qsTrId("save") :
                //% "Create"
                qsTrId("create")
            onClicked: {
                if (!isFormValid()) {
                    scrollView.scrollBackUp()
                    return
                }

                let error = ""

                if (isEdit) {
                    error = chatsModel.communities.editCommunityCategory(communityId, categoryId, Utils.filterXSS(popup.contentItem.categoryName.input.text), JSON.stringify(channels))
                } else {
                    error = chatsModel.communities.createCommunityCategory(communityId, Utils.filterXSS(popup.contentItem.categoryName.input.text), JSON.stringify(channels))
                }

                if (error) {
                    categoryError.text = error
                    return categoryError.open()
                }

                popup.close()
            }
        }
    ]

    MessageDialog {
        id: categoryError
        title: isEdit ? 
                //% "Error editing the category"
                qsTrId("error-editing-the-category") :
                //% "Error creating the category"
                qsTrId("error-creating-the-category")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}
