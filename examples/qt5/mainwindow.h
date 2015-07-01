#ifndef MAINWINDOW_H_INCLUDED
#define MAINWINDOW_H_INCLUDED

#include <QMainWindow>
#include <QScopedPointer>

namespace  Ui
{
	class MainWindow;
} // namespace  Ui

class MainWindow : public QMainWindow
{
public:
	MainWindow();
	~MainWindow();

private:
	QScopedPointer<Ui::MainWindow> m_ui;
};

#endif
