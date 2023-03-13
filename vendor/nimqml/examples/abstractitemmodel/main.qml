import QtQuick 2.8
import QtQuick.Controls 2.3

ApplicationWindow {
    width: 400
    height: 300
    title: "AbstractItemModel"

    Component.onCompleted: visible = true

    Component {
        id: myListModelDelegate
        Label { text: "Name:" + name }
    }

    ListView {
        anchors.fill: parent
        model: myListModel
        delegate: myListModelDelegate
    }
}
