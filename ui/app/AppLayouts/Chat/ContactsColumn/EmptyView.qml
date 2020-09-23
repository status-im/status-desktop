import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../components"
import "../data/channelList.js" as ChannelJSON
import "../../../../shared"
import "../../../../imports"

//Item {
            ScrollView {
//                id: sview
                clip: true

//                anchors.top: suggestionsText.bottom
//                anchors.topMargin: Style.current.smallPadding
//                anchors.left: parent.left
//                anchors.right: parent.right
//                anchors.bottom: parent.bottom

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
//                Layout.fillHeight: true
//                Layout.fillWidth: true
    property var onCloseButtonPressed: function () {}

    id: emptyView
    Layout.fillHeight: true
    Layout.fillWidth: true

    contentHeight: {
        var totalHeight = 0
        for (let i = 0; i < sectionRepeater.count; i++) {
            totalHeight += sectionRepeater.itemAt(i).height + Style.current.padding
        }
        return inviteFriendsContainer.height + totalHeight + Style.current.padding
//        return totalHeight
    }

    Rectangle {
        id: emptyViewContent
        border.color: Style.current.border
        radius: 16
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        height: inviteFriendsContainer.height + suggestionContainer.height
        color: Style.current.transparent

        Item {
            id: inviteFriendsContainer
            height: 190
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            SVGImage {
                anchors.top: parent.top
                anchors.topMargin: -6
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../../img/chatEmptyHeader.svg"
                width: 66
                height: 50
            }

            SVGImage {
                id: closeImg
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                source: "../../../img/close.svg"
                height: 20
                width: 20
            }
            ColorOverlay {
                anchors.fill: closeImg
                source: closeImg
                color: Style.current.darkGrey
            }
            MouseArea {
                anchors.fill: closeImg
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    emptyView.onCloseButtonPressed()
                }
            }

            StyledText {
                id: chatAndTransactText
                //% "Chat and transact privately with your friends"
                text: qsTrId("chat-and-transact-privately-with-your-friends")
                anchors.top: parent.top
                anchors.topMargin: 56
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 15
                wrapMode: Text.WordWrap
                anchors.right: parent.right
                anchors.rightMargin: Style.current.xlPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.xlPadding
            }

            StyledButton {
                //% "Invite friends"
                label: qsTrId("invite-friends")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.xlPadding
                onClicked: {
                    inviteFriendsPopup.open()
                }
            }

            InviteFriendsPopup {
                id: inviteFriendsPopup
            }
        }

        Separator {
            anchors.topMargin: 0
            anchors.top: inviteFriendsContainer.bottom
            color: Style.current.border
        }

        Item {
            id: suggestionContainer
            anchors.top: inviteFriendsContainer.bottom
            anchors.right: parent.right
            anchors.left: parent.left
//            height: suggestionsText.height + channelFlow.height + 2 * Style.current.xlPadding + Style.current.bigPadding
//            height: suggestionsText.height + 2 * Style.current.xlPadding + Style.current.bigPadding

            StyledText {
                id: suggestionsText
                width: parent.width
                //% "Follow your interests in one of the many Public Chats."
                text: qsTrId("follow-your-interests-in-one-of-the-many-public-chats.")
                anchors.top: parent.top
                anchors.topMargin: Style.current.xlPadding
                font.pointSize: 15
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.FixedSize
                renderType: Text.QtRendering
                anchors.right: parent.right
                anchors.rightMargin: Style.current.xlPadding
                anchors.left: parent.left
                anchors.leftMargin: Style.current.xlPadding
            }

//            ScrollView {
//                id: sview
//                clip: true

//                anchors.top: suggestionsText.bottom
//                anchors.topMargin: Style.current.smallPadding
//                anchors.left: parent.left
//                anchors.right: parent.right
//                anchors.bottom: parent.bottom

//                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
//                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
//                Layout.fillHeight: true
//                Layout.fillWidth: true
//                contentHeight: {
//                    var totalHeight = 0
//                    for (let i = 0; i < sectionRepeater.count; i++) {
//                        totalHeight += sectionRepeater.itemAt(i).height + Style.current.padding
//                    }
//                    return totalHeight + Style.current.padding
//                }

                Repeater {
                    id: sectionRepeater
                                    anchors.top: suggestionsText.bottom
                                    anchors.topMargin: Style.current.smallPadding
//                    id: sview
                    model: ChannelJSON.categories
                    Item {
                        anchors.top: index === 0 ? suggestionsText.bottom : parent.children[index - 1].bottom
                        anchors.topMargin: index === 0 ? 0 : Style.current.padding
                        width: parent.width - Style.current.padding
//                        height: {
//                            return childrenRect.height
//                        }

                        height: {
                            var totalHeight = 0
                            for (let i = 0; i < channelRepeater.count; i++) {
                                totalHeight += channelRepeater.itemAt(i).height + Style.current.padding
                            }
                            return totalHeight
                        }

                        Text {
                            id: sectionTitle
                            text: modelData.name
                            font.bold: true
                            font.pixelSize: 16
                        }
                        Flow {
                            anchors.top: sectionTitle.bottom
                            anchors.topMargin: Style.current.smallPadding
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            width: parent.width
                            spacing: 10
                            Repeater {
                                id: channelRepeater
                                model: modelData.channels
                                SuggestedChannel { channel: modelData }
                            }
                        }

                    }

                }
//            }

//            Flow {
//                id: channelFlow
//                Layout.fillHeight: false
//                Layout.fillWidth: true
//                spacing: 6
//                anchors.right: parent.right
//                anchors.rightMargin: Style.current.xlPadding
//                anchors.left: parent.left
//                anchors.leftMargin: Style.current.xlPadding
//                anchors.top: suggestionsText.bottom
//                anchors.topMargin: Style.current.bigPadding

//                SuggestedChannel {
//                    channel: "introductions"
//                }
//                SuggestedChannel {
//                    channel: "chitchat"
//                }
//                SuggestedChannel {
//                    channel: "status"
//                }
//                SuggestedChannel {
//                    channel: "crypto"
//                }
//                SuggestedChannel {
//                    channel: "tech"
//                }
//                SuggestedChannel {
//                    channel: "music"
//                }
//                SuggestedChannel {
//                    channel: "movies"
//                }
//                SuggestedChannel {
//                    channel: "test"
//                }
//                SuggestedChannel {
//                    channel: "test2"
//                }
//            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:1.25;height:500;width:300}
}
##^##*/
