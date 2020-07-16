import QtQuick 2.3

// This rectangle's only job is to mask the corner to make it less rounded... yep
Rectangle {
    color: parent.color
    width: 18
    height: 18
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0
    anchors.left: !isCurrentUser ? parent.left : undefined
    anchors.leftMargin: 0
    anchors.right: !isCurrentUser ? undefined : parent.right
    anchors.rightMargin: 0
    radius: 4
    z: -1
}
