import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string communityId
    readonly property int maxDescChars: 140
    property string nameValidationError: ""
    property bool isValid: nameInput.isValid 

    property var channels: []

    id: popup
    height: 453

    onOpened: {
        nameInput.text = "";
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: destroy()

    function validate() {
        nameInput.validate()
        return isValid
    }

    title: qsTr("New category")

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
                text: qsTr("Chats")
                anchors.top: sep.bottom
                anchors.topMargin: Style.current.smallPadding
            }

            ListView {
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


        }
    }

    footer: StatusButton {
        enabled: popup.isValid
        //% "Create"
        text: qsTrId("create")
        anchors.right: parent.right
        onClicked: {
            if (!validate()) {
                scrollView.scrollBackUp()
                return
            }

            const error = chatsModel.communities.createCommunityCategory(communityId, Utils.filterXSS(nameInput.text), JSON.stringify(channels))

            if (error) {
                creatingError.text = error
                return creatingError.open()
            }

            popup.close()
        }

        MessageDialog {
            id: creatingError
            title: qsTr("Error creating the category")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}
