import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.popups 1.0

import SortFilterProxyModel 0.2

StatusModal {
    id: root

    property var store
    property string communityId
    property string categoryId
    property string categoryName: ""
    property var channels: []

    property bool isEdit: false

    readonly property int maxCategoryNameLength: 24

    onOpened: {
        if(isEdit){
            root.contentItem.categoryName.input.text = categoryName
            root.channels = []
            root.store.prepareEditCategoryModel(categoryId);
        }
        root.contentItem.categoryName.input.edit.forceActiveFocus()
    }
    onClosed: destroy()

    function isFormValid() {
        return contentItem.categoryName.valid
    }

    headerSettings.title: isEdit ? qsTr("Edit category") : qsTr("New category")

    contentItem: Column {
        property alias categoryName: nameInput

        width: root.width
        topPadding: 16

        StatusInput {
            id: nameInput

            anchors.left: parent.left
            anchors.leftMargin: 16

            input.edit.objectName: "createOrEditCommunityCategoryNameInput"
            input.clearable: true
            label: qsTr("Category title")
            charLimit: maxCategoryNameLength
            placeholderText: qsTr("Name the category")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(nameInput.errors, qsTr("category name"))
                },
                StatusRegularExpressionValidator {
                    regularExpression: Constants.regularExpressions.alphanumericalExpanded
                    errorMessage: Constants.errorMessages.alphanumericalExpandedRegExp
                }
            ]
        }

        StatusModalDivider {
            topPadding: 8
            bottomPadding: 8
        }

        Item {
            width: root.width
            height: Math.min(communityChannelList.contentHeight, 300)

            Item {
                anchors.fill: parent
                anchors.margins: -8
                clip: true

                StatusListView {
                    id: communityChannelList
                    objectName: "createOrEditCommunityCategoryChannelList"

                    anchors.fill: parent
                    anchors.margins: -parent.anchors.margins
                    displayMarginBeginning: anchors.margins
                    displayMarginEnd: anchors.margins
                    clip: false

                    model: SortFilterProxyModel {
                        sourceModel: root.isEdit ? root.store.chatCommunitySectionModule.editCategoryChannelsModel
                                                 : root.store.chatCommunitySectionModule.model
                        // filter out channels with categories
                        filters: ValueFilter {
                            enabled: !root.isEdit
                            roleName: "categoryId"
                            value: ""
                        }
                    }

                    header: Item {
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

                    delegate: Loader {
                        active: model.type !== Constants.chatType.category
                        
                        sourceComponent: StatusListItem {
                            readonly property bool checked: channelItemCheckbox.checked
                            objectName: "category_item_name_" + model.name
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: 16
                            height: visible ? implicitHeight : 0
                            title: "#" + model.name
                            asset.width: 40
                            asset.height: 40
                            asset.emoji: model.emoji
                            asset.color: model.color
                            asset.imgIsIdenticon: false
                            asset.name: model.icon
                            asset.isImage: !!model.icon
                            ringSettings.ringSpecModel: model.colorHash
                            asset.isLetterIdenticon: true
                            asset.bgColor: model.color
                            onClicked: channelItemCheckbox.checked = !channelItemCheckbox.checked

                            components: [
                                StatusCheckBox {
                                    id: channelItemCheckbox
                                    checked: root.isEdit ? model.categoryId === root.categoryId : false
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
            visible: isEdit
            type: StatusBaseButton.Type.Danger
            text: qsTr("Delete Category")
            onClicked: {
                Global.openPopup(deleteCategoryConfirmationDialogComponent, {
                    "headerSettings.title": qsTr("Delete '%1' category").arg(nameInput.text),
                    confirmationText: qsTr("Are you sure you want to delete '%1' category? Channels inside the category won’t be deleted.").arg(nameInput.text)
                })
            }
        },
        StatusButton {
            objectName: "createOrEditCommunityCategoryBtn"
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
                    error = root.store.editCommunityCategory(root.categoryId, StatusQUtils.Utils.filterXSS(root.contentItem.categoryName.input.text), JSON.stringify(channels));
                } else {
                    error = root.store.createCommunityCategory(StatusQUtils.Utils.filterXSS(root.contentItem.categoryName.input.text), JSON.stringify(channels));
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
