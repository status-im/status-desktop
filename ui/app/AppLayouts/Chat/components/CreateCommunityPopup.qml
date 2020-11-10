import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    readonly property int maxDescChars: 140

    id: popup
    height: 600

    onOpened: {
        nameInput.text = "";
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    title: qsTr("New community")

    ScrollView {
        anchors.fill: parent
        rightPadding: Style.current.padding
        anchors.rightMargin: - Style.current.halfPadding
        contentHeight: content.height
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        clip: true

        Item {
            id: content
            height: childrenRect.height
            width: parent.width

            Input {
                id: nameInput
                label: qsTr("Name your community")
                placeholderText: qsTr("A catchy name")
            }

            StyledTextArea {
                id: descriptionTextArea
                label: qsTr("Give it a short description")
                placeholderText: qsTr("What your community is about")
                validationError: descriptionTextArea.text.length > maxDescChars ? qsTr("The description cannot exceed 140 characters") : ""
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

            StyledText {
                id: thumbnailText
                text: qsTr("Thumbnail image")
                anchors.top: descriptionTextArea.bottom
                anchors.topMargin: Style.current.smallPadding
                font.pixelSize: 15
                color: Style.current.secondaryText
            }

            Rectangle {
                id: addImageButton
                color: Style.current.inputBackground
                width: 128
                height: width
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: thumbnailText.bottom
                anchors.topMargin: Style.current.padding

                Item {
                    id: addImageCenter
                    width: uploadText.width
                    height: childrenRect.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    SVGImage {
                        id: imageImg
                        source: "../../../img/images_icon.svg"
                        width: 20
                        height: 18
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        id: uploadText
                        text: qsTr("Upload")
                        anchors.top: imageImg.bottom
                        anchors.topMargin: 5
                        font.pixelSize: 15
                        color: Style.current.secondaryText
                    }
                }

                Rectangle {
                    color: Style.current.primary
                    width: 40
                    height: width
                    radius: width / 2
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.halfPadding

                    SVGImage {
                        source: "../../../img/plusSign.svg"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: 13
                        height: 13
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: console.log('upload')
                }
            }

            Input {
                id: colorPicker
                label: qsTr("Community colour")
                placeholderText: qsTr("Pick a colour")
                anchors.top: addImageButton.bottom
                anchors.topMargin: Style.current.smallPadding
            }

            Separator {
                id: separator1
                anchors.top: colorPicker.bottom
                anchors.topMargin: Style.current.bigPadding
            }

            Item {
                id: privateSwitcher
                height: privateSwitch.height
                width: parent.width
                anchors.top: separator1.bottom
                anchors.topMargin: Style.current.smallPadding * 2

                StyledText {
                    text: qsTr("Private community")
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
                text: privateSwitch.checked ?
                          qsTr("Only members with an invite link will be able to join your community. Private communities are not listed inside Status") :
                          qsTr("Your community will be public for anyone to join. Public communities are listed inside Status for easy discovery")
            }
        }
    }
    
    footer: StatusButton {
        text: qsTr("Create")
        anchors.right: parent.right
    }
}

