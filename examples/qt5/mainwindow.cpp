#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow() :
	m_ui(new Ui::MainWindow())
{
	m_ui->setupUi(this);
}

MainWindow::~MainWindow()
{
}
