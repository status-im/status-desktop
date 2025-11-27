import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Controls
import StatusQ.Components

Flow {
    id: root

    spacing: Theme.halfPadding / 2

    signal addEmojiClicked(var sender, var mouse)
    signal hoverChanged(bool hovered)
    signal toggleReaction(string hexcode)

    property var reactionsModel
    property bool limitReached: false

    QtObject {
        id: d

        function showReactionAuthors(jsonArrayOfUsersReactedWithThisEmoji, emoji) {
            if (!jsonArrayOfUsersReactedWithThisEmoji) {
                return
            }
            const listOfUsers = JSON.parse(jsonArrayOfUsersReactedWithThisEmoji)
            if (listOfUsers.error) {
                console.error("error parsing users who reacted to a message, error: ", obj.error)
                return
            }

            const maxReactions = 12
            const extraCount = listOfUsers.splice(maxReactions).length
            if (extraCount > 0) {
                listOfUsers.push(qsTr("%1 more").arg(extraCount)) // "a, b, ... and N more"
            }

            // Create a simple comma-separated list without using QLocale.createSeparatedList (not available in QML)
            return qsTr("%1 reacted with %2").arg(listOfUsers.join(", ")).arg(StatusQUtils.Emoji.fromCodePoint(emoji))
        }
    }

    Repeater {
        model: root.reactionsModel

        StatusButton {
            id: reactionDelegate

            size: StatusBaseButton.Size.Small
            implicitHeight: 32

            verticalPadding: Theme.halfPadding / 2
            leftPadding: Theme.halfPadding
            rightPadding: Theme.halfPadding / 2
            spacing: Theme.halfPadding / 2

            background: Rectangle {
                implicitWidth: 36
                radius: Theme.radius
                color: {
                    if (reactionDelegate.hovered) {
                        return Theme.palette.statusMessage.emojiReactionBackgroundHovered
                    }
                    return model.didIReactWithThisEmoji ? Theme.palette.primaryColor2 : Theme.palette.statusMessage.emojiReactionBackground
                }
                border.width: model.didIReactWithThisEmoji || reactionDelegate.hovered ? 1 : 0
                border.color: reactionDelegate.hovered ? Theme.palette.statusMessage.emojiReactionBorderHovered : Theme.palette.primaryColor1
            }

            contentItem: RowLayout {
                spacing: reactionDelegate.spacing

                StatusIcon {
                    objectName: "emojiReaction"
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    icon: Theme.emoji(model.emoji)
                }

                StatusBaseText {
                    text: model.numberOfReactions
                    font.pixelSize: Theme.fontSize13
                }
            }

            StatusToolTip {
                visible: reactionDelegate.hovered
                maxWidth: 400
                text: d.showReactionAuthors(model.jsonArrayOfUsersReactedWithThisEmoji, model.emoji) || ""
            }

            HoverHandler {
                cursorShape: hovered ? Qt.PointingHandCursor : undefined
                onHoveredChanged: root.hoverChanged(hovered)
            }

            onClicked: root.toggleReaction(model.emoji)
        }
    }

    StatusFlatButton {
        width: 36
        height: 32
        horizontalPadding: Theme.halfPadding
        verticalPadding: Theme.halfPadding/2
        visible: root.enabled
        icon.name: "reaction-b"
        size: StatusBaseButton.Size.Small
        icon.color: hovered && !root.limitReached ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
        tooltip.text: root.limitReached ? qsTr("Maximum number of different reactions reached") : qsTr("Add reaction")

        // We use a MouseArea because we need to pass the mouse event to the signal
        StatusMouseArea {
            anchors.fill: parent
            cursorShape: !root.limitReached ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            onClicked: (mouse) => {
                mouse.accepted = true
                if (root.limitReached)
                    return
                root.addEmojiClicked(this, mouse)
            }
        }
    }
}
