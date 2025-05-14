import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Control {
    id: root

    /** required input property representing page size **/
    required property int pageSize
    /** required input property representing total count of items **/
    required property int totalCount
    /** required property representing current page set from outside **/
    required property int currentPage

    signal requestPage(int pageNumber)

    QtObject {
        id: d
        readonly property int totalPages: Math.ceil(root.totalCount/root.pageSize)

        function getPagesModel() {
            let pages = [];
            if (totalPages <= 5) {
                for (let i = 1; i <= totalPages; i++) pages.push(i);
            } else {
                if (root.currentPage <= 3) {
                    pages = [1, 2, 3, 4, 5, "...", totalPages];
                } else if (root.currentPage >= totalPages - 2) {
                    pages = [1, "...", totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
                } else {
                    pages = [1, "...", root.currentPage - 1, root.currentPage, root.currentPage + 1, "...", totalPages];
                }
            }
            return pages;
        }
    }

    contentItem: RowLayout {
        spacing: 8
        StatusButton {
            objectName: "previousButton"

            font.pixelSize: Theme.additionalTextSize
            normalColor: Theme.palette.transparent
            hoverColor: Theme.palette.primaryColor3
            disabledColor: Theme.palette.transparent

            icon.name: "previous"
            enabled: root.currentPage > 1
            onClicked: {
                if (root.currentPage > 1) {
                    root.requestPage(root.currentPage - 1)
                }
            }
        }

        Repeater {
            objectName: "pageNumbersRepeater"

            model: d.getPagesModel()
            delegate: StatusButton {
                objectName: "numberButton_"+ index

                font.pixelSize: Theme.additionalTextSize
                normalColor: Theme.palette.transparent
                hoverColor: Theme.palette.primaryColor3
                disabledColor: Theme.palette.transparent

                text: modelData
                enabled: modelData !== "..."
                highlighted: modelData === root.currentPage
                onClicked: {
                    if (modelData !== "...") {
                        root.requestPage(modelData)
                    }
                }
            }
        }

        StatusButton {
            objectName: "nextButton"

            font.pixelSize: Theme.additionalTextSize
            normalColor: Theme.palette.transparent
            hoverColor: Theme.palette.primaryColor3
            disabledColor: Theme.palette.transparent

            icon.name: "next"
            enabled: root.currentPage < d.totalPages
            onClicked: {
                if (root.currentPage < d.totalPages) {
                    root.requestPage(root.currentPage + 1)
                }
            }
        }
    }
}
