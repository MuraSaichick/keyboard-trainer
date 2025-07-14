#ifndef LESSONMANAGER_H
#define LESSONMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QVariantMap>

class LessonManager : public QObject
{
    Q_OBJECT

public:
    explicit LessonManager(QObject *parent = nullptr);

    Q_INVOKABLE int getLessonsCount(const QString& language);
    Q_INVOKABLE double getUserLessonSpeed(int userId, int lessonId, const QString& language);
    Q_INVOKABLE double getUserLessonAccuracy(int userId, int lessonId, const QString& language);
    Q_INVOKABLE QString getLessonText(int lessonId, const QString& language);

    Q_INVOKABLE QString getLessonType(const QString &language, int lessonId);


private:
    QSqlDatabase m_db;
    bool connectToDatabase();
};

#endif // LESSONMANAGER_H

