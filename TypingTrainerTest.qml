import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import RandText
import KeyboardHandler
import TimeTracker

Rectangle {
    id: root
    anchors.fill: parent
    onWidthChanged: {
        handler.setTextWidth(textArea.width);
    }

    color: themeManager.background
    property string typeTest: "words"
    property int testDetail: sizeWords.value
    property bool firstClick: true
    property var fontSizes: [40, 45, 50, 55, 60, 65, 70]
    property int currentIndexFontSizes: 0
    onCurrentIndexFontSizesChanged: {
            handler.setFontSize(fontSizes[currentIndexFontSizes]);
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
    signal finishedTest(var speedList, int elapsedTime, double accuracy, string typeTest, int testDetail, string languageTest, int keyCount)

    SettingsButton {
        id: settingsButton
    }

    // Логотип SigmaTap
    AppName {
        id: appName
    }

    RandText {
        id: randomText

        onTextChanged: function(newText) {
            timeTracker.reset()
            textArea.text = newText
            handler.setOriginalString(newText)
            handler.setModifiedString(newText)
            handler.setFontFamily(textArea.font.family)
            handler.setFontSize(textArea.font.pixelSize)
            handler.setPosition(0, textArea.font.letterSpacing * 2)
            handler.startPositionLater()
            handler.setTextWidth(textArea.width)
            handler.setEnteredWords(0);
            customCursor.y = textArea.lineHeight
            counter.timer = root.testDetail
            flicableForTextArea.contentY = 0
            eventKeyPress.forceActiveFocus()
            timeTracker.setIsTimer(time.isSelected || texts.isSelected)
            root.firstClick = true
        }
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
           onEnteredWordsChanged: function() {
               counter.count = getEnteredWords();
           }
           onTextEntryCompleted: function() {
               console.log("отправляем сигнал")
               finishedTest(timeTracker.getListSpeed(), timeTracker.getTime(), handler.getPressAccuracy(), root.typeTest, root.testDetail ,selectLanguage.activeLanguage, handler.getCorrectKeyCount());
           }
       }

    TimeTracker {
        id: timeTracker
        onTimeChanged: function(newTime) {
            counter.timer = newTime
        }
        onTimerFinished: function() {
            finishedTest(timeTracker.getListSpeed(), root.testDetail, handler.getPressAccuracy(), root.typeTest,root.testDetail, selectLanguage.activeLanguage, handler.getCorrectKeyCount());
        }
        Component.onCompleted: {
            timeTracker.setKeyboardHandler(handler.self());
        }
    }

    Rectangle {
        id: selectLanguage
        // Используем Layout для определения размера
        property string activeLanguage: "ru" // По умолчанию русский

        opacity: root.firstClick ? 1 : 0

        Behavior on opacity {
                    NumberAnimation {
                        duration: 300 // 1 секунда
                        easing.type: Easing.InOutQuad
                    }
                }

        width: rowSelectLanguage.width + 20 // Добавляем отступы по краям
        height: rowSelectLanguage.height + 10 // Добавляем отступы по вертикали
        radius: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        color: themeManager.figure
        border.color: themeManager.border
        border.width: 2

        Row {
            id: rowSelectLanguage
            anchors.centerIn: parent
            spacing: 0
            // Размер Row определяется размерами дочерних элементов

            // Вычисляем максимальную ширину для обеих кнопок
            property int maxButtonWidth: Math.max(textRUS.width, textENG.width) + 30
            property int buttonHeight: Math.max(textRUS.height, textENG.height) + 20

            // Русский
            Rectangle {
                id: buttonRUS
                property bool isHighlighted: selectLanguage.activeLanguage === "ru"
                width: rowSelectLanguage.maxButtonWidth
                height: rowSelectLanguage.buttonHeight
                color: "transparent"
                radius: 8

                Rectangle {
                    id: buttonRUSBackground
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 7
                    color: buttonRUS.isHighlighted ? themeManager.highlight : "transparent"

                    // Анимация при изменении состояния
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                Text {
                    id: textRUS
                    anchors.centerIn: parent
                    color: buttonRUS.isHighlighted ? themeManager.highlightedText : themeManager.text
                    text: qsTr("Русский")
                    font.pixelSize: 16

                    // Анимация при изменении цвета текста
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectLanguage.activeLanguage = "ru"
                        startTest()
                    }
                }
            }

            // Разделитель между кнопками
            Rectangle {
                width: 1
                height: Math.min(buttonRUS.height, buttonENG.height) - 6
                anchors.verticalCenter: parent.verticalCenter
                color: themeManager.border
                opacity: 0.7
            }

            // Английский
            Rectangle {
                id: buttonENG
                property bool isHighlighted: selectLanguage.activeLanguage === "en"
                width: rowSelectLanguage.maxButtonWidth
                height: rowSelectLanguage.buttonHeight
                color: "transparent"
                radius: 8

                Rectangle {
                    id: buttonENGBackground
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 7
                    color: buttonENG.isHighlighted ? themeManager.highlight : "transparent"

                    // Анимация при изменении состояния
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                Text {
                    id: textENG
                    anchors.centerIn: parent
                    color: buttonENG.isHighlighted ? themeManager.highlightedText : themeManager.text
                    text: qsTr("Английский")
                    font.pixelSize: 16

                    // Анимация при изменении цвета текста
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectLanguage.activeLanguage = "en"
                        startTest()
                    }
                }
            }
        }
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
                text: "Назад"
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

        Item {
            id: itemBoardForButtons
            height: 40
            width: rowButtons.width + 20
            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        // Для кнопок
        Rectangle {
            id: panelButtons
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
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10


                // Кнопка уменьшения шрифта
                Rectangle {
                    id: decreaseFontButton
                    width: 30
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
                    width: 30 // Относительный размер с ограничением
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
                    width: 30 // Относительный размер с ограничением
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
                            root.currentIndexFamily = (root.currentIndexFamily + 1) % root.fonts.length
                        }
                    }
                }

                // Разделительная линия
                Rectangle {
                    width: 5 // Ширина линии
                    height: rowButtons.height * 0.8 // Высота линии
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !texts.isSelected
                    radius: 2
                    color: themeManager.border // Цвет линии
                }

                // Кнопка с пунктуацией
                Rectangle {
                    id: punctuation
                    width: punctuationText.width + 20 // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    visible: !texts.isSelected
                    // Добавляем свойство для отслеживания состояния выделения
                    property bool isHighlighted: false

                    Text {
                        id: punctuationText
                        anchors.centerIn: parent
                        text: qsTr("Пунктуация")
                        font.pixelSize: parent.height / 2
                        // Можно также менять цвет текста при выделении для лучшего контраста
                        color: themeManager.text
                        font.bold: parent.isHighlighted
                    }

                    // Для выделения
                    Rectangle {
                        id: punctuationUnderline
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
                            // Переключаем состояние выделения при каждом клике
                            punctuation.isHighlighted = !punctuation.isHighlighted
                            console.log("Кнопка " + (punctuation.isHighlighted ? "выделена" : "не выделена"))
                            startTest();
                        }
                    }
                }

                // Кнопка для Цифр
                Rectangle {
                    id: numbers
                    width: numbersText.width + 20 // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    visible: !texts.isSelected
                    property bool isHighlighted: false

                    Text {
                        id: numbersText
                        anchors.centerIn: parent
                        text: qsTr("Числа")
                        font.pixelSize: parent.height / 2
                        color: themeManager.text
                        font.bold: parent.isHighlighted
                    }

                    // Для выделения
                    Rectangle {
                        id: numbersUnderline
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
                            numbers.isHighlighted = !numbers.isHighlighted
                            console.log("Кнопка Числа нажата")
                            startTest();
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

                // Кнопка "Время"
                Rectangle {
                    id: time
                    width: timeText.width + 20 // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    property bool isSelected: false // Свойство для отслеживания выбранного состояния

                    // Добавляем подчеркивание для визуального выделения
                    Rectangle {
                        id: timeUnderline
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: themeManager.text // Цвет подчеркивания как у текста
                        opacity: time.isSelected ? 1 : 0 // Видимо только когда выбрано
                    }

                    Text {
                        id: timeText
                        anchors.centerIn: parent
                        text: qsTr("Время")
                        font.pixelSize: parent.height / 2
                        color: themeManager.text // Цвет текста
                        font.bold: time.isSelected // Жирный текст при выделении
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            console.log("Кнопка Время нажата")
                            sizeWords.visible = false
                            sizeTime.visible = true
                            texts.isSelected = false
                            words.isSelected = false
                            time.isSelected = true // Устанавливаем флаг выделения при нажатии
                            counter.timer = sizeTime.value
                            root.typeTest = "time"
                            root.testDetail = sizeTime.value
                            startTest();
                        }
                    }
                }

                // кнопка "Слова"
                Rectangle {
                    id: words
                    width: wordsText.width + 20 // Относительный размер с ограничением
                    height: 30
                    radius: 5
                    color: "transparent"
                    property bool isSelected: true // Свойство для отслеживания выбранного состояния

                    // Добавляем подчеркивание для визуального выделения
                    Rectangle {
                        id: underline
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: themeManager.text // Цвет подчеркивания как у текста
                        opacity: words.isSelected ? 1 : 0 // Видимо только когда выбрано
                    }

                    Text {
                        id: wordsText
                        anchors.centerIn: parent
                        text: qsTr("Слова")
                        font.pixelSize: parent.height / 2
                        color: themeManager.text // Цвет текста
                        font.bold: words.isSelected // Жирный текст при выделении
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            console.log("Кнопка Слова нажата")
                            sizeTime.visible = false
                            sizeWords.visible = true
                            texts.isSelected = false
                            time.isSelected = false
                            words.isSelected = true
                            root.typeTest = "words"
                            root.testDetail = sizeWords.value
                            startTest();
                        }
                    }
                }

                // Кнопка для текстов
                Rectangle {
                    id: texts
                    width: textsText.width + 20
                    height: 30
                    radius: 5
                    color: "transparent"
                    property bool isSelected: false // Свойство для отслеживания выбранного состояния

                    // Добавляем подчеркивание для визуального выделения
                    Rectangle {
                        id: quotesUnderline
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 2
                        color: themeManager.text // Цвет подчеркивания как у текста
                        opacity: texts.isSelected ? 1 : 0 // Видимо только когда выбрано
                    }

                    Text {
                        id: textsText
                        anchors.centerIn: parent
                        text: qsTr("Текст")
                        font.pixelSize: parent.height / 2
                        color: themeManager.text // Цвет текста
                        font.bold: texts.isSelected // Жирный текст при выделении
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = themeManager.highlight
                        onReleased: parent.color = "transparent"
                        hoverEnabled: true
                        onEntered: parent.color = themeManager.buttonHoverColor
                        onExited: parent.color = "transparent"
                        onClicked: {
                            console.log("Кнопка Цитаты нажата")
                            sizeWords.visible = false
                            sizeTime.visible = false
                            words.isSelected = false // Снимаем выделение с других кнопок
                            time.isSelected = false
                            texts.isSelected = true // Устанавливаем флаг выделения при нажатии
                            root.typeTest = "text"
                            root.testDetail = sizeTexts.value
                            counter.timer = sizeTexts.value
                            startTest();
                        }
                    }
                }

                // разделительная линия
                Rectangle {
                    width: 5 // Ширина линии
                    height: rowButtons.height * 0.8 // Высота линии
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: themeManager.border // Цвет линии
                }

                // количество слов
                Row {
                    id: sizeWords

                    spacing: 8 // Увеличиваем расстояние между кнопками
                    visible: true
                    property int value: 10

                    Rectangle {
                        id: ten
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: true
                        Text {
                            anchors.centerIn: parent
                            text: "10"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }

                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeWords.value = 10
                                twentyFive.isSelected = false
                                fifty.isSelected = false
                                oneHundred.isSelected = false
                                ten.isSelected = true
                                console.log("Кнопка 10 нажата")
                                root.typeTest = "words"
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: twentyFive
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false
                        Text {
                            anchors.centerIn: parent
                            text: "25"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                        }
                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeWords.value = 25
                                fifty.isSelected = false
                                oneHundred.isSelected = false
                                ten.isSelected = false
                                twentyFive.isSelected = true
                                console.log("Кнопка 25 нажата")
                                root.typeTest = "words"
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: fifty
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false
                        Text {
                            anchors.centerIn: parent
                            text: "50"  // Исправлено с "10" на "50"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                        }
                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeWords.value = 50
                                oneHundred.isSelected = false
                                ten.isSelected = false
                                twentyFive.isSelected =false
                                fifty.isSelected = true
                                console.log("Кнопка 50 нажата")
                                root.typeTest = "words"
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: oneHundred
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false

                        Text {
                            anchors.centerIn: parent
                            text: "100"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                        }
                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeWords.value = 100
                                ten.isSelected = false
                                twentyFive.isSelected =false
                                fifty.isSelected = false
                                oneHundred.isSelected = true
                                console.log("Кнопка 100 нажата")
                                root.typeTest = "words"
                                startTest();
                            }
                        }
                    }
                }

                Row {
                    id: sizeTime
                    spacing: 8
                    visible: false
                    property int value: 15
                    onValueChanged: {
                        root.testDetail = value
                    }

                    Rectangle {
                        id: fifteen
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: true

                        Text {
                            anchors.centerIn: parent
                            text: "15"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeTime.value = 15
                                thirty.isSelected = false
                                oneMinute.isSelected = false
                                twoMinute.isSelected = false
                                fifteen.isSelected = true
                                console.log("Кнопка 15 нажата")
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: thirty
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false

                        Text {
                            anchors.centerIn: parent
                            text: "30"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked:{
                                sizeTime.value = 30
                                oneMinute.isSelected = false
                                twoMinute.isSelected = false
                                fifteen.isSelected = false
                                thirty.isSelected = true
                                console.log("Кнопка 30 нажата")
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: oneMinute
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false

                        Text {
                            anchors.centerIn: parent
                            text: "60"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked:{
                                sizeTime.value = 60
                                thirty.isSelected = false
                                twoMinute.isSelected = false
                                fifteen.isSelected = false
                                oneMinute.isSelected = true
                                console.log("Кнопка 60 нажата")
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: twoMinute
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false

                        Text {
                            anchors.centerIn: parent
                            text: "120"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        // Добавляем подчеркивание для визуального выделения
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text // Цвет подчеркивания как у текста
                            opacity: parent.isSelected ? 1 : 0 // Видимо только когда выбрано
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked:{
                                sizeTime.value = 120
                                thirty.isSelected = false
                                oneMinute.isSelected = false
                                fifteen.isSelected = false
                                twoMinute.isSelected = true
                                console.log("Кнопка 120 нажата")
                                startTest();
                            }
                        }
                    }
                }
                Row {
                    id: sizeTexts
                    spacing: 8
                    visible: texts.isSelected
                    property int value: 60
                    onValueChanged: {
                        root.testDetail = value
                    }

                    Rectangle {
                        id: sixty
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: true

                        Text {
                            anchors.centerIn: parent
                            text: "60"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text
                            opacity: parent.isSelected ? 1 : 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeTexts.value = 60
                                oneTwenty.isSelected = false
                                oneEighty.isSelected = false
                                threeHundred.isSelected = false
                                sixty.isSelected = true
                                console.log("Кнопка 60 нажата")
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: oneTwenty
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false

                        Text {
                            anchors.centerIn: parent
                            text: "120"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text
                            opacity: parent.isSelected ? 1 : 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeTexts.value = 120
                                sixty.isSelected = false
                                oneEighty.isSelected = false
                                threeHundred.isSelected = false
                                oneTwenty.isSelected = true
                                console.log("Кнопка 120 нажата")
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: oneEighty
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false

                        Text {
                            anchors.centerIn: parent
                            text: "180"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text
                            opacity: parent.isSelected ? 1 : 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeTexts.value = 180
                                sixty.isSelected = false
                                oneTwenty.isSelected = false
                                threeHundred.isSelected = false
                                oneEighty.isSelected = true
                                console.log("Кнопка 180 нажата")
                                startTest();
                            }
                        }
                    }

                    Rectangle {
                        id: threeHundred
                        width: 30
                        height: 30
                        radius: 5
                        color: "transparent"
                        property bool isSelected: false

                        Text {
                            anchors.centerIn: parent
                            text: "300"
                            font.pixelSize: parent.height / 2
                            color: themeManager.text
                            font.bold: parent.isSelected
                        }
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            color: themeManager.text
                            opacity: parent.isSelected ? 1 : 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: parent.color = themeManager.highlight
                            onReleased: parent.color = "transparent"
                            hoverEnabled: true
                            onEntered: parent.color = themeManager.buttonHoverColor
                            onExited: parent.color = "transparent"
                            onClicked: {
                                sizeTexts.value = 300
                                sixty.isSelected = false
                                oneTwenty.isSelected = false
                                oneEighty.isSelected = false
                                threeHundred.isSelected = true
                                console.log("Кнопка 300 нажата, value: ", sizeTexts.value, "counter.timer: ", counter.timer)
                                startTest();
                            }
                        }
                    }
                }
            }
        }
        }

        Flickable {
            id: flicableForTextArea
            // Прикрепляем Flickable к границам прямоугольника
            width: root.width * 0.8
            height: root.height * 0.3

            // Добавляем отступы для текста
            anchors.margins: 10

            // Ограничиваем прокрутку только по вертикали
            flickableDirection: Flickable.VerticalFlick

            // Содержимое, которое может прокручиваться
            contentWidth: width
            contentHeight: textArea.contentHeight

            // Отключаем эффект отскока при прокрутке
            boundsBehavior: Flickable.StopAtBounds
            interactive: false

            // Отключаем перетаскивание за границы
            clip: true

            Text {
                id: textArea
                width: parent.width
                wrapMode: Text.WordWrap
                textFormat: Text.RichText

                // Настройки текста с использованием themeManager
                color: Qt.alpha(themeManager.inputTextColor, 0.7)
                font.pixelSize: root.fontSizes[root.currentIndexFontSizes]
                font.letterSpacing: 5
                font.kerning: false

                font.family: root.fonts[currentIndexFamily];
                text: startTest()
            }
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
                        startTest();
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
        property int count
        property int timer: sizeTime.value
        Text {
            id: counterText
            color: Qt.alpha(themeManager.text, 0.5)
            anchors.centerIn: parent
            font.pixelSize: 20
            text: words.isSelected ? counter.count + " / " + sizeWords.value : counter.timer
        }
    }

    Setting {
        id: settingsWindow
    }

    function startTest() {

        randomText.startTest(root.typeTest, selectLanguage.activeLanguage, sizeWords.value, sizeTime.value, punctuation.isHighlighted, numbers.isHighlighted);
        console.log("Тест начался!");
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
                console.log("Кнопка нажата:", event.key, "кнопка:", event.text);
                if (event.text.length === 1 ) {
                    timeTracker.start(words.isSelected ? 0 : root.testDetail);
                    handler.inputCharacter(event.text);
                    if(root.firstClick) {
                        root.firstClick = false;
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        startTest();
    }
}
