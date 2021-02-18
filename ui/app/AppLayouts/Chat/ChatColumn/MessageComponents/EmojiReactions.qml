import QtQuick 2.3
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../../../imports"

Item {
    property int imageMargin: 4
    signal hoverChanged(bool hovered)

    id: root
    height: 20
    width: childrenRect.width

    function lastTwoItems(nodes) {
        //% " and "
        return nodes.join(qsTrId("-and-"));
    }

    function showReactionAuthors(fromAccounts, emojiId) {
        let tooltip
        if (fromAccounts.length === 1) {
            tooltip = fromAccounts[0]
        } else if (fromAccounts.length === 2) {
            tooltip = lastTwoItems(fromAccounts);
        } else {
            var leftNode = [];
            var rightNode = [];
            const maxReactions = 12
            let maximum = Math.min(maxReactions, fromAccounts.length)

            if (fromAccounts.length > maxReactions) {
                leftNode = fromAccounts.slice(0, maxReactions);
                rightNode = fromAccounts.slice(maxReactions, fromAccounts.length);
                return (rightNode.length === 1) ?
                            lastTwoItems([leftNode.join(", "), rightNode[0]]) :
                            //% "%1 more"
                            lastTwoItems([leftNode.join(", "), qsTrId("-1-more").arg(rightNode.length)]);
            }

            leftNode = fromAccounts.slice(0, maximum - 1);
            rightNode = fromAccounts.slice(maximum - 1, fromAccounts.length);
            tooltip = lastTwoItems([leftNode.join(", "), rightNode[0]])
        }

        //% " reacted with "
        tooltip += qsTrId("-reacted-with-");

        switch (emojiId) {
        case 1: return tooltip + ":heart:"
        case 2: return tooltip + ":thumbsup:"
        case 3: return tooltip + ":thumbsdown:"
        case 4: return tooltip + ":laughing:"
        case 5: return tooltip + ":cry:"
        case 6: return tooltip + ":angry:"
        default: return tooltip
        }
    }

    Row {
        spacing: root.imageMargin

        Repeater {
            id: reactionRepeater
            width: childrenRect.width
            model: emojiReactionsModel

            Rectangle {
                property bool isHovered: false

                id: emojiContainer
                width: emojiImage.width + emojiCount.width + (root.imageMargin * 2) +  + 8
                height: 20
                radius: 10
                color: modelData.currentUserReacted ?
                           (isHovered ? Style.current.emojiReactionActiveBackgroundHovered : Style.current.secondaryBackground) :
                           (isHovered ? Style.current.emojiReactionBackgroundHovered : Style.current.emojiReactionBackground)

                StatusToolTip {
                    visible: mouseArea.containsMouse
                    maxWidth: 400
                    text: showReactionAuthors(modelData.fromAccounts, modelData.emojiId)
                }

                // Rounded corner to cover one corner
                Rectangle {
                    color: parent.color
                    width: 10
                    height: 10
                    anchors.top: parent.top
                    anchors.left: !isCurrentUser || appSettings.useCompactMode ? parent.left : undefined
                    anchors.leftMargin: 0
                    anchors.right: !isCurrentUser || appSettings.useCompactMode ? undefined : parent.right
                    anchors.rightMargin: 0
                    radius: 2
                    z: -1
                }

                // This is a workaround to get a "border" around the rectangle including the weird rectangle
                Loader {
                    active: modelData.currentUserReacted
                    anchors.top: parent.top
                    anchors.topMargin: -1
                    anchors.left: parent.left
                    anchors.leftMargin: -1
                    z: -2

                    sourceComponent: Component {
                        Rectangle {
                            width: emojiContainer.width + 2
                            height: emojiContainer.height + 2
                            radius: emojiContainer.radius
                            color: Style.current.primary

                            Rectangle {
                                color: parent.color
                                width: 10
                                height: 10
                                anchors.top: parent.top
                                anchors.left: !isCurrentUser || appSettings.useCompactMode ? parent.left : undefined
                                anchors.leftMargin: 0
                                anchors.right: !isCurrentUser || appSettings.useCompactMode ? undefined : parent.right
                                anchors.rightMargin: 0
                                radius: 2
                                z: -1
                            }
                        }
                    }
                }

                SVGImage {
                    id: emojiImage
                    width: 15
                    fillMode: Image.PreserveAspectFit
                    source: {
                        const basePath = "../../../../img/emojiReactions/"
                        switch (modelData.emojiId) {
                        case 1: return basePath + "heart.svg"
                        case 2: return basePath + "thumbsUp.svg"
                        case 3: return basePath + "thumbsDown.svg"
                        case 4: return basePath + "laughing.svg"
                        case 5: return basePath + "sad.svg"
                        case 6: return basePath + "angry.svg"
                        default: return ""
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.imageMargin
                }

                StyledText {
                    id: emojiCount
                    text: modelData.count
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: emojiImage.right
                    anchors.leftMargin: root.imageMargin
                    font.pixelSize: 12
                    color: modelData.currentUserReacted ? Style.current.textColorTertiary : Style.current.textColor
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        root.hoverChanged(true)
                        emojiContainer.isHovered = true
                    }
                    onExited: {
                        root.hoverChanged(false)
                        emojiContainer.isHovered = false
                    }
                    onClicked: {
                        chatsModel.toggleReaction(messageId, modelData.emojiId)

                    }
                }
            }
        }

        Item {
            width: addEmojiBtn.width + addEmojiBtn.anchors.leftMargin // there is more margin between the button and the emojis than between each emoji
            height: addEmojiBtn.height

            SVGImage {
                property bool isHovered: false

                id: addEmojiBtn
                source: "../../../../img/emoji.svg"
                width: 16.5
                height: 16.5
                anchors.left: parent.left
                anchors.leftMargin: 2.5

            }

            ColorOverlay {
                anchors.fill: addEmojiBtn
                antialiasing: true
                source: addEmojiBtn
                color: addEmojiBtn.isHovered ? Style.current.primary : Style.current.secondaryText
            }

            MouseArea {
                anchors.fill: addEmojiBtn
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: addEmojiBtn.isHovered = true
                onExited: addEmojiBtn.isHovered = false
                onClicked: {
                    if (typeof isMessageActive !== "undefined") {
                        isMessageActive = true
                    }
                    clickMessage(false, false, false, null, true)
                }
            }

            StatusToolTip {
              visible: addEmojiBtn.isHovered
              //% "Add reaction"
              text: qsTrId("add-reaction")
            }
        }
    }
}
