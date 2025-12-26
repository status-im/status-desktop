import QtQuick
import Qt5Compat.GraphicalEffects

import StatusQ
import StatusQ.Core.Utils
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Controls.Validators

import shared.popups

import utils

import AppLayouts.stores.Browser as BrowserStores

// TODO: replace with StatusDialog
ModalPopup {
    id: root

    required property bool incognitoMode
    required property BrowserStores.BookmarksStore bookmarksStore

    property string ogUrl: ""
    property string ogName: ""
    property bool modifiyModal: false
    property bool toolbarMode: false

    width: toolbarMode ? 345 : 480
    height: toolbarMode ? 400 : 480

    modal: !toolbarMode

    background: Rectangle {
        id: bgPopup
        color: root.incognitoMode?
                   Theme.palette.privacyColors.primary:
                   Theme.palette.background
        radius: Theme.radius
        layer.enabled: true
        layer.effect: DropShadow {
            width: bgPopup.width
            height: bgPopup.height
            x: bgPopup.x
            y: bgPopup.y + 10
            visible: bgPopup.visible
            source: bgPopup
            horizontalOffset: 0
            verticalOffset: 5
            radius: 10
            samples: 15
            color: Theme.palette.dropShadow
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
                   qsTr("Favourite added") :
                   qsTr("Edit favourite")
               : qsTr("Add favourite")

    Column {
        width: parent.width
        spacing: Theme.padding

        StatusInput {
            id: urlInput
            anchors.left: parent.left
            anchors.right: parent.right
            label: qsTr("URL")
            input.text: ogUrl
            placeholderText: qsTr("Paste URL")
            input.rightComponent: StatusButton {
                anchors.verticalCenter: parent.verticalCenter
                borderColor: Theme.palette.primaryColor1
                size: StatusBaseButton.Size.Tiny
                text: qsTr("Paste")
                visible: ClipboardUtils.hasText && Utils.isURL(ClipboardUtils.text)
                onClicked: {
                    text = qsTr("Pasted")
                    urlInput.text = ClipboardUtils.text
                }
            }
            validators: [
                StatusUrlValidator {}
            ]
            validationMode: StatusInput.ValidationMode.Always
        }

        StatusInput {
            id: nameInput
            anchors.left: parent.left
            anchors.right: parent.right
            leftPadding: 0
            rightPadding: 0
            label: qsTr("Name")
            input.text: ogName
            placeholderText: qsTr("Name of the website")
            validators: [
                StatusMinLengthValidator {
                    errorMessage: qsTr("Please enter a name")
                    minLength: 1
                }
            ]
            validationMode: StatusInput.ValidationMode.Always
        }
    }

    footer: Item {
        width: parent.width
        height: removeBtn.height

        StatusButton {
            id: removeBtn
            anchors.right: addBtn.left
            anchors.rightMargin: Theme.padding
            visible: root.modifiyModal
            text: qsTr("Remove")
            anchors.bottom: parent.bottom
            type: StatusBaseButton.Type.Danger
            onClicked: {
                root.bookmarksStore.deleteBookmark(root.ogUrl)
                root.close()
            }
        }

        StatusButton {
            id: addBtn
            anchors.right: parent.right
            anchors.rightMargin: Theme.smallPadding
            text: root.modifiyModal ?
                      qsTr("Done") :
                      qsTr("Add")
            anchors.bottom: parent.bottom
            enabled: nameInput.valid && urlInput.valid
            onClicked: {
                if (!root.modifiyModal) {
                    // remove "add favorite" button at the end, add new bookmark, add "add favorite" button back
                    root.bookmarksStore.deleteBookmark(Constants.newBookmark)
                    root.bookmarksStore.addBookmark(urlInput.input.text, nameInput.input.text)
                    root.bookmarksStore.addBookmark(Constants.newBookmark, qsTr("Add Favourite"))
                } else if (root.ogName !== nameInput.input.text || root.ogUrl !== urlInput.input.text) {
                    root.bookmarksStore.updateBookmark(root.ogUrl, urlInput.input.text, nameInput.input.text)
                }

                root.close()
            }
        }
    }
}
