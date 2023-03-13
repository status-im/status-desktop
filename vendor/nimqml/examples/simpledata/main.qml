import QtQuick 2.8
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ApplicationWindow {
    width: 400
    height: 300
    title: "SimpleData"

    Component.onCompleted: visible = true

    ColumnLayout {
        anchors.fill: parent
        SpinBox { value: qVar1}
        TextField { text: qVar2}
        CheckBox { checked: qVar3}
        SpinBox { value: qVar4 }
    }
}
