import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

Item {
    id: root

    property int count

    // delegate properites
    property bool outgoing
    property string text
    property int index

    implicitHeight: 20

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: "white"
        }

        Text {
            text: qsTr("%1 missed messages").arg(root.count)
            color: "white"
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: "white"
        }
    }
}
