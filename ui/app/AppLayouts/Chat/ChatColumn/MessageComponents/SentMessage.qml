import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

SVGImage {
    id: sentMessage
    width: visible ? 9 : 0
    height: visible ? 9 : 0
    source: visible ? "../../../../img/check.svg" : ""
}
