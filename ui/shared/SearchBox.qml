import QtQuick 2.13

import utils 1.0
import "./controls"

Input {
    id: searchBox
    //% "Search"
    placeholderText: qsTrId("search")
    icon: Style.svg("search")
    iconWidth: 24
    iconHeight: 24
    customHeight: 36
    fontPixelSize: 15
}
