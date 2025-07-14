// AuthLanguageSelector.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 140
    height: 30

    property bool initialized: false

    property int initialIndex: {
        console.log("Проверяем выбранный язык")
            if (languageManager.currentLanguage() === "SigmaTap_en_US") {
                return 1
            }
            console.log("Условие с англ не верно");
            return 0
        }

    ComboBox {
        id: languageComboBox
        anchors.fill: parent
        font.pixelSize: 15

        currentIndex: initialIndex
        model: ["Русский", "English"]

        background: Rectangle {
            color: themeManager.inputBackground
            radius: 5
            border.color: themeManager.border
            border.width: 1
        }

        contentItem: Text {
            text: parent.currentText
            font.pixelSize: 15
            color: themeManager.inputTextColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        delegate: ItemDelegate {
            width: parent.width
            background: Rectangle {
                color: themeManager.background
                radius: 5
                border.color: themeManager.border
                border.width: 1
            }

            contentItem: Text {
                text: modelData
                font.pixelSize: 14
                color: themeManager.text
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        onCurrentIndexChanged: {
            if(root.initialized) {
                if (currentIndex === 0) {
                    languageManager.loadLanguage("SigmaTap_ru_RU")
                } else {
                    languageManager.loadLanguage("SigmaTap_en_US")
                }
            }
        }
    }
    Component.onCompleted: {
               // Разрешаем реагировать на смену языка после полной загрузки
               root.initialized = true
           }
}
