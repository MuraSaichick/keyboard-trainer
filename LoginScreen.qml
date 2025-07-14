import QtQuick 2.15
import QtQuick.Controls 2.15
import AuthManager

// Основной фон приложения
Rectangle {
    anchors.fill: parent
    color: themeManager.background

    AuthManager {
        id: loginUser
        onLoginError: {
            passwordLoginError.text = qsTr(error);

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

        // Заголовок приветствия
        Text {
            id: welcomeText
            text: qsTr("Добро пожаловать!")
            font.pixelSize: 32
            color: themeManager.text
            horizontalAlignment: Text.AlignHCenter
        }

        // Поле ввода логина
        TextField {
            id: usernameField
            placeholderText: qsTr("Введите ваш логин")
            font.pixelSize: 18
            color: themeManager.inputTextColor
            placeholderTextColor: themeManager.placeHolderText
            background: Rectangle {
                color: themeManager.inputBackground
                radius: 8
            }
            padding: 10
            width: parent.width * 0.6
        }

        Row {
            spacing: 10

            // Поле ввода пароля
            TextField {
                id: passwordField
                placeholderText: qsTr("Введите ваш пароль")
                echoMode: TextInput.Password
                font.pixelSize: 18
                color: themeManager.inputTextColor
                placeholderTextColor: themeManager.placeHolderText
                background: Rectangle {
                    color: themeManager.inputBackground
                    radius: 8
                }
                padding: 10
                width: parent.width * 0.85
            }

            // Кнопка-переключатель показа пароля
            MouseArea {
                id: togglePasswordVisibility
                width: 30
                height: 30
                Rectangle {
                    id: eyeButton
                    anchors.fill: parent
                    radius: 15
                    color: themeManager.inputBackground
                    border.color: themeManager.border
                }
                Text {
                    id: eyeIcon
                    text: passwordField.echoMode === TextInput.Password ? "👁" : "🙈"
                    anchors.centerIn: parent
                    font.pixelSize: 18
                    color: themeManager.text
                }
                onClicked: {
                    passwordField.echoMode = passwordField.echoMode === TextInput.Password
                        ? TextInput.Normal
                        : TextInput.Password
                }
            }
        }

        // Поле ошибки
        Item {
            width: parent.width * 0.75
            height: 10 // Фиксированная высота для текста ошибки
            visible: passwordLoginError.text.length > 0
            Text {
                id: passwordLoginError
                text: ""
                color: "red"
                anchors.left: parent.left
                visible: passwordLoginError.text.length > 0  // Показываем только если есть ошибка
            }
        }

        Row {
            spacing: 10
            // Кастомная галочка "Запомнить меня"
            Rectangle {
                id: rememberMeCheckBox
                width: 24
                height: 24
                radius: 4
                color: checked ? themeManager.button : themeManager.inputBackground
                border.color: themeManager.border
                border.width: 2

                property bool checked: false

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        rememberMeCheckBox.checked = !rememberMeCheckBox.checked
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            // Текст рядом с галочкой
            Text {
                id: rememberMeLabel
                text: qsTr("Запомнить меня")
                font.pixelSize: 18
                color: themeManager.text
                verticalAlignment: Text.AlignVCenter
            }
        }

        Row {
            spacing: 20

            // Кнопка входа
            Rectangle {
                id: loginButton
                width: 150
                height: 50
                color: themeManager.button
                radius: 8
                Text {
                    text: qsTr("Войти")
                    color: themeManager.text
                    font.pixelSize: 18
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = themeManager.buttonHoverColor
                    onExited: parent.color = themeManager.button
                    onClicked: {
                        if(loginUser.loginUser(usernameField.text, passwordField.text, rememberMeCheckBox.checked)) {
                            UserStats.loadFromDatabase(loginUser.userID()) // Передали ID логина для загрузки его данных
                            pageLoader.source = "MainMenu.qml"
                        } else {
                            console.log("Не получилось войти, что-то с аккаунтом")
                        }
                    }
                }
            }

            // Кнопка регистрации
            Rectangle {
                id: registerButton
                width: 180
                height: 50
                color: themeManager.button
                radius: 8
                Text {
                    text: qsTr("Регистрация")
                    color: themeManager.text
                    font.pixelSize: 18
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: registerButton.color = themeManager.buttonHoverColor
                    onExited: registerButton.color = themeManager.button
                    onClicked: {
                        pageLoader.source = "RegisterScreen.qml"
                        console.log("Переход к регистрации")
                    }
                }

            }
        }
    }
    Connections {
        target: themeManager
        function onColorsChanged() {
            registerButton.color = themeManager.button
            loginButton.color = themeManager.button
        }
    }
}
