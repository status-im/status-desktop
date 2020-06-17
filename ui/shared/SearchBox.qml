import QtQuick 2.13
import "../imports"

Input {
    id: searchBox
    placeholderText: qsTr("Search")
    icon: "../app/img/search.svg"
    iconWidth: 17
    iconHeight: 17
    customHeight: 36
    fontPixelSize: 12
}
