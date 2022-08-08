import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Qt.labs.calendar 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusDatePicker
   \inherits StatusQ.Controls.StatusComboBox
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief Displays a date picker based on a combobox with a calendar popup

   The \c StatusDatePicker displays a date picker based on a combobox with a calendar popup.
   The property \p selectedDate reflects the currently chosen date (defaults to today).

   For a list of components available see StatusQ.
*/
StatusComboBox {
    id: root

    /*!
       \qmlproperty string StatusDatePicker::dateFormat

       This property specifies how the selected date will be displayed to the user.
       By default it is current locale's short date format. For a list of available types
       and formatting characters, see https://doc.qt.io/qt-5/qdate.html#toString-2
    */
    property string dateFormat: Qt.locale().dateFormat(Locale.ShortFormat)

    /*!
       \qmlproperty date StatusDatePicker::selectedDate

       This property holds the currently selected date.
       \sa QtQml.Date
    */
    readonly property alias selectedDate: d.selectedDate

    QtObject {
        id: d
        property date selectedDate: new Date()
    }

    control.delegate: null
    control.displayText: root.selectedDate.toLocaleDateString(Qt.locale(), root.dateFormat)
    control.popup.horizontalPadding: 8

    control.popup.onAboutToShow: {
        // always open the popup showing the last (currently) selected date
        grid.year = d.selectedDate.getFullYear()
        grid.month = d.selectedDate.getMonth()
    }

    control.popup.contentItem: Item {
        property alias grid: grid
        GridLayout {
            anchors.fill: parent
            columns: 2

            RowLayout {
                Layout.fillWidth: true
                Layout.columnSpan: 2
                StatusFlatButton {
                    text: "<<"
                    onClicked: grid.year = grid.year - 1
                    StatusToolTip {
                        text: qsTr("Previous year")
                        visible: parent.hovered
                    }
                }
                StatusFlatButton {
                    text: "<"
                    onClicked: {
                        // switch to previous month (and optionally prev year in January)
                        const date = new Date(grid.year, grid.month)
                        date.setMonth(date.getMonth() - 1)
                        grid.month = date.getMonth()
                        grid.year = date.getFullYear()
                    }
                    StatusToolTip {
                        text: qsTr("Previous month")
                        visible: parent.hovered
                    }
                }
                StatusFlatButton {
                    Layout.fillWidth: true
                    text: grid.title
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    onClicked: {
                        const date = new Date()
                        grid.month = date.getMonth()
                        grid.year = date.getFullYear()
                    }
                    StatusToolTip {
                        text: qsTr("Show current month")
                        visible: parent.hovered
                    }
                }
                StatusFlatButton {
                    text: ">"
                    onClicked: {
                        // switch to next month (and optionally next year in December)
                        const date = new Date(grid.year, grid.month)
                        date.setMonth(date.getMonth() + 1)
                        grid.month = date.getMonth()
                        grid.year = date.getFullYear()
                    }
                    StatusToolTip {
                        text: qsTr("Next month")
                        visible: parent.hovered
                    }
                }
                StatusFlatButton {
                    text: ">>"
                    onClicked: grid.year = grid.year + 1
                    StatusToolTip {
                        text: qsTr("Next year")
                        visible: parent.hovered
                    }
                }
            }

            DayOfWeekRow {
                Layout.row: 1
                Layout.column: 1
                Layout.fillWidth: true
                delegate: StatusBaseText {
                    text: model.shortName
                    color: Theme.palette.directColor3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            WeekNumberColumn {
                id: weekColumn
                month: grid.month
                year: grid.year
                Layout.fillHeight: true
                delegate: StatusBaseText {
                    text: model.weekNumber
                    color: Theme.palette.directColor3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MonthGrid {
                id: grid
                month: d.selectedDate.getMonth()
                year: d.selectedDate.getFullYear()
                Layout.fillWidth: true
                Layout.fillHeight: true
                delegate: StatusFlatButton {
                    readonly property bool selected: d.selectedDate.getFullYear() === model.year &&
                                                     d.selectedDate.getMonth() === model.month &&
                                                     d.selectedDate.getDate() === model.day
                    opacity: model.month === grid.month ? 1 : 0.5
                    text: model.day
                    textColor: selected ? Theme.palette.primaryColor1 : Theme.palette.directColor1
                    font.bold: selected || model.today
                    onClicked: {
                        d.selectedDate = model.date
                        root.control.popup.close()
                    }
                }
            }
        }
    }
}
