import QtQuick 2.14
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "./samples/"
import "../../../../../imports"
import "../../../../../shared"

ListView {
    property var contacts: ContactsData {}

    anchors.topMargin: 48
    anchors.top: element2.bottom
    anchors.fill: parent

    model: contacts
    delegate: Contact {
        name: model.name
        address: model.address
        identicon: model.identicon
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
