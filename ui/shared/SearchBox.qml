import QtQuick 2.13
import "../imports"

Input {
    id: searchBox
    //% "Search"
    placeholderText: qsTrId("search")
    icon: "../app/img/search.svg"
    iconWidth: 17 * scaleAction.factor
    iconHeight: 17 * scaleAction.factor
    customHeight: 36 * scaleAction.factor
    fontPixelSize: 15 * scaleAction.factor
}
