import QtQuick 2.14
import QtQuick.Controls 2.14

ListView {
    id: root

    spacing: 5
    clip: true

    property string currentPage
    signal pageSelected(string page)

    delegate: Button {
        width: parent.width

        text: model.title
        checked: root.currentPage === model.title

        onClicked: root.pageSelected(model.title)
        onCheckableChanged: checkable = false
    }
}
