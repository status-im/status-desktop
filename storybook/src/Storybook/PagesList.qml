import QtQuick 2.14
import QtQuick.Controls 2.14

ListView {
    id: root

    clip: true

    property string currentPage

    signal pageSelected(string page)
    signal sectionClicked(int index)

    readonly property string foldedPrefix: "▶  "
    readonly property string unfoldedPrefix: "▼  "

    ScrollBar.vertical: ScrollBar {}

    delegate: ItemDelegate {
        id: delegate

        width: ListView.view.width

        Drag.dragType: Drag.Automatic
        Drag.active: dragArea.drag.active
        Drag.mimeData: {
            "text/uri-list": `file:${pagesFolder}/${model.title}Page.qml`
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent

            drag.target: this
            acceptedButtons: Qt.RightButton
        }

        TextMetrics {
            id: textMetrics
            text: root.unfoldedPrefix
            font: delegate.font
        }

        function sectionPrefix(isFolded) {
            return isFolded ? foldedPrefix : unfoldedPrefix
        }

        text: model.isSection
              ? sectionPrefix(model.isFolded) + model.section + ` (${model.subitemsCount})`
              : model.title

        font.bold: model.isSection
        highlighted: root.currentPage === model.title

        onClicked: model.isSection
                   ? sectionClicked(index)
                   : root.pageSelected(model.title)

        Component.onCompleted: {
            if (!model.isSection)
                leftPadding += textMetrics.advanceWidth
        }
    }
}
