import QtQuick 2.14

QtObject {
    property string title
    property string subTitle

    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
        isIdenticon: false
    }

    property StatusIconSettings icon: StatusIconSettings {
        width: 40
        height: 40
        isLetterIdenticon: false
    }
}
