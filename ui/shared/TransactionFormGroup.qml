import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

FormGroup {
    id: root
    property string headerText
    property string footerText
    property bool showBackBtn: true
    property bool showNextBtn: true
    property var onBackClicked
    property var onNextClicked
}