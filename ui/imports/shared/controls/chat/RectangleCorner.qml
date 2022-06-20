import QtQuick 2.3

import utils 1.0

// This rectangle's only job is to mask the corner to make it less rounded... yep
Rectangle {
    color: parent.color
    width: Style.dp(18)
    height: Style.dp(18)
    property bool isCurrentUser: false
    anchors.bottom: parent.bottom
    anchors.left: !isCurrentUser ? parent.left : undefined
    anchors.right: !isCurrentUser ? undefined : parent.right
    radius: Style.dp(4)
    z: -1
}
