import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0

Rectangle {
    id: root

    /*required*/ property int currentCategory: GifPopupDefinitions.Category.Trending

    signal doRetry()

    height: parent.height
    width: parent.width
    color: Style.current.background

    StatusBaseText {
        id: emptyText
        anchors.centerIn: parent
        text: {
            if(root.currentCategory === GifPopupDefinitions.Category.Favorite) {
                return qsTr("Favorite GIFs will appear here")
            } else if(root.currentCategory === GifPopupDefinitions.Category.Recent) {
                return qsTr("Recent GIFs will appear here")
            }

            return qsTr("Error while contacting Tenor API, please retry.")
        }
        font.pixelSize: 15
        color: Style.current.secondaryText
    }

    StatusButton {
        text: qsTr("Retry")

        visible: root.currentCategory === GifPopupDefinitions.Category.Trending || root.currentCategory === GifPopupDefinitions.Category.Search

        anchors.top: emptyText.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter

        onClicked: root.doRetry()
    }
}
