pragma Singleton

import QtQuick 2.13
import "./Themes"

QtObject {
    property Theme current: lightTheme
    property Theme lightTheme: LightTheme { }
}
