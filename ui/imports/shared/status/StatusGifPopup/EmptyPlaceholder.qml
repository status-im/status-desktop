import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

Rectangle {
    id: root

    required property int currentCategory
    property bool loading: false

    signal doRetry()

    color: Theme.palette.background

    StatusBaseText {
        id: emptyText
        anchors.centerIn: parent
        text: {
            if (root.loading) {
                return qsTr("Loading gifs...")
            }
            if (root.currentCategory === GifPopupDefinitions.Category.Favorite) {
                return qsTr("Favorite GIFs will appear here")
            }
            if (root.currentCategory === GifPopupDefinitions.Category.Recent) {
                return qsTr("Recent GIFs will appear here")
            }

            return qsTr("Error while contacting Tenor API, please retry.")
        }
        color: Theme.palette.secondaryText
    }

    StatusButton {
        text: qsTr("Retry")

        visible: !root.loading &&
            (root.currentCategory === GifPopupDefinitions.Category.Trending ||
            root.currentCategory === GifPopupDefinitions.Category.Search)

        anchors.top: emptyText.bottom
        anchors.topMargin: Theme.padding
        anchors.horizontalCenter: parent.horizontalCenter

        onClicked: root.doRetry()
    }
}
