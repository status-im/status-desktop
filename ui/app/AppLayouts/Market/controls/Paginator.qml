import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core.Theme

Control {
    id: root

    /** required input property representing page size **/
    required property int pageSize
    /** required input property representing total count of items **/
    required property int totalCount
    /** required property representing current page set from outside **/
    required property int currentPage

    property bool compactMode: false

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
        function getCompactPagesModel() {
            let pages = [];
            if (totalPages <= 3) {
                for (let i = 1; i <= totalPages; i++) pages.push(i);
            } else {
                if (root.compactMode) {
                    // --- COMPACT MODE ---
                    if (root.currentPage == 1 || root.currentPage == totalPages) {
                        // At first page or at the last page
                        pages = [1, "...", totalPages];
                    } else if (root.currentPage === 2) {
                        // Near the beginning
                        pages = [1, 2, "...", totalPages];
                    } else if (root.currentPage === totalPages - 1) {
                        // Near the end
                        pages = [1, "...", totalPages - 1, totalPages];
                    } else {
                        // Somewhere in the middle
                        pages = [1, "...", root.currentPage, "...", totalPages];
                    }
                }
            }
            return pages;
        }
    }

    contentItem: RowLayout {
        spacing: Theme.halfPadding
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

            model: root.compactMode ? d.getCompactPagesModel() : d.getPagesModel()
            delegate: StatusButton {
                objectName: "numberButton_"+ index

                font.pixelSize: Theme.additionalTextSize
                normalColor: Theme.palette.transparent
                hoverColor: Theme.palette.primaryColor3
                disabledColor: Theme.palette.transparent
                size: root.compactMode ? StatusBaseButton.Size.Small : StatusBaseButton.Size.Large

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
