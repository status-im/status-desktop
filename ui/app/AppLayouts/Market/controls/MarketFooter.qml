import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

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
    }

    topPadding: 20
    bottomPadding: 20

    contentItem: Item {
        anchors.fill: parent

        implicitWidth: childrenRect.width
        implicitHeight: paginator.height

        StatusBaseText {
            id: infoText

            objectName: "infoText"

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

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

            anchors.centerIn: parent

            pageSize: root.pageSize
            totalCount: root.totalCount
            currentPage: root.currentPage
            onRequestPage: root.switchPage(pageNumber)
        }
    }
}
