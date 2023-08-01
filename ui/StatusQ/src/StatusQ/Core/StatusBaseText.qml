import QtQuick 2.13
import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusBaseText
   \inherits Text
   \inqmlmodule StatusQ.Core
   \since StatusQ.Core 0.1
   \brief Displays multiple lines of text. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-text.html}{Text}.

   The \c StatusBaseText item displays text.
   For example:

   \qml
       StatusBaseText {
           width: 240
           text: qsTr("Hello World!")
           font.pixelSize: 24
           color: Theme.palette.directColor1
       }
   \endqml

   \image status_base_text.png

   For a list of components available see StatusQ.
*/

Text {
    font.family: Theme.palette.baseFont.name
    font.pixelSize: Theme.primaryTextFontSize
    color: Theme.palette.directColor1
    linkColor: hoveredLink ? Qt.lighter(Theme.palette.primaryColor1)
                           : Theme.palette.primaryColor1
}
