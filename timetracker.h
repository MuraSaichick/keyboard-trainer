#ifndef TIMETRACKER_H
#define TIMETRACKER_H

#include <QObject>
#include <QTimer>
#include <keyboardhandler.h>

class TimeTracker : public QObject
{
    Q_OBJECT
public:
    explicit TimeTracker(QObject* parent = nullptr);

    Q_INVOKABLE void start(int endTime = 0);     // запускает по текущему режиму
    Q_INVOKABLE void stop();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void setIsTimer(bool isTimer);   // установить режим таймера/секундомера

signals:
    void timeChanged(int newTime);    // передаёт либо прошедшее время, либо оставшееся
    void timerFinished();

public slots:
    void setKeyboardHandler(KeyboardHandler* keyboardHandler);
    QList<double> getListSpeed();
    int getTime();

private slots:
    void onTimeout();

private:
    QTimer m_timer;
    int m_elapsedTime;      // для секундомера
    int m_remainingTime;    // для таймера
    bool m_isTimer;
    bool m_timerStarted;
    double m_speed;
    QList<double> m_speedLog;
    KeyboardHandler* m_keyboardHandler;
};

#endif // TIMETRACKER_H

