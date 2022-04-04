import QtQuick 2.3
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import shared 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1 as StatusQ
import utils 1.0

Item {
    id: root
    height: 20
    width: childrenRect.width

    property int imageMargin: 4
    signal addEmojiClicked()
    signal hoverChanged(bool hovered)
    signal toggleReaction(int emojiID)
    signal setMessageActive(string messageId, bool active)

    property var store
    property bool isCurrentUser
    property var emojiReactionsModel
    property bool isMessageActive

    Row {
        spacing: root.imageMargin

        Repeater {
            id: reactionRepeater
            width: childrenRect.width
            model: root.emojiReactionsModel

            Rectangle {
                property bool isHovered: false

                id: emojiContainer
                width: emojiImage.width + emojiCount.width + (root.imageMargin * 2) +  + 8
                height: 20
                radius: 10
                color: model.didIReactWithThisEmoji ?
                           (isHovered ? Style.current.emojiReactionActiveBackgroundHovered : Style.current.secondaryBackground) :
                           (isHovered ? Style.current.emojiReactionBackgroundHovered : Style.current.emojiReactionBackground)

                StatusQ.StatusToolTip {
                    visible: mouseArea.containsMouse
                    maxWidth: 400
                    text: root.store.showReactionAuthors(model.jsonArrayOfUsersReactedWithThisEmoji, model.emojiId)
                }

                // Rounded corner to cover one corner
                Rectangle {
                    color: parent.color
                    width: 10
                    height: 10
                    anchors.top: parent.top
                    anchors.left: !root.isCurrentUser? parent.left : undefined
                    anchors.leftMargin: 0
                    anchors.right: !root.isCurrentUser? undefined : parent.right
                    anchors.rightMargin: 0
                    radius: 2
                    z: -1
                }

                // This is a workaround to get a "border" around the rectangle including the weird rectangle
                Loader {
                    active: model.didIReactWithThisEmoji
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
                                anchors.left: !root.isCurrentUser? parent.left : undefined
                                anchors.leftMargin: 0
                                anchors.right: !root.isCurrentUser? undefined : parent.right
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
                    height: 15
                    fillMode: Image.PreserveAspectFit
                    source: {
                        switch (model.emojiId) {
                        case 1: return Style.svg("emojiReactions/heart")
                        case 2: return Style.svg("emojiReactions/thumbsUp")
                        case 3: return Style.svg("emojiReactions/thumbsDown")
                        case 4: return Style.svg("emojiReactions/laughing")
                        case 5: return Style.svg("emojiReactions/sad")
                        case 6: return Style.svg("emojiReactions/angry")
                        default: return ""
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.imageMargin
                }

                StyledText {
                    id: emojiCount
                    text: model.numberOfReactions
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: emojiImage.right
                    anchors.leftMargin: root.imageMargin
                    font.pixelSize: 12
                    color: model.didIReactWithThisEmoji ? Style.current.textColorTertiary : Style.current.textColor
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
                        toggleReaction(model.emojiId)
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
                source: Style.svg("emoji")
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
                    if (typeof root.isMessageActive !== "undefined") {
                        setMessageActive(messageId, true);
                    }
                    root.addEmojiClicked();
                }
            }

            StatusQ.StatusToolTip {
              visible: addEmojiBtn.isHovered
              text: qsTr("Add reaction")
            }
        }
    }
}
