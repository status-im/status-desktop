import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

/// Responsible for setup of user workflows after onboarding
Item {
    id: root

    /// Emited when everything is loaded and UX ready
    signal ready()

    Component.onCompleted: root.ready()

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        RowLayout {}
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "TODO MainView"
        }
        Button {
            text: "Quit"
            Layout.alignment: Qt.AlignHCenter
            onClicked: Qt.quit()
        }

        RowLayout {}
    }
}
