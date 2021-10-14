import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.controls 1.0

import StatusQ.Controls 0.1

import shared 1.0
import shared.popups 1.0
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property string urlError: ""
    property string nameError: ""
    property string ogUrl
    property string ogName
    property bool modifiyModal: false
    property bool toolbarMode: false

    id: popup
    width: toolbarMode ? 345 : 480
    height: toolbarMode ? 345 : 480

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
            y: bgPopup.y + 10
            visible: bgPopup.visible
            source: bgPopup
            horizontalOffset: 0
            verticalOffset: 5
            radius: 10
            samples: 15
            color: Style.current.dropShadow
        }
    }

    onOpened: {
        urlInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    onClosed: {
        reset()
    }

    function validate() {
        urlError = ""
        if (!urlInput.text) {
            //% "Please enter a URL"
            urlError = qsTrId("please-enter-a-url")
        } else if (!Utils.isURL(urlInput.text)) {
            //% "This fields needs to be a valid URL"
            urlError = qsTrId("this-fields-needs-to-be-a-valid-url")
        }

        //% "Please enter a Name"
        nameError = !nameInput.text ? qsTrId("please-enter-a-name") : ""

        return !urlError && !nameError
    }

    function reset() {
        modifiyModal = false
        toolbarMode = false
        urlError = ""
        nameError = ""
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

        Input {
            id: urlInput
            //% "URL"
            label: qsTrId("url")
            //% "Paste URL"
            placeholderText: qsTrId("paste-url")
            pasteFromClipboard: true
            validationError: popup.urlError
            text: popup.ogUrl
        }

        Input {
            id: nameInput
            //% "Name"
            label: qsTrId("name")
            //% "Name the website"
            placeholderText: qsTrId("name-the-website")
            validationError: popup.nameError
            text: popup.ogName
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
            onClicked: {
                if (!validate()) {
                    return
                }

                if (!popup.modifiyModal) {
                    // remove "add favorite" button at the end, add new bookmark, add "add favorite" button back
                    BookmarksStore.deleteBookmark("")
                    BookmarksStore.addBookmark(urlInput.text, nameInput.text)
                    BookmarksStore.addBookmark("", qsTr("Add Favorite"))
                } else if (popup.ogName !== nameInput.text || popup.ogUrl !== urlInput.text) {
                    BookmarksStore.updateBookmark(popup.ogUrl, urlInput.text, nameInput.text)
                }

                popup.close()
            }
        }
    }
}
