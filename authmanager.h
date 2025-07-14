#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QString>

class AuthManager : public QObject
{
    Q_OBJECT

public:
    explicit AuthManager(QObject *parent = nullptr);

    // Функция для регистрации пользователя
    Q_INVOKABLE bool registerUser(const QString &login, const QString &password, const QString &confirmPassword);

    // Функция для входа пользователя
    Q_INVOKABLE bool loginUser(const QString &login, const QString &password, bool isRememberMe);

public slots:
    int userID();

signals:
    // при регистрации
    void loginErrorOccurred(const QString &error);
    void passwordErrorOccurred(const QString &error);

    // при логине
    void loginError(const QString &error);

private:
    // Метод для хэширования данных (логина и пароля)
    QString hashData(const QString &data);

    QString validatePassword(const QString &password);
    QString validateLogin(const QString &login);
    int m_id;
};

#endif // AUTHMANAGER_H

