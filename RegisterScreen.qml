import QtQuick 2.15
import QtQuick.Controls 2.15
import AuthManager

// Основной фон страницы регистрации
Rectangle {
    anchors.fill: parent
    color: themeManager.background

    AuthManager {
        id: registerUser
        onLoginErrorOccurred: {
                   // Отображаем ошибку, очищаем текст и меняем placeHolderText для логина на красный
                   usernameErrorText.text = qsTr(error)
                   usernameField.border.color = "red"  // Меняем границу на красную
               }

        onPasswordErrorOccurred: {
            // Отображаем ошибку, очищаем текст и меняем placeHolderText для пароля на красный
            passwordErrorText.text = qsTr(error)
            passwordField.border.color = "red"  // Меняем границу на красную
        }
    }

    AuthLanguageSelector {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 16
            anchors.bottomMargin: 16
        }

    AuthThemeSwitch {
           anchors.right: parent.right
           anchors.top: parent.top
           anchors.rightMargin: 16
           anchors.topMargin: 16
       }

    Column {
        anchors.centerIn: parent
        spacing: 20

        // Заголовок "Регистрация"
        Text {
            id: registrationTitle
            text: qsTr("Регистрация")
            font.pixelSize: 32
            color: themeManager.text
            horizontalAlignment: Text.AlignHCenter
        }

        // Поле для имени пользователя
        TextField {
            id: usernameField
            placeholderText: qsTr("Введите имя пользователя")
            font.pixelSize: 18
            color: themeManager.inputTextColor
            placeholderTextColor: themeManager.placeHolderText
            background: Rectangle {
                color: themeManager.inputBackground
                radius: 8
            }
            padding: 10
            width: parent.width * 0.75
        }

        // Текст ошибки для имени пользователя
        Item {
            width: parent.width * 0.75
            height: 10 // Фиксированная высота для текста ошибки
            visible: usernameErrorText.text.length > 0
            Text {
                id: usernameErrorText
                text: ""
                color: "red"
                anchors.left: parent.left
            }
        }

        // Строка: поле "Придумайте пароль" + глазик справа
        Row {
            width: parent.width
            spacing: 10

            // Поле для пароля
            TextField {
                id: passwordField
                placeholderText: qsTr("Придумайте пароль")
                echoMode: TextInput.Password
                font.pixelSize: 18
                color: themeManager.inputTextColor
                placeholderTextColor: themeManager.placeHolderText
                background: Rectangle {
                    color: themeManager.inputBackground
                    radius: 8
                }
                padding: 10
                width: parent.width * 0.75 // Убираем 50 пикселей на глазик
            }

            // Кнопка-переключатель видимости пароля (перемещена справа)
            MouseArea {
                id: togglePasswordVisibility
                width: 30
                height: 30
                Rectangle {
                    id: eyeButton
                    anchors.fill: parent
                    radius: 20
                    color: themeManager.inputBackground
                    border.color: themeManager.border
                }
                Text {
                    id: eyeIcon
                    text: passwordField.echoMode === TextInput.Password ? "👁" : "🙈"
                    anchors.centerIn: parent
                    font.pixelSize: 20
                    color: themeManager.text
                }
                onClicked: {
                    let newMode = passwordField.echoMode === TextInput.Password ? TextInput.Normal : TextInput.Password
                    passwordField.echoMode = newMode
                    confirmPasswordField.echoMode = newMode
                }
            }
        }
        Item {
            width: parent.width * 0.75
            height: 10 // Фиксированная высота для текста ошибки
            visible: passwordErrorText.text.length > 0
            Text {
                id: passwordErrorText
                text: ""
                color: "red"
                anchors.left: parent.left
                visible: passwordErrorText.text.length > 0  // Показываем только если есть ошибка
            }
        }


        // Поле подтверждения пароля
        TextField {
            id: confirmPasswordField
            placeholderText: qsTr("Подтвердите пароль")
            echoMode: TextInput.Password
            font.pixelSize: 18
            color: themeManager.inputTextColor
            placeholderTextColor: themeManager.placeHolderText
            background: Rectangle {
                color: themeManager.inputBackground
                radius: 8
            }
            padding: 10
            width: parent.width * 0.75
        }

        // Кнопки: Зарегистрироваться и Вернуться
        Row {
            spacing: 20

            // Кнопка "Зарегистрироваться"
            Rectangle {
                id: registerButton
                width: 180
                height: 50
                color: themeManager.button
                radius: 8
                Text {
                    text: qsTr("Зарегистрироваться")
                    color: themeManager.text
                    font.pixelSize: 18
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = themeManager.buttonHoverColor
                    onExited: parent.color = themeManager.button
                    onClicked: {
                        if(registerUser.registerUser(usernameField.text, passwordField.text, confirmPasswordField.text)) {
                            console.log("Создан пользователь " , usernameField.text, " с паролем ", passwordField.text)
                            pageLoader.source = "LoginScreen.qml"
                        } else {
                            console.log("что-то не получилось зарегаться")
                        }
                    }
                }
            }

            // Кнопка "Вернуться"
            Rectangle {
                id: backButton
                width: 180
                height: 50
                color: themeManager.button
                radius: 8
                Text {
                    text: qsTr("Вернуться")
                    color: themeManager.text
                    font.pixelSize: 18
                    anchors.centerIn: parent
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = themeManager.buttonHoverColor
                    onExited: parent.color = themeManager.button
                    onClicked: {
                        pageLoader.source = "LoginScreen.qml"
                        console.log("Возвращаемся ко входу")
                    }
                }
            }
        }
    }
    Connections {
        target: themeManager
        function onColorsChanged() {
            registerButton.color = themeManager.button
            backButton.color = themeManager.button
        }
    }
}

