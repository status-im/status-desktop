import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../data/channelList.js" as ChannelJSON
import "./"

Repeater {
    id: sectionRepeater
    model: ChannelJSON.categories
    Item {
        anchors.top: index === 0 ? parent.top : parent.children[index - 1].bottom
        anchors.topMargin: index === 0 ? 0 : Style.current.padding
        width: parent.width - Style.current.padding
        height: childrenRect.height

        StyledText {
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
                model: modelData.channels
                SuggestedChannel { channel: modelData }
            }
        }

    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
