#include "AuthManager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QCryptographicHash>
#include <QDebug>
#include <QRegularExpression>


AuthManager::AuthManager(QObject *parent)
    : QObject(parent)
{
    // Открываем базу данных, но не пытаемся создавать таблицу.
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("./Assets/database/UsersDB.db");

    if (!db.open()) {
        qCritical() << "Не удалось открыть базу данных!";
    } else {
        qDebug() << "База данных успешно открыта.";
    }
}

QString AuthManager::validatePassword(const QString &password) {
    // Минимальная длина пароля
    if (password.length() < 8) {
        return "Пароль должен быть не менее 8 символов.";
    }
    // Проверка наличия хотя бы одной цифры
    QRegularExpression re1("[0-9]");
    if (!re1.match(password).hasMatch()) {
        return "Пароль должен содержать хотя бы одну цифру.";
    }
    // Проверка наличия хотя бы одной заглавной буквы
    QRegularExpression re2("[A-Z]");
    if (!re2.match(password).hasMatch()) {
        return "Пароль должен содержать хотя бы одну заглавную букву.";
    }
    // Проверка наличия хотя бы одного специального символа
    QRegularExpression re3("[!@#$%^&*()_,.?\":{}|<>]");
    if (!re3.match(password).hasMatch()) {
        return "Пароль должен содержать хотя бы один специальный символ.";
    }

    return "";
}

QString AuthManager::validateLogin(const QString &login) {
    // Проверка на пустой логин
    if (login.trimmed().isEmpty()) {
        return "Логин не может быть пустым.";
    }
    return "";
}



QString AuthManager::hashData(const QString &data)
{
    QByteArray hash = QCryptographicHash::hash(data.toUtf8(), QCryptographicHash::Sha256);
    return QString(hash.toHex());
}

bool AuthManager::registerUser(const QString &login, const QString &password, const QString &confirmPassword)
{
    // Проверка логина
    QString loginError = validateLogin(login);
    if (!loginError.isEmpty()) {
        emit loginErrorOccurred(loginError);  // Отправляем ошибку по логину
        return false;
    }

    // Проверка пароля
    QString passwordError = validatePassword(password);
    if (!passwordError.isEmpty()) {
        emit passwordErrorOccurred(passwordError);  // Отправляем ошибку по паролю
        return false;
    }

    // Проверка совпадения паролей
    if (password != confirmPassword) {
        emit passwordErrorOccurred("Пароли не совпадают!");  // Отправляем ошибку по паролю
        return false;
    }

    QSqlDatabase db = QSqlDatabase::database();
    QSqlQuery query;

    // Хэшируем пароль
    QString hashedPassword = hashData(password);

    qDebug() << "Хэшированный пароль:" << hashedPassword;


    // Добавляем нового пользователя с хэшированным логином и паролем
    query.prepare("INSERT INTO users (login, password) VALUES (?, ?)"); // Используем позиционные параметры
    query.addBindValue(login);
    query.addBindValue(hashedPassword);

    if (!query.exec()) {
        qCritical() << "Ошибка регистрации пользователя:" << query.lastError();
        return false;
    }

    qDebug() << "Пользователь успешно зарегистрирован!";
    return true;
}

bool AuthManager::loginUser(const QString &login, const QString &password, bool isRememberMe)
{
    QSqlDatabase db = QSqlDatabase::database();
    QSqlQuery query;

    // Хэшируем пароль
    QString hashedPassword = hashData(password);

    // Проверяем, существует ли такой логин и пароль
    query.prepare("SELECT id FROM users WHERE login = :login AND password = :password;");
    query.bindValue(":login", login);
    query.bindValue(":password", hashedPassword);
    if (!query.exec() || !query.next()) {
        qWarning() << "Пользователь с таким логином не найден!";
        emit loginError("Неверный логин или пароль");
        return false;
    }

    // Получаем хэшированный пароль из базы данных
    m_id = query.value(0).toInt();

    qDebug() << "Значение ID: " << m_id;
    qDebug() << "Успешный вход!";
    // Если "Запомнить меня" активировано, сохраняем сессию
    if (isRememberMe) {
        // Добавляем сессию в таблицу user_sessions
        QSqlQuery sessionQuery;

        if (!sessionQuery.exec("DELETE FROM user_sessions")) {
            qDebug() << "Ошибка при удалении всех сессий:" << sessionQuery.lastError().text();
        } else {
            qDebug() << "Все сессии успешно удалены";
        }

        sessionQuery.prepare("INSERT INTO user_sessions (user_id) VALUES (:user_id)");
        sessionQuery.bindValue(":user_id", m_id);

        if (!sessionQuery.exec()) {
            qCritical() << "Ошибка добавления сессии:" << sessionQuery.lastError();
            return false;
        }

        qDebug() << "Сессия пользователя сохранена!";
    }
    return true;
}

int AuthManager::userID()
{
    return m_id;
}
