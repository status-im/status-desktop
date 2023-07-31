import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
      \qmltype StatusWarningBox
      \inherits Control
      \inqmlmodule StatusQ.Controls
      \since StatusQ.Controls 0.1
      \brief Displays a customizable WarningBox component.
      Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-controls2-control.html}{Item}.

      The \c StatusWarningBox displays an customizable WarningBox for users to show an icon and text.
      For example:

      \qml
      StatusWarningBox {
          icon: "caution"
          text: qsTr("Warning!")
          bgColor: Theme.palette.warningColor1
      }
      \endqml

      \image status_warning_box.png

      For a list of components available see StatusQ.
*/

Control {
    id: root
    implicitWidth: 614
    implicitHeight: rowContent.height

    /*!
        \qmlproperty alias StatusWarningBox::text
        This property holds a reference to the StatusBaseText component's text property and displays the
        warning text.
    */
    property alias text: warningText.text
    /*!
        \qmlproperty string StatusWarningBox::icon
        This property sets the StatusWarningBox icon.
    */
    property string icon
    /*!
        \qmlproperty string StatusWarningBox::iconColor
        This property sets the StatusWarningBox icon color.
    */
    property string iconColor: "transparent"
    /*!
        \qmlproperty string StatusWarningBox::bgColor
        This property sets the StatusWarningBox background color.
    */
    property string bgColor: "transparent"
    /*!
        \qmlproperty string StatusWarningBox::borderColor
        This property sets the StatusWarningBox border color.
    */
    property string borderColor: Theme.palette.warningColor1
    /*!
        \qmlproperty string StatusWarningBox::textColor
        This property sets the StatusWarningBox text color.
    */
    property string textColor: Theme.palette.warningColor1

    background: Rectangle {
        radius: 8
        opacity: 0.5
        border.color: root.borderColor
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            color: root.bgColor
            radius: 8
            opacity: 0.2
        }
    }

    contentItem: Item {
        id: rowContent
        width: parent.width
        height: (row.height+32)//xlPadding
        RowLayout {
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            height: warningText.contentHeight
            spacing: 6
            StatusIcon {
                Layout.alignment: Qt.AlignTop
                icon: root.icon
                color: root.iconColor
            }
            StatusBaseText {
                id: warningText
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.primaryTextFontSize
                color: root.textColor
            }
        }
    }
}

