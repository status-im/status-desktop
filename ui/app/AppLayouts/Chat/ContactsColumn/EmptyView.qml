import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../components"
import "../../../../shared"

Item {
    id: suggestionsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    Row {
        id: description
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20

        StyledText {
            width: parent.width
            text: qsTr("Follow your interests in one of the many Public Chats.")
            font.pointSize: 15
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.FixedSize
            renderType: Text.QtRendering
            onLinkActivated: console.log(link)
        }
    }

    RowLayout {
        id: row
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: description.bottom
        anchors.topMargin: 20

        Flow {
            Layout.fillHeight: false
            Layout.fillWidth: true
            spacing: 6

            SuggestedChannel {
                channel: "introductions"
            }
            SuggestedChannel {
                channel: "chitchat"
            }
            SuggestedChannel {
                channel: "status"
            }
            SuggestedChannel {
                channel: "crypto"
            }
            SuggestedChannel {
                channel: "tech"
            }
            SuggestedChannel {
                channel: "music"
            }
            SuggestedChannel {
                channel: "movies"
            }
            SuggestedChannel {
                channel: "test"
            }
            SuggestedChannel {
                channel: "test2"
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
