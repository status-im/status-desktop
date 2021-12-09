import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

RowLayout {
    id: favoritesBar

    property alias bookmarkModel: bookmarkList.model

    property var favoritesMenu
    property var setAsCurrentWebUrl: function(url){}
    property var addFavModal: function(){}

    spacing: 0
    height: 38

    ListView {
        id: bookmarkList
        spacing: Style.current.halfPadding
        orientation : ListView.Horizontal
        height: parent.height
        clip: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        width: parent.width
        boundsBehavior: Flickable.StopAtBounds
        delegate: StatusFlatButton {
            id: favoriteBtn
            height: 32
            icon.source: imageUrl
            icon.width: 24
            icon.height: 24
            text: name

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                z: 51
                onClicked: function (mouse) {
                    const isAddBookmarkButton = url === Constants.newBookmark
                    if (mouse.button === Qt.RightButton && isAddBookmarkButton) {
                        return
                    }

                    if (mouse.button === Qt.RightButton) {
                        favoritesMenu.url = url
                        favoritesMenu.x = favoriteBtn.x + mouse.x
                        favoritesMenu.y = Qt.binding(function () {return mouse.y + favoritesMenu.height})
                        favoritesMenu.open()
                        return
                    }

                    if (isAddBookmarkButton) {
                        addFavModal()
                        return
                    }

                    setAsCurrentWebUrl(url)
                }
            }
        }
    }
}
