import QtQuick 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import shared.popups 1.0

import utils 1.0

import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property string ogUrl: ""
    property string ogName: ""
    property bool modifiyModal: false
    property bool toolbarMode: false

    id: popup
    width: Style.dp(toolbarMode ? 345 : 480)
    height: Style.dp(toolbarMode ? 400 : 480)

    modal: !toolbarMode

    background: Rectangle {
        id: bgPopup
        color: Style.current.background
        radius: Style.current.radius
        layer.enabled: true
        layer.effect: DropShadow{
            width: bgPopup.width
            height: bgPopup.height
            x: bgPopup.x
            y: bgPopup.y + Style.dp(10)
            visible: bgPopup.visible
            source: bgPopup
            horizontalOffset: 0
            verticalOffset: Style.dp(5)
            radius: Style.dp(10)
            samples: 15
            color: Style.current.dropShadow
        }
    }

    onOpened: {
        urlInput.input.text = ogUrl
        nameInput.input.text = ogName
        urlInput.input.forceActiveFocus(Qt.MouseFocusReason)
    }

    onClosed: {
        reset()
    }

    function reset() {
        modifiyModal = false
        toolbarMode = false
        urlInput.reset()
        nameInput.reset()
        ogUrl = ""
        ogName = ""
        x = Math.round(((parent ? parent.width : 0) - width) / 2)
        y = Math.round(((parent ? parent.height : 0) - height) / 2)
    }

    title: modifiyModal ?
               toolbarMode ?
                   //% "Favorite added"
                   qsTrId("favorite-added") :
                   //% "Edit"
                   qsTrId("edit")
               //% "Add favorite"
               : qsTrId("add-favorite")

    Column {
        width: parent.width
        spacing: Style.current.padding

        StatusInput {
            id: urlInput
            anchors.left: parent.left
            anchors.right: parent.right
            leftPadding: 0
            rightPadding: 0
            label: qsTr("URL")
            input.text: ogUrl
            input.placeholderText: qsTr("Paste URL")
            input.rightComponent: StatusButton {
                anchors.verticalCenter: parent.verticalCenter
                border.width: Style.dp(1)
                border.color: Theme.palette.primaryColor1
                size: StatusBaseButton.Size.Tiny
                text: qsTr("Paste")
                onClicked: {
                    text = qsTr("Pasted")
                    urlInput.input.edit.paste()
                }
            }
            validators: [
                StatusUrlValidator {
                    errorMessage: qsTr("Please enter a valid URL")
                }
            ]
        }

        StatusInput {
            id: nameInput
            anchors.left: parent.left
            anchors.right: parent.right
            leftPadding: 0
            rightPadding: 0
            label: qsTr("Name")
            input.text: ogName
            input.placeholderText: qsTr("Name of the website")
            validators: [
                StatusMinLengthValidator {
                    errorMessage: qsTr("Please enter a name")
                    minLength: 1
                }
            ]
        }
    }

    footer: Item {
        width: parent.width
        height: removeBtn.height

        StatusButton {
            id: removeBtn
            anchors.right: addBtn.left
            anchors.rightMargin: Style.current.padding
            visible: popup.modifiyModal
            //% "Remove"
            text: qsTrId("remove")
            anchors.bottom: parent.bottom
            type: StatusBaseButton.Type.Danger
            onClicked: {
                BookmarksStore.deleteBookmark(popup.ogUrl)
                popup.close()
            }
        }

        StatusButton {
            id: addBtn
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            text: popup.modifiyModal ?
                      //% "Done"
                      qsTrId("done") :
                      //% "Add"
                      qsTrId("add")
            anchors.bottom: parent.bottom
            enabled: nameInput.valid && !!nameInput.text && urlInput.valid && !!urlInput.text
            onClicked: {
                if (!popup.modifiyModal) {
                    // remove "add favorite" button at the end, add new bookmark, add "add favorite" button back
                    BookmarksStore.deleteBookmark(Constants.newBookmark)
                    BookmarksStore.addBookmark(urlInput.input.text, nameInput.input.text)
                    BookmarksStore.addBookmark(Constants.newBookmark, qsTr("Add Favorite"))
                } else if (popup.ogName !== nameInput.input.text || popup.ogUrl !== urlInput.input.text) {
                    BookmarksStore.updateBookmark(popup.ogUrl, urlInput.input.text, nameInput.input.text)
                }

                popup.close()
            }
        }
    }
}
