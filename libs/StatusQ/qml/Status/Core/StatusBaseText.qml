import QtQuick

import Status.Core.Theme

/*!
   \qmltype StatusBaseText
   \inherits Text
   \inqmlmodule StatusQ.Core
   \since StatusQ.Core
   \brief Displays multiple lines of text. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-text.html}{Text}.

   The \c StatusBaseText item displays text.
   For example:

   \qml
       StatusBaseText {
           width: 240
           text: qsTr("Hello World!")
           font.pixelSize: 24
           color: Theme.pallete.directColor1
       }
   \endqml

   \image status_base_text.png

   For a list of components available see StatusQ.
*/

Text {
    font.family: Theme.baseFont.name
}
