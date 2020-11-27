import QtQuick 2.13
import QtQuick.Controls 2.3
import QtWebEngine 1.9
import "../../../shared"
import "../../../shared/status"
import "../../../imports"
import "../Chat/ChatColumn/ChatComponents"
import "../Profile/LeftTab/constants.js" as ProfileConstants

PopupMenu {
    property var openInNewTab: function () {}
    property string url
    property var currentFavorite: getCurrentFavorite(url)

    id: root
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Action {
        text: qsTr("Open in new Tab")
        icon.source: "../../img/generate_account.svg"
        icon.width: 16
        icon.height: 16
        onTriggered: {
            openInNewTab(root.url)
        }
    }

    Separator {}

    Action {
        text: qsTr("Edit")
        icon.source: "../../img/edit.svg"
        icon.width: 16
        icon.height: 16
        onTriggered: {
            addFavoriteModal.modifiyModal = true
            addFavoriteModal.ogUrl = root.currentFavorite ? root.currentFavorite.url : currentWebView.url
            addFavoriteModal.ogName = root.currentFavorite ? root.currentFavorite.name : currentWebView.title
            addFavoriteModal.open()
        }
    }

    Action {
        text: qsTr("Remove")
        icon.source: "../../img/remove.svg"
        icon.color: Style.current.danger
        icon.width: 16
        icon.height: 16
        onTriggered: {
            browserModel.removeBookmark(root.url)
        }
    }
}
