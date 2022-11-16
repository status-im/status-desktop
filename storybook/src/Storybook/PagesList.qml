import QtQuick 2.14
import QtQuick.Controls 2.14

ListView {
    id: root

    spacing: 5
    clip: true

    property string currentPage

    signal pageSelected(string page)
    signal sectionClicked(int index)

    readonly property string foldedPrefix: "▶  "
    readonly property string unfoldedPrefix: "▼  "

    delegate: ItemDelegate {
        id: delegate

        width: ListView.view.width

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
