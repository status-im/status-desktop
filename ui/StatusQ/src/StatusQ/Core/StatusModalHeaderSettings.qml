import QtQuick 2.14

QtObject {
    property string title
    property string subTitle
    property StatusIconSettings detailsButtonSettings: StatusIconSettings {
        width: 20
        height: 20
    }

    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
    }
}
