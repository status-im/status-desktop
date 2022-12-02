import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import Qt.labs.qmlmodels 1.0

import "delegates"

ListView {
    id: root

    property int newMessagesCount
    property int recentMessagesCount

    readonly property bool isMostRecentMessageInViewport: visibleArea.yPosition >= 0.999 - visibleArea.heightRatio
    readonly property alias hasMostRecentMessageBeenSeen: d.hasMostRecentMessageBeenSeen

    signal markAsUnreadClicked(int index)

    spacing: 2
    verticalLayoutDirection: ListView.BottomToTop

    onIsMostRecentMessageInViewportChanged: if (isMostRecentMessageInViewport) d.hasMostRecentMessageBeenSeen = true
    onVisibleChanged: if (visible) {
                          if (newMessagesCount) {
                              root.positionViewAtIndex(newMessagesCount, ListView.End)
                          }
                          d.hasMostRecentMessageBeenSeen = isMostRecentMessageInViewport
                      }

    QtObject {
        id: d
        property bool hasMostRecentMessageBeenSeen: false
    }


    delegate: Loader {
        width: ListView.view.width

        sourceComponent: {
            if (model.contentType === Model.ContentType.Message) return messageDelegate
            if (model.contentType === Model.ContentType.NewMessagesMarker) return newMessageMarkerDelegate
            return null
        }

        onLoaded: {
            item.outgoing = Qt.binding(() => model.outgoing)
            item.text = Qt.binding(() => model.text)
            item.index = Qt.binding(() => index)
        }
    }

    Component {
        id: messageDelegate
        MessageDelegate {
            onMarkAsUnreadClicked: root.markAsUnreadClicked(index)
        }
    }

    Component {
        id: newMessageMarkerDelegate
         NewMessageMarkerDelegate {
             count: root.newMessagesCount
         }
    }

    ScrollBar.vertical: ScrollBar {
    }
}
