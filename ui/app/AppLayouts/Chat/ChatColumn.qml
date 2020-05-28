import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../shared"
import "../../../imports"
import "./ChatColumn"

StackLayout {
    property int chatGroupsListViewCount: 0
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.minimumWidth: 300

    currentIndex: chatGroupsListViewCount > 0 ? 0 : 1

    ColumnLayout {
        id: chatColumn

        RowLayout {
            id: chatTopBar
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            z: 60

            TopBar {}
        }

        RowLayout {
            id: chatContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop

            ChatMessages {}
       }

        RowLayout {
            id: chatInputContainer
            height: 70
            Layout.fillWidth: true
            Layout.bottomMargin: 0
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            transformOrigin: Item.Bottom

            ChatInput {}
        }
    }

    EmptyChat {}
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:770;width:800}
}
##^##*/
