import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1

import utils 1.0

RowLayout {
    id: favoritesBar

    property alias bookmarkModel: bookmarkList.model

    property var favoritesMenu
    property var setAsCurrentWebUrl: function(url){}
    property var addFavModal: function(){}

    spacing: 0
    height: 38

    StatusListView {
        id: bookmarkList
        spacing: Style.current.halfPadding
        orientation : ListView.Horizontal
        Layout.fillWidth: true
        Layout.fillHeight: true
        delegate: StatusFlatButton {
            id: favoriteBtn
            height: 32
            icon.source: imageUrl
            icon.width: 24
            icon.height: 24
            // Limit long named tabs. StatusFlatButton is not well-behaved control
            //  implicitWidth doesn't work. Also avoid breaking visualization by escaping HTML
            text: SQUtils.StringUtils.escapeHtml(Utils.elideIfTooLong(name, 40))

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
