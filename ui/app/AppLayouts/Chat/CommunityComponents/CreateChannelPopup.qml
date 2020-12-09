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

    id: popup
    height: 600

    onOpened: {
        nameInput.text = "";
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    function validate() {
        nameValidationError = ""

        if (nameInput.text === "") {
            nameValidationError = qsTr("You need to enter a name")
        } else if (!(/^[a-z0-9\-\ ]+$/i.test(nameInput.text))) {
            nameValidationError = qsTr("Please restrict your name to letters, numbers, dashes and spaces")
        } else if (nameInput.text.length > 100) {
            nameValidationError = qsTr("Your name needs to be 100 characters or shorter")
        }

        return !nameValidationError && !descriptionTextArea.validationError
    }

    title: qsTr("New channel")

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
                label: qsTr("Channel name")
                placeholderText: qsTr("A cool name")
                validationError: popup.nameValidationError
            }

            StyledTextArea {
                id: descriptionTextArea
                label: qsTr("Channel description")
                placeholderText: qsTr("What your channel is about")
                validationError: descriptionTextArea.text.length > maxDescChars ? qsTr("The description cannot exceed %1 characters").arg(maxDescChars) : ""
                anchors.top: nameInput.bottom
                anchors.topMargin: Style.current.bigPadding
                customHeight: 88
            }

            StyledText {
                id: charLimit
                text: `${descriptionTextArea.text.length}/${maxDescChars}`
                anchors.top: descriptionTextArea.bottom
                anchors.topMargin: !descriptionTextArea.validationError ? 5 : - Style.current.smallPadding
                anchors.right: descriptionTextArea.right
                font.pixelSize: 12
                color: !descriptionTextArea.validationError ? Style.current.textColor : Style.current.danger
            }

            Separator {
                id: separator1
                anchors.top: charLimit.bottom
                anchors.topMargin: Style.current.bigPadding
            }

            Item {
                id: privateSwitcher
                height: privateSwitch.height
                width: parent.width
                anchors.top: separator1.bottom
                anchors.topMargin: Style.current.smallPadding * 2

                StyledText {
                    text: qsTr("Private channel")
                    anchors.verticalCenter: parent.verticalCenter
                }

                StatusSwitch {
                    id: privateSwitch
                    anchors.right: parent.right
                }
            }

            StyledText {
                id: privateExplanation
                anchors.top: privateSwitcher.bottom
                wrapMode: Text.WordWrap
                anchors.topMargin: Style.current.smallPadding * 2
                width: parent.width
                text: qsTr("By making a channel private, only members with selected permission will be able to access it")
            }
        }
    }

    footer: StatusButton {
        text: qsTr("Create")
        anchors.right: parent.right
        onClicked: {
            if (!validate()) {
                scrollView.scrollBackUp()
                return
            }
            const error = chatsModel.createCommunityChannel(communityId,
                                                            Utils.filterXSS(nameInput.text),
                                                            Utils.filterXSS(descriptionTextArea.text))

            if (error) {
                creatingError.text = error
                return creatingError.open()
            }

            // TODO Open the community once we have designs for it
            popup.close()
        }

        MessageDialog {
            id: creatingError
            title: qsTr("Error creating the community")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}

