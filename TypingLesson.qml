import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import RandText
import KeyboardHandler
import TimeTracker
import LessonManager

Rectangle {
    id: root
    anchors.fill: parent
    onWidthChanged: {
        handler.setTextWidth(textArea.width);
    }

    color: themeManager.background
    property string language
    property string lessonText
    property int lessonId
    property var keyItems: []
    property var currentKeyItem: null
    property bool firstClick: true
    property var fontSizes: [40, 45, 50, 55, 60, 65, 70]
    property int currentIndexFontSizes: 0
    onCurrentIndexFontSizesChanged: {
        handler.setFontSize(fontSizes[currentIndexFontSizes]);
    }
    onLessonIdChanged: {
        console.log("Получили текст:", root.lessonText)
        textArea.text = lessonManager.getLessonText(root.lessonId, root.language)
        handler.setOriginalString(textArea.text)
        handler.setModifiedString(textArea.text)
        handler.setFontFamily(textArea.font.family)
        handler.setFontSize(fontSizes[currentIndexFontSizes])
        handler.setPosition(0, textArea.font.letterSpacing * 2)
        handler.startPositionLater()
        handler.setTextWidth(root.width * 0.8)
        handler.setEnteredWords(0)
        handler.setIsVertical(toggleButton.isVertical);
        console.log("Успешно передали текст в handler")
    }

    property var fonts: [
        "monospace",
        "Arial",
        "Times New Roman",
        "Courier New",
        "Georgia",
        "Comic Sans MS",
        "Verdana"
    ]
    property int currentIndexFamily: 0
    onCurrentIndexFamilyChanged: {
        handler.setFontFamily(fonts[currentIndexFamily])
    }
    onLessonTextChanged: {
        console.log("Получили текст:", root.lessonText)
        textArea.text = root.lessonText
        handler.setOriginalString(root.lessonText)
        handler.setModifiedString(root.lessonText)
        handler.setFontFamily(textArea.font.family)
        handler.setFontSize(fontSizes[currentIndexFontSizes])
        handler.setPosition(0, textArea.font.letterSpacing * 2)
        handler.startPositionLater()
        handler.setTextWidth(root.width * 0.8)
        handler.setEnteredWords(0)
        handler.setIsVertical(toggleButton.isVertical);
        console.log("Успешно передали текст в handler")
    }

    signal finishedLesson(var speedList, int elapsedTime, double accuracy, int lessonId, string language, int keyCount);

    SettingsButton {
        id: settingsButton
    }

    // Логотип SigmaTap
    AppName {
        id: appName
    }

    KeyboardHandler {
        id: handler
        onTextChanged: function() {
            textArea.text = getModifiedString()
        }
        onCursorChanged: function(x) {
            customCursor.x = x
        }
        onScrollChanged: function() {
            //flicableForTextArea.contentY += textArea.lineHeight * 5 + textArea.font.pixelSize
            //customCursor.y += textArea.lineHeight * 5 + textArea.font.pixelSize

            let offset = handler.getLineSpacingText();
            flicableForTextArea.contentY += offset + 1
            customCursor.y += offset + 1
        }
        onTextEntryCompleted: function() {
            console.log("отправляем сигнал")
            finishedLesson(timeTracker.getListSpeed(), timeTracker.getTime(), handler.getPressAccuracy(), root.lessonId, root.language, handler.getCorrectKeyCount());
        }
        onScrollHorizontalRequested: function(offset) {
            console.log("меняем горизонтально на 1 букву");
            flicableForTextArea.contentX = offset
        }
    }

    TimeTracker {
        id: timeTracker
        onTimeChanged: function(newTime) {
            counter.count = newTime
        }
        Component.onCompleted: {
            timeTracker.setKeyboardHandler(handler.self());
        }
    }

    LessonManager {
        id: lessonManager
    }

    // Кнопка назад
    Rectangle {
        id: backButton
        width: 120
        height: 40
        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 20
        }
        color: "transparent"
        radius: 5

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        layer.enabled: true

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "←"
                font.pixelSize: 28
                font.bold: true
                color: themeManager.text
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Назад")
                font.pixelSize: 25
                color: themeManager.text
            }
        }

        MouseArea {
            id: backMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                pageLoader.source = "MainMenu.qml"
            }
        }
    }


    // Текстовое поле и кнопки
    Column {
        id: columnButtonsText
        anchors.centerIn: parent
        spacing: 30

        // Для кнопок
        Item {
            id: itemBoardForButtons
            height: 40
            width: rowButtons.width + 10
            anchors.horizontalCenter: parent.horizontalCenter
        Rectangle {
            id: boardForButtons
            anchors.fill: parent
            color: Qt.alpha(themeManager.figure, 0.7)
            border.color: themeManager.border
            border.width: 1
            radius: 10
            opacity: root.firstClick ? 1 : 0

            Behavior on opacity {
                        NumberAnimation {
                            duration: 300 // 1 секунда
                            easing.type: Easing.InOutQuad
                        }
                    }

            // Для текста
            Row {
                id: rowButtons
                spacing: 10
                anchors.centerIn: parent
                // Кнопка уменьшения шрифта
                Rectangle {
                    id: decreaseFontButton
                    width: Math.min(45, parent.width * 0.05) // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "A-"
                        color: themeManager.text
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            if(root.currentIndexFontSizes !== 0) {
                                root.currentIndexFontSizes--;
                            }
                        }
                    }
                }

                // Кнопка увеличения шрифта
                Rectangle {
                    id: increaseFontButton
                    width: Math.min(45, parent.width * 0.05) // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "A+"
                        color: themeManager.text
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            if(root.currentIndexFontSizes != 6) {
                                root.currentIndexFontSizes++;
                            }
                        }

                    }
                }

                // Кнопка изменения типа шрифта
                Rectangle {
                    id: fontTypeButton
                    width: Math.min(45, parent.width * 0.05) // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "Aa"
                        color: themeManager.text
                        font.bold: true
                        font.italic: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            handler.setFontFamily(textArea.font.family)
                            root.currentIndexFamily = (root.currentIndexFamily + 1) % root.fonts.length
                        }
                    }
                }

                // Разделительная линия
                Rectangle {
                    width: 5 // Ширина линии
                    height: rowButtons.height * 0.8 // Высота линии
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: themeManager.border // Цвет линии
                }
                // Кнопка для Клавиатуры
                Rectangle {
                    id: keyboardButton
                    width: keyboardButtonText.width + 10 // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    property bool isHighlighted: true

                    Text {
                        id: keyboardButtonText
                        anchors.centerIn: parent
                        text: qsTr("Клавиатура")
                        font.pixelSize: parent.height / 2
                        color: themeManager.text
                        font.bold: parent.isHighlighted
                    }

                    // Для выделения
                    Rectangle {
                        id: keyboardButtonUnderline
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: themeManager.text // Цвет подчеркивания как у текста
                        opacity: parent.isHighlighted ? 1 : 0 // Видимо только когда выбрано
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            keyboardButton.isHighlighted = !keyboardButton.isHighlighted
                            console.log("Кнопка Клавиатура нажата")
                        }
                    }
                }

                // Разделительная линия
                Rectangle {
                    width: 5 // Ширина линии
                    height: rowButtons.height * 0.8 // Высота линии
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: themeManager.border // Цвет линии
                }
                // Вид текста
                Rectangle {
                    id: toggleButton
                    property bool isVertical: false
                    width: toggleButtonText.width + 10
                    height: 30
                    color: "transparent"
                    radius: 8
                    // Реакция на клик
                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            toggleButton.isVertical = !toggleButton.isVertical
                            handler.setIsVertical(toggleButton.isVertical)
                        }
                    }

                    // Текст внутри кнопки
                    Text {
                        id: toggleButtonText
                        anchors.centerIn: parent
                        text: toggleButton.isVertical ? "↔ " + qsTr("Переключить на горизонталь") : "↕ " + qsTr("Переключить на вертикаль")
                        color: themeManager.text
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }
        }
        }
        Flickable {
            id: flicableForTextArea

            // Ширина и высота меняются в зависимости от ориентации
            width: root.width * 0.8
            height: toggleButton.isVertical ? root.height * 0.3 : textArea.height + 10
            anchors.margins: 10

            // Направление прокрутки
            flickableDirection: toggleButton.isVertical ? Flickable.VerticalFlick : Flickable.HorizontalFlick

            // Контентные размеры
            contentWidth: width
            contentHeight: toggleButton.isVertical ? textArea.height : height

            boundsBehavior: Flickable.StopAtBounds
            interactive: true
            clip: true
            Behavior on contentX {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
            Text {
                id: textArea

                width: parent.width
                height: toggleButton.isVertical ? parent.height : font.pixelSize

                wrapMode: toggleButton.isVertical ? Text.WordWrap : Text.NoWrap
                textFormat: Text.RichText
                x: toggleButton.isVertical ? 0 : parent.width - width / 3
                color: Qt.alpha(themeManager.inputTextColor, 0.7)
                font.pixelSize: root.fontSizes[root.currentIndexFontSizes]
                font.letterSpacing: 5
                font.kerning: false
                font.family: root.fonts[currentIndexFamily]
                text: root.lessonText

                // Кастомный курсор
                    Rectangle {
                        id: customCursor
                        width: 2
                        height: textArea.font.pixelSize
                        color: themeManager.text
                        visible: true

                        // Позиционируем в конец текста
                        x:0
                        y: textArea.lineHeight

                        // Мигание курсора
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: root.firstClick
                            NumberAnimation { from: 1; to: 0; duration: 500 }
                            NumberAnimation { from: 0; to: 1; duration: 500 }
                        }
                        Behavior on x {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
            }
        }
        // Клавиатура
        Rectangle {
            id: keyboard
            width: 725
            height: 250
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            border.color: themeManager.border
            border.width: 1
            radius: 10
            visible: keyboardButton.isHighlighted

            property var keys: root.language == "ru" ? [
                                                           ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BackSpace"],
                                                           ["Tab", "й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "ъ", "\\"],
                                                           ["CapsLock", "ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э", "Enter"],
                                                           ["Shift", "я", "ч", "с", "м", "и", "т", "ь", "б", "ю", ".", "Shift"],
                                                           ["Ctrl", "Fn", "Win", "Alt", "Space", "Alt", "Ctrl"]
                                                       ] : [
                                                           ["ё", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BackSpace"],
                                                           ["Tab", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]", "\\"],
                                                           ["CapsLock", "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'", "Enter"],
                                                           ["Shift", "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "Shift"],
                                                           ["Ctrl", "Fn", "Win", "Alt", "Space", "Alt", "Ctrl"]
                                                       ]

            Column {
                spacing: 10
                anchors.centerIn: parent

                Repeater {
                    model: keyboard.keys
                    Row {
                        spacing: 6
                        Repeater {
                            model: modelData
                            Item {
                                property string keyLabel: modelData

                                function highlight() {
                                    keyRect.color = themeManager.highlight
                                }

                                function unhighlight() {
                                    keyRect.color = themeManager.figure
                                }

                                Component.onCompleted: {
                                    root.keyItems.push(this)
                                }

                                width: {
                                    if (keyLabel === "BackSpace" || keyLabel === "CapsLock" || keyLabel === "Enter" || keyLabel === "Shift")
                                        return 100;
                                    else if (keyLabel === "Tab")
                                        return 60;
                                    else if (keyLabel === "Space")
                                        return 300;
                                    else if (keyLabel === "Ctrl" || keyLabel === "Alt" || keyLabel === "Win" || keyLabel === "Fn")
                                        return 50;
                                    else
                                        return height;
                                }
                                height: 40

                                Rectangle {
                                    id: keyRect
                                    anchors.fill: parent
                                    color: themeManager.figure
                                    border.color: themeManager.border
                                    border.width: 1
                                    radius: 5

                                    Text {
                                        text: keyLabel
                                        anchors.centerIn: parent
                                        font.pixelSize: 20
                                        color: themeManager.text
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("Key clicked:", keyLabel)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        Item {
                id: reloadButton
                width: 40
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: icon
                    text: "⟲"
                    anchors.centerIn: parent
                    font.pixelSize: 28
                    color: themeManager.text
                    opacity: 1.0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.firstClick = true;
                        restart();
                    }
                }
            }
    }
    Rectangle {
        id: counter
        width: counterText.width + 10
        height: counterText.height + 10
        anchors.top: columnButtonsText.top
        anchors.right: columnButtonsText.left
        anchors.topMargin: rowButtons.height + columnButtonsText.spacing / 2
        anchors.leftMargin: 5
        color: "transparent"
        property int count: 0
        Text {
            id: counterText
            color: Qt.alpha(themeManager.text, 0.5)
            anchors.centerIn: parent
            font.pixelSize: 20
            text: counter.count
        }
    }

    Setting {
        id: settingsWindow
    }

    // Отслеживание нажатий клавиш
    Item {
        id: eventKeyPress
        anchors.fill: parent
        Component.onCompleted: forceActiveFocus()
        Keys.onPressed: function(event) {
            const ignoredKeys = [
                                  Qt.Key_Shift, Qt.Key_Control, Qt.Key_Alt, Qt.Key_Meta, Qt.Key_Tab,
                                  Qt.Key_CapsLock, Qt.Key_NumLock, Qt.Key_ScrollLock, Qt.Key_Super_L, Qt.Key_Super_R,
                                  Qt.Key_Menu, Qt.Key_Hyper_L, Qt.Key_Hyper_R, Qt.Key_Insert, Qt.Key_Home,
                                  Qt.Key_End, Qt.Key_PageUp, Qt.Key_PageDown, Qt.Key_F1, Qt.Key_F2, Qt.Key_F3,
                                  Qt.Key_F4, Qt.Key_F5, Qt.Key_F6, Qt.Key_F7, Qt.Key_F8, Qt.Key_F9, Qt.Key_F10,
                                  Qt.Key_F11, Qt.Key_F12
                              ];

            if (ignoredKeys.indexOf(event.key) === -1) {
                console.log("Key нажата:", event.key, "буква:", event.text);
                if (event.text.length === 1) {
                    timeTracker.start(0);
                    handler.inputCharacter(event.text);
                    if (root.firstClick) {
                        root.firstClick = false;
                    }

                    let key = event.text.toLowerCase();
                    for (let i = 0; i < keyItems.length; i++) {
                        if (keyItems[i].keyLabel === key) {
                            if (root.currentKeyItem && root.currentKeyItem !== keyItems[i]) {
                                root.currentKeyItem.unhighlight();
                            }
                            keyItems[i].highlight();
                            root.currentKeyItem = keyItems[i];
                            break;
                        }
                    }
                }
            }
        }
    }
    function restart() {
        textArea.text = lessonManager.getLessonText(root.lessonId, root.language)
        handler.setOriginalString(textArea.text)
        handler.setModifiedString(textArea.text)
        handler.setFontFamily(textArea.font.family)
        handler.setFontSize(fontSizes[currentIndexFontSizes])
        handler.setPosition(0, textArea.font.letterSpacing * 2)
        handler.startPositionLater()
        handler.setTextWidth(root.width * 0.8)
        handler.setEnteredWords(0)
        handler.setIsVertical(toggleButton.isVertical);
        timeTracker.reset();
        flicableForTextArea.contentX = 0;
        customCursor.x = 0;
    }
}
