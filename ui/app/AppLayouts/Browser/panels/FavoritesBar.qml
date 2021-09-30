import QtQuick 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../shared/status"

import utils 1.0

RowLayout {
    id: favoritesBar

    property alias bookmarkModel: bookmarkList.model

    spacing: 0
    height: bookmarkModel.rowCount() > 0 ? 38: 0

    ListView {
        id: bookmarkList
        spacing: Style.current.halfPadding
        orientation : ListView.Horizontal
        height: parent.height
        clip: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        width: parent.width
        boundsBehavior: Flickable.StopAtBounds
        delegate: StatusButton {
            id: favoriteBtn
            height: 32
            icon.source: imageUrl
            disableColorOverlay: true
            icon.width: 24
            icon.height: 24
            text: name
            implicitHeight: 32
            type: "secondary"

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                z: 51
                onClicked: function (mouse) {
                    if (mouse.button === Qt.RightButton) {
                        favoriteMenu.url = url
                        favoriteMenu.x = favoriteBtn.x + mouse.x
                        favoriteMenu.y = Qt.binding(function () {return mouse.y + favoriteMenu.height})
                        favoriteMenu.open()
                        return
                    }
                    if (!url.toString()) {
                        addFavoriteModal.open()
                    } else {
                        currentWebView.url = determineRealURL(url)
                    }
                }
            }
        }
    }
}
