import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string communityId
    property string categoryId
    property string categoryName: ""
    property var channels: []

    property bool isEdit: false
    readonly property int maxDescChars: 140
    property string nameValidationError: ""
    property bool isValid: nameInput.isValid 


    id: popup
    height: 453

    onOpened: {
        nameInput.text = isEdit ? categoryName : "";
        if(isEdit){
            channels = JSON.parse(chatsModel.communities.activeCommunity.getChatIdsByCategory(categoryId))
        }
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
        if(isEdit){
            validate();
        }
    }
    onClosed: destroy()

    function validate() {
        nameInput.validate()
        return isValid
    }

    title: isEdit ?
            qsTr("Edit category") : 
            qsTr("New category")

    ScrollView {
        property ScrollBar vScrollBar: ScrollBar.vertical

        id: scrollView
        anchors.fill: parent
        rightPadding: Style.current.padding
        anchors.rightMargin: - Style.current.halfPadding
        contentHeight: content.height
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        function scrollBackUp() {
            vScrollBar.setPosition(0)
        }

        Item {
            id: content
            height: childrenRect.height
            width: parent.width

            Input {
                id: nameInput
                placeholderText: qsTr("Category title")
                validationError: popup.nameValidationError

                property bool isValid: false

                onTextEdited: {
                    validate()
                }

                function validate() {
                    validationError = ""
                    if (nameInput.text === "") {
                        //% "You need to enter a name"
                        validationError = qsTrId("you-need-to-enter-a-name")
                    } else if (nameInput.text.length > 100) {
                        //% "Your name needs to be 100 characters or shorter"
                        validationError = qsTrId("your-name-needs-to-be-100-characters-or-shorter")
                    }
                    isValid = validationError === ""
                    return validationError
                }
            }

            Separator {
                id: sep
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: nameInput.bottom
                anchors.topMargin: Style.current.padding
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding
            }

            StatusSectionHeadline {
                id: chatsTitle
                text: qsTr("Channels")
                anchors.top: sep.bottom
                anchors.topMargin: Style.current.smallPadding
            }

            ListView {
                id: communityChannelList
                height: childrenRect.height
                model: chatsModel.communities.activeCommunity.chats
                anchors.top: chatsTitle.bottom
                anchors.topMargin: Style.current.smallPadding
                anchors.left: parent.left
                anchors.right: parent.right
                delegate: CommunityChannel {
                    name: model.name
                    channelId: model.id
                    categoryId: model.categoryId
                    checked: popup.isEdit ? channels.indexOf(model.id) > - 1 : false
                    visible: popup.isEdit ? model.categoryId === popup.categoryId || model.categoryId === "" : model.categoryId === ""
                    onItemChecked: function(channelId, itemChecked){
                        var idx = channels.indexOf(channelId)
                        if(itemChecked){
                            if(idx === -1){
                                channels.push(channelId)
                            }
                        } else {
                            if(idx > -1){
                                channels.splice(idx, 1);
                            }
                        }
                    }
                }
            }

            Separator {
                id: sep2
                visible: isEdit
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: communityChannelList.bottom
                anchors.topMargin: Style.current.padding
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding
            }

            Item {
                id: deleteCategory
                visible: isEdit
                anchors.top: sep2.bottom
                anchors.topMargin: Style.current.padding
                width: deleteBtn.width + deleteTxt.width + Style.current.padding
                height: deleteBtn.height


                StatusRoundButton {
                    id: deleteBtn
                    icon.name: "delete"
                    size: "medium"
                    type: "warn"
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    id: deleteTxt
                    text: qsTr("Delete category")
                    color: Style.current.red
                    anchors.left: deleteBtn.right
                    anchors.leftMargin: Style.current.padding
                    anchors.verticalCenter: deleteBtn.verticalCenter
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        openPopup(deleteCategoryConfirmationDialogComponent, {
                            title: qsTr("Delete %1 category").arg(categoryName),
                            confirmationText: qsTr("Are you sure you want to delete %1 category? Channels inside the category won’t be deleted.").arg(categoryName)
                            
                        })
                    }
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


        }
    }

    footer: StatusButton {
        enabled: popup.isValid
        text: isEdit ?
            qsTr("Save") :
            qsTr("Create")
        anchors.right: parent.right
        onClicked: {
            if (!validate()) {
                scrollView.scrollBackUp()
                return
            }

            let error = ""

            if(isEdit){
                error = chatsModel.communities.editCommunityCategory(communityId, categoryId, Utils.filterXSS(nameInput.text), JSON.stringify(channels))
            } else {
                error = chatsModel.communities.createCommunityCategory(communityId, Utils.filterXSS(nameInput.text), JSON.stringify(channels))
            }

            if (error) {
                categoryError.text = error
                return categoryError.open()
            }

            popup.close()
        }

        MessageDialog {
            id: categoryError
            title: isEdit ? 
                    qsTr("Error editing the category") :
                    qsTr("Error creating the category")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}
