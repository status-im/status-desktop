import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

ListModel {
    ListElement {
        userName: "Ferocious Herringbone Sinewave"
        message: "Everybody betrayed me! \n I'm fed up with this world."
        repeatMessageInfo: true
    }
    ListElement {
        userName: "Teenage Mutant Turtle"
        message: "You're tearing me apart, Lisa!"
        repeatMessageInfo: true
    }
    ListElement {
        userName: "Teenage Mutant Turtle"
        message: "It's bullshit, I did not hit her.\nI did nooot."
        repeatMessageInfo: false
    }
    ListElement {
        userName: "Teenage Mutant Turtle"
        message: "Oh hi, Mark!"
        repeatMessageInfo: false
    }
    ListElement {
        userName: "me"
        message: "Hi Johnny"
        isCurrentUser: true
        repeatMessageInfo: true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
