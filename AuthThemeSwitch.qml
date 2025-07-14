// AuthThemeSwitch.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 50
    height: 50

    property string theme: "light"

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        width: 60
        height: 60
        radius: width / 2
        color: themeManager.background
        border.color: themeManager.border

        Text {
            anchors.centerIn: parent
            font.pixelSize: parent.width / 2
            text: root.theme === "dark" ? "🌙" : "☀️"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(theme === "light") {
                    themeManager.setTheme("light");
                    root.theme = "dark";
                } else {
                    themeManager.setTheme("dark");
                    root.theme = "light";
                }
            }
        }
    }
}
