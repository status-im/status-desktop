import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as SQUtils
import StatusQ.Controls

import utils

RowLayout {
    id: favoritesBar

    property alias bookmarkModel: bookmarkList.model

    property var favoritesMenu

    signal addFavModalRequested()
    signal setAsCurrentWebUrl(url url)
    signal openInNewTab(url url)

    spacing: 0
    height: 38

    StatusListView {
        id: bookmarkList
        spacing: Theme.halfPadding
        orientation : ListView.Horizontal
        Layout.fillWidth: true
        Layout.fillHeight: true
        delegate: StatusFlatButton {
            id: favoriteBtn
            size: StatusBaseButton.Size.Small
            icon.source: model.imageUrl
            icon.width: 24
            icon.height: 24
            // Limit long named tabs. StatusFlatButton is not well-behaved control
            //  implicitWidth doesn't work. Also avoid breaking visualization by escaping HTML
            text: SQUtils.StringUtils.escapeHtml(Utils.elideIfTooLong(name, 40))

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: containsMouse ? Qt.PointingHandCursor : undefined
                z: 51
                onClicked: function (mouse) {
                    const isAddBookmarkButton = model.url === Constants.newBookmark
                    if (mouse.button === Qt.RightButton && isAddBookmarkButton) {
                        return
                    }

                    if (mouse.button === Qt.RightButton) {
                        favoritesMenu.url = model.url
                        favoritesMenu.x = favoriteBtn.x + mouse.x
                        favoritesMenu.y = Qt.binding(function () {return mouse.y + favoritesMenu.height})
                        favoritesMenu.open()
                        return
                    }

                    if (isAddBookmarkButton) {
                        favoritesBar.addFavModalRequested()
                        return
                    }

                    if (mouse.button === Qt.LeftButton)
                        favoritesBar.setAsCurrentWebUrl(model.url)
                    else if (mouse.button === Qt.MiddleButton)
                        favoritesBar.openInNewTab(model.url)
                }
            }
        }
    }
}
