import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup

    onOpened: {
        searchBox.text = "";
        searchBox.forceActiveFocus(Qt.MouseFocusReason)
    }

    title: qsTr("Communities")

    SearchBox {
        id: searchBox
        iconWidth: 17
        iconHeight: 17
        customHeight: 36
        fontPixelSize: 15
    }

    ScrollView {
        anchors.fill: parent
        anchors.topMargin: Style.current.padding
        anchors.top: searchBox.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        id: svMembers
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: communitiesList.contentHeight > communitiesList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            anchors.fill: parent
            model: ListModel {
                id: data
            }
            spacing: 0
            clip: true
            id: communitiesList
            delegate: Item {
                StyledText {
                    text: "NAME"
                }
            }
        }
    }
    
    footer: StatusButton {
        text: qsTr("Create a community")
        anchors.right: parent.right
    }
}

