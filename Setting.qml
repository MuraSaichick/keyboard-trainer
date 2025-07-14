import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: root
    visible: false
    width: 400
    height: 480
    title: qsTr("Настройки")
    color: "transparent"

    // Анимация появления окна
    opacity: visible ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    // Компонент элемента настройки (переиспользуемый)
    component SettingItem: Item {
        property string iconText: ""
        property string settingText: ""
        height: 50

        Rectangle {
            id: iconBg
            width: 36
            height: 36
            radius: 8
            color: themeManager.button
            opacity: 0.8
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: iconText
                font.pixelSize: 18
            }
        }

        Text {
            anchors.left: iconBg.right
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: settingText
            font.pixelSize: 15
            font.family: "Arial"
            color: themeManager.text
        }
    }

    Rectangle {
        id: mainRect
        width: parent.width
        height: parent.height
        color: themeManager.background
        radius: 15
        border.color: themeManager.border
        border.width: 1

        // Заголовок с декоративным элементом
        Rectangle {
            id: headerDecoration
            width: parent.width
            height: 60
            radius: 15
            color: themeManager.button
            anchors.top: parent.top

            // Обрезаем нижние углы
            Rectangle {
                width: parent.width
                height: parent.height / 2
                color: parent.color
                anchors.bottom: parent.bottom
            }

            Text {
                anchors.centerIn: parent
                text: qsTr("Настройки")
                font {
                    pixelSize: 26
                    bold: true
                    family: "Arial"
                }
                color: themeManager.text
            }
        }

        // Основной контент
        Column {
            id: contentColumn
            anchors {
                top: headerDecoration.bottom
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 40
            spacing: 20

            // Иконка с декоративной линией
            Item {
                width: parent.width
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    height: 2
                    width: parent.width * 0.4
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    color: themeManager.border
                    opacity: 0.6
                }

                Rectangle {
                    height: 2
                    width: parent.width * 0.4
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    color: themeManager.border
                    opacity: 0.6
                }

                Rectangle {
                    width: 26
                    height: 26
                    radius: width/2
                    color: themeManager.button
                    anchors.centerIn: parent

                    Text {
                        anchors.centerIn: parent
                        text: "⚙️"
                        font.pixelSize: 16
                    }
                }
            }

            // Настройка языка
            SettingItem {
                id: languageItem
                width: parent.width
                height: 50
                iconText: "🌐"
                settingText: qsTr("Язык")

                ComboBox {
                    id: languageComboBox
                    width: 140
                    height: 36
                    font.pixelSize: 15
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    background: Rectangle {
                        color: themeManager.inputBackground
                        radius: 8
                        border.color: languageComboBox.hovered ? themeManager.buttonHoverColor : themeManager.border
                        border.width: languageComboBox.hovered ? 2 : 1

                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }

                        Behavior on border.width {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: languageComboBox.currentText
                        font.pixelSize: 15
                        color: themeManager.inputTextColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    indicator: Text {
                        text: "▼"
                        font.pixelSize: 12
                        color: themeManager.text
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    model: ["Русский", "English"]
                    currentIndex: currentedLanguage

                    delegate: ItemDelegate {
                        width: parent.width
                        height: 36

                        background: Rectangle {
                            color: highlighted ? themeManager.button : themeManager.background
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

                    popup: Popup {
                        y: languageComboBox.height
                        width: languageComboBox.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: languageComboBox.popup.visible ? languageComboBox.delegateModel : null
                            currentIndex: languageComboBox.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: themeManager.background
                            radius: 8
                            border.color: themeManager.border
                            border.width: 1
                        }

                        enter: Transition {
                            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
                        }

                        exit: Transition {
                            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
                        }
                    }
                }
            }

            // Настройка темы
            SettingItem {
                id: themeItem
                width: parent.width
                height: 50
                iconText: "🎨"
                settingText: qsTr("Цветовая тема")

                ComboBox {
                    id: themesColor
                    width: 140
                    height: 36
                    font.pixelSize: 15
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    background: Rectangle {
                        color: themeManager.inputBackground
                        radius: 8
                        border.color: themesColor.hovered ? themeManager.buttonHoverColor : themeManager.border
                        border.width: themesColor.hovered ? 2 : 1

                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }

                        Behavior on border.width {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: themesColor.currentText
                        font.pixelSize: 15
                        color: themeManager.inputTextColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    indicator: Text {
                        text: "▼"
                        font.pixelSize: 12
                        color: themeManager.text
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    model: [qsTr("Светлая"), qsTr("Темная"), qsTr("Разноцветная"), qsTr("Акварельная"), qsTr("Нейтральная"), qsTr("Ретро")]
                    Component.onCompleted: {
                        let theme = qsTr(themeManager.theme)
                            let capitalized = theme.charAt(0).toUpperCase() + theme.slice(1)
                        console.log(capitalized);
                            let index = themesColor.find(capitalized)
                            if (index !== -1)
                                themesColor.currentIndex = index
                    }



                    delegate: ItemDelegate {
                        width: parent.width
                        height: 36

                        background: Rectangle {
                            color: highlighted ? themeManager.button : themeManager.background
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

                    popup: Popup {
                        y: themesColor.height
                        width: themesColor.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: themesColor.popup.visible ? themesColor.delegateModel : null
                            currentIndex: themesColor.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: themeManager.background
                            radius: 8
                            border.color: themeManager.border
                            border.width: 1
                        }

                        enter: Transition {
                            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
                        }

                        exit: Transition {
                            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
                        }
                    }
                }
            }

            // Настройка режима окна
            SettingItem {
                id: modeItem
                width: parent.width
                height: 50
                iconText: "🖥️"
                settingText: qsTr("Режим окна")

                ComboBox {
                    id: modeComboBox
                    width: 140
                    height: 36
                    font.pixelSize: 15
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    background: Rectangle {
                        color: themeManager.inputBackground
                        radius: 8
                        border.color: modeComboBox.hovered ? themeManager.buttonHoverColor : themeManager.border
                        border.width: modeComboBox.hovered ? 2 : 1

                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }

                        Behavior on border.width {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: modeComboBox.currentText
                        font.pixelSize: 15
                        color: themeManager.inputTextColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    indicator: Text {
                        text: "▼"
                        font.pixelSize: 12
                        color: themeManager.text
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    model: [qsTr("Оконный"), qsTr("Полноэкранный")]
                    currentIndex: 0

                    delegate: ItemDelegate {
                        width: parent.width
                        height: 36

                        background: Rectangle {
                            color: highlighted ? themeManager.button : themeManager.background
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

                    popup: Popup {
                        y: modeComboBox.height
                        width: modeComboBox.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: modeComboBox.popup.visible ? modeComboBox.delegateModel : null
                            currentIndex: modeComboBox.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: themeManager.background
                            radius: 8
                            border.color: themeManager.border
                            border.width: 1
                        }

                        enter: Transition {
                            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
                        }

                        exit: Transition {
                            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
                        }
                    }
                }
            }

            // Разделительная линия
            Rectangle {
                width: parent.width
                height: 1
                color: themeManager.border
                opacity: 0.5
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Кнопки
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 10

                // Кнопка "Применить"
                Rectangle {
                    id: applyButton
                    width: 130
                    height: 40
                    color: themeManager.button
                    radius: 10
                    border.color: themeManager.border
                    border.width: 2
                    scale: applyArea.containsMouse ? 1.05 : 1

                    // Эффект нажатия
                    states: State {
                        name: "pressed"
                        when: applyArea.pressed
                        PropertyChanges {
                            target: applyButton
                            color: themeManager.buttonHoverColor
                            scale: 0.95
                        }
                    }

                    transitions: [
                        Transition {
                            from: ""
                            to: "pressed"
                            reversible: true
                            ParallelAnimation {
                                ColorAnimation { duration: 100 }
                                NumberAnimation {
                                    properties: "scale";
                                    duration: 100;
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        },
                        Transition {
                            from: "*"
                            to: "*"
                            NumberAnimation {
                                properties: "scale";
                                duration: 150;
                                easing.type: Easing.OutBack
                            }
                        }
                    ]

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "✓"
                            font.pixelSize: 16
                            color: themeManager.text
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Применить")
                            font.pixelSize: 15
                            font.bold: true
                            color: themeManager.text
                        }
                    }

                    MouseArea {
                        id: applyArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            // Применить анимацию к кнопке
                            applyButtonAnimation.start()

                            // Логика применения настроек
                            if (themesColor.currentIndex === 0) {
                                themeManager.setTheme("light");
                            } else if (themesColor.currentIndex === 1) {
                                themeManager.setTheme("dark");
                            } else if (themesColor.currentIndex === 2) {
                                themeManager.setTheme("colorful");
                            } else if (themesColor.currentIndex === 3) {
                                themeManager.setTheme("watercolor");
                            } else if (themesColor.currentIndex === 5) {
                                themeManager.setTheme("retro");
                            } else if (themesColor.currentIndex === 4) {
                                themeManager.setTheme("neutral");
                            }

                            if(modeComboBox.currentIndex === 0) {
                                windowManager.toggleFullscreen()
                            } else if(modeComboBox.currentIndex === 1) {
                                windowManager.setFullscreen(true)
                            }

                            if(languageComboBox.currentText === "Русский") {
                                languageManager.loadLanguage("SigmaTap_ru_RU")
                            } else if(languageComboBox.currentText === "English") {
                                languageManager.loadLanguage("SigmaTap_en_US")
                            }
                            // для themesColor
                            let theme = qsTr(themeManager.theme)
                            let capitalized = theme.charAt(0).toUpperCase() + theme.slice(1)
                            console.log(capitalized);
                            let index = themesColor.find(capitalized)
                            if (index !== -1)
                                themesColor.currentIndex = index
                        }
                    }

                    // Анимация при нажатии
                    SequentialAnimation {
                        id: applyButtonAnimation
                        NumberAnimation {
                            target: applyButton
                            property: "scale"
                            to: 0.9
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: applyButton
                            property: "scale"
                            to: 1.0
                            duration: 100
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                // Кнопка "Закрыть"
                Rectangle {
                    id: closeButton
                    width: 130
                    height: 40
                    color: themeManager.button
                    radius: 10
                    border.color: themeManager.border
                    border.width: 2
                    scale: closeArea.containsMouse ? 1.05 : 1

                    // Эффект нажатия
                    states: State {
                        name: "pressed"
                        when: closeArea.pressed
                        PropertyChanges {
                            target: closeButton
                            color: themeManager.buttonHoverColor
                            scale: 0.95
                        }
                    }

                    transitions: [
                        Transition {
                            from: ""
                            to: "pressed"
                            reversible: true
                            ParallelAnimation {
                                ColorAnimation { duration: 100 }
                                NumberAnimation {
                                    properties: "scale";
                                    duration: 100;
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        },
                        Transition {
                            from: "*"
                            to: "*"
                            NumberAnimation {
                                properties: "scale";
                                duration: 150;
                                easing.type: Easing.OutBack
                            }
                        }
                    ]

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "✖"
                            font.pixelSize: 16
                            color: themeManager.text
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Закрыть")
                            font.pixelSize: 15
                            font.bold: true
                            color: themeManager.text
                        }
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.visible = false
                        }
                    }
                }
            }
        }
    }
    property int currentedLanguage: {
        if(languageManager.currentLanguage() === "SigmaTap_ru_RU") {
            return 0;
        } else if(languageManager.currentLanguage() === "SigmaTap_en_US") {
            return 1;
        }
}
}
