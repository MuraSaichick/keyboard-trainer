#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>

#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QSqlDatabase>
#include <QCryptographicHash>
class UserStatsManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(int userId READ userId NOTIFY userIdChanged)
    Q_PROPERTY(QString login READ login NOTIFY loginChanged)

public:
    explicit UserStatsManager(QObject* parent = nullptr);

    Q_INVOKABLE void saveTestResult(const QString& testType,
                                    const QString& language,
                                    const QString& testDetail,
                                    double speed,
                                    double accuracy,
                                    double consistency);

    Q_INVOKABLE QVariantMap getAverageTestResult(const QString& testType,
                                                 const QString& language,
                                                 int testDetail) const;
    Q_INVOKABLE void saveLessonResult(int lessonId,
                                      const QString& language,
                                      double speed,
                                      double accuracy);

    Q_INVOKABLE QVariantMap getLessonResult(int lessonId,
                                            const QString& language) const;

    Q_INVOKABLE bool findUserIdBySessionId();
    Q_INVOKABLE int getUserId();
    Q_INVOKABLE QString getRegistrationDate();
    Q_INVOKABLE bool loadFromDatabase(int userId);
    Q_INVOKABLE void update_time_and_presses(int keyStrokes, int time);
    Q_INVOKABLE QVariantMap getBasicProfileStats();
    Q_INVOKABLE QVariantMap getLessonProgress(const QString& language);
    Q_INVOKABLE void updateLessonLockStatus(int lessonID,const QString& language);
    Q_INVOKABLE double getTypingSpeed(const QString& language);
    Q_INVOKABLE void logout();
    int userId() const;
    QString login() const;


signals:
    void userIdChanged();
    void loginChanged();

private:
    int m_userId;
    QString m_login;
};
