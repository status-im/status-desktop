import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml 2.14
import "../../imports"
import "../../shared"

RoundButton {
    property string type: "primary"
    property string state: "default"
    font.pixelSize: 15
    font.weight: Font.Medium

    enabled: state === "default"

    id: control
    height: 44
    width: 44

    /* background: Rectangle { */
    /*     color: Style.current.roundedButtonBackgroundColor */
    /*     radius: parent.width / 2 */
    /* } */

    /* contentItem: Item { */
    /*     anchors.fill: parent */
    /*     LoadingImage { */
    /*         id: loadingIndicator */
    /*         visible: control.state === "pending" */
    /*         height: loadingIndicator.visible ? 23 : 0 */
    /*         width: loadingIndicator.height */
    /*         anchors.horizontalCenter: parent.horizontalCenter */
    /*         anchors.verticalCenter: parent.verticalCenter */
    /*     } */
    /* } */
}
