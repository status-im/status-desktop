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

    /** output property representing current page set in Paginator **/
    readonly property int currentPage: d.currentPage

    QtObject {
        id: d
        property int currentPage: 1
        readonly property int totalPages: Math.ceil(root.totalCount/root.pageSize)

        function getPagesModel() {
            let pages = [];
            if (totalPages <= 5) {
                for (let i = 1; i <= totalPages; i++) pages.push(i);
            } else {
                if (currentPage <= 3) {
                    pages = [1, 2, 3, 4, 5, "...", totalPages];
                } else if (currentPage >= totalPages - 2) {
                    pages = [1, "...", totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
                } else {
                    pages = [1, "...", currentPage - 1, currentPage, currentPage + 1, "...", totalPages];
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
            enabled: d.currentPage > 1
            onClicked: {
                if (d.currentPage > 1) {
                    d.currentPage--;
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
                highlighted: modelData === d.currentPage
                onClicked: {
                    if (modelData !== "...") {
                        d.currentPage = modelData;
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
            enabled: d.currentPage < d.totalPages
            onClicked: {
                if (d.currentPage < d.totalPages) {
                    d.currentPage++;
                }
            }
        }
    }
}
