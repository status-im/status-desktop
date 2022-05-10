import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    signal userLoggedIn()

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        RowLayout {}
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "TODO OnboardingWorkflow"
        }
        Button {
            text: "Done"
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.userLoggedIn()
        }
        RowLayout {}
    }
}
