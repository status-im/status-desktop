import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.popups 1.0

StatusModal {
    id: root

    property var store
    property string communityId
    property string categoryId
    property string categoryName: ""
    property var channels: []

    property bool isEdit: false

    readonly property int maxCategoryNameLength: 24
    readonly property var categoryNameValidator: Utils.Validate.NoEmpty
                                                 | Utils.Validate.TextLength

    onOpened: {
        if(isEdit){
            root.contentItem.categoryName.input.text = categoryName
            root.channels = []
            root.store.prepareEditCategoryModel(categoryId);
        }
        root.contentItem.categoryName.input.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: destroy()

    function isFormValid() {
        return contentItem.categoryName.valid
    }

    header.title: isEdit ?
            qsTr("Edit category") :
            qsTr("New category")

    contentItem: Column {
        property alias categoryName: nameInput

        width: root.width
        topPadding: 16

        StatusInput {
            id: nameInput

            anchors.left: parent.left
            anchors.leftMargin: 16

            label: qsTr("Category title")
            charLimit: maxCategoryNameLength
            input.placeholderText: qsTr("Name the category")
            validators: [StatusMinLengthValidator {
                minLength: 1
                errorMessage: Utils.getErrorMessage(nameInput.errors, qsTr("category name"))
            }]
        }

        StatusModalDivider {
            topPadding: 8
            bottomPadding: 8
        }

        ScrollView {
            id: scrollView

            width: root.width
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
                        text: qsTr("Channels")
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
                    model: isEdit ? root.store.chatCommunitySectionModule.editCategoryChannelsModel : root.store.chatCommunitySectionModule.model
                    interactive: false
                    clip: true

                    delegate: StatusListItem {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: model.type != Constants.chatType.unknown
                        height: visible ? implicitHeight : 0
                        title: "#" + model.name
                        icon.emoji: model.emoji
                        icon.color: model.color
                        image.isIdenticon: false
                        image.source: model.icon
                        ringSettings.ringSpecModel: model.colorHash
                        icon.isLetterIdenticon: true
                        icon.background.color: model.color
                        sensor.onClicked: channelItemCheckbox.checked = !channelItemCheckbox.checked

                        components: [
                            StatusCheckBox {
                                id: channelItemCheckbox
                                checked: root.isEdit ? model.categoryId == root.categoryId : false
                                onCheckedChanged: {
                                    if(checked){
                                        var idx = root.channels.indexOf(model.itemId)
                                        if(idx === -1){
                                            root.channels.push(model.itemId)
                                        }
                                    } else {
                                        root.channels = root.channels.filter(el => el !== model.itemId);
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

            title: qsTr("Delete category")
            icon.name: "delete"
            type: StatusListItem.Type.Danger
            sensor.onClicked: {
                Global.openPopup(deleteCategoryConfirmationDialogComponent, {
                    title: qsTr("Delete %1 category").arg(root.contentItem.categoryName.input.text),
                    confirmationText: qsTr("Are you sure you want to delete %1 category? Channels inside the category won’t be deleted.").arg(root.contentItem.categoryName.input.text)

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
                    const error = root.store.deleteCommunityCategory(root.categoryId);
                    if (error) {
                        categoryError.text = error
                        return categoryError.open()
                    }
                    close();
                    root.close()
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            enabled: isFormValid()
            text: isEdit ?
                qsTr("Save") :
                qsTr("Create")
            onClicked: {
                if (!isFormValid()) {
                    scrollView.scrollBackUp()
                    return
                }

                let error = ""
                if (isEdit) {
                    error = root.store.editCommunityCategory(root.categoryId, Utils.filterXSS(root.contentItem.categoryName.input.text), JSON.stringify(channels));
                } else {
                    error = root.store.createCommunityCategory(Utils.filterXSS(root.contentItem.categoryName.input.text), JSON.stringify(channels));
                }

                if (error) {
                    categoryError.text = error
                    return categoryError.open()
                }

                root.close()
            }
        }
    ]

    MessageDialog {
        id: categoryError
        title: isEdit ?
                qsTr("Error editing the category") :
                qsTr("Error creating the category")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}
