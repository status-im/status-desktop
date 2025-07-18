import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

Control {
    id: root

    /** required input property representing page size **/
    required property int pageSize
    /** required input property representing total count of items **/
    required property int totalCount
    /** required property representing current page set from outside **/
    required property int currentPage

    /** signla to update next page **/
    signal switchPage(int pageNumber)

    QtObject {
        id: d

        // Calculate the starting index
        property int startIndex: ((paginator.currentPage - 1) * root.pageSize) + 1
        // Calculate the ending index (ensuring it doesn't exceed totalCount)
        property int endIndex: Math.min(paginator.currentPage * root.pageSize, root.totalCount)
        // Determine if there is not enough width to display both info text and paginator side by side
        readonly property bool isPortrait: infoText.width + paginator.width > root.width
    }

    topPadding: 20
    bottomPadding: 20

    contentItem: GridLayout {

        rows: d.isPortrait ? 2 : 0
        columns: d.isPortrait ? 0 : 2
        flow: d.isPortrait ? GridLayout.TopToBottom:
                                 GridLayout.LeftToRight

        StatusBaseText {
            id: infoText

            objectName: "infoText"

            Layout.alignment: d.isPortrait ? Qt.AlignHCenter :
                                                 Qt.AlignLeft | Qt.AlignVCenter

            color: Theme.palette.baseColor1
            font.pixelSize: Theme.additionalTextSize
            lineHeightMode: Text.FixedHeight
            lineHeight: 18

            text: qsTr("Showing %1 to %2 of %3 results").
            arg(LocaleUtils.numberToLocaleString(d.startIndex)).
            arg(LocaleUtils.numberToLocaleString(d.endIndex)).
            arg(LocaleUtils.numberToLocaleString(root.totalCount))
        }

        Paginator {
            id: paginator

            objectName: "paginator"

            Layout.alignment: d.isPortrait ? Qt.AlignHCenter :
                                                 Qt.AlignVCenter

            pageSize: root.pageSize
            totalCount: root.totalCount
            currentPage: root.currentPage
            onRequestPage: root.switchPage(pageNumber)
        }
    }
}
