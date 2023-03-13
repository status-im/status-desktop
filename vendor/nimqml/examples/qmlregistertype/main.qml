import QtQuick 2.8
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ContactModule 1.0

ApplicationWindow {
    width: 400
    height: 300
    title: "qmlregistertype"

    Component.onCompleted: visible = true

    Contact {
        id: contact
        firstName: "John"
        lastName: "Doo"
    }

    Label {
        anchors.centerIn: parent;
        text: contact.firstName + " " + contact.lastName
    }

    RowLayout {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        Item { Layout.fillWidth: true }
        Label { text: "FirstName:" }
        TextField { Layout.preferredWidth: 100; onEditingFinished: contact.firstName = text }
        Item { width: 30 }
        Label { text: "LastName: " }
        TextField { Layout.preferredWidth: 100; onEditingFinished: contact.lastName = text }
        Item { Layout.fillWidth: true }
    }
}
