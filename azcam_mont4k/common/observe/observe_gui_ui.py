# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'observe_gui.ui'
#
# Created by: PyQt4 UI code generator 4.11.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:

    def _fromUtf8(s):
        return s


try:
    _encoding = QtGui.QApplication.UnicodeUTF8

    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)


except AttributeError:

    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)


class Ui_observe(object):
    def setupUi(self, observe):
        observe.setObjectName(_fromUtf8("observe"))
        observe.resize(936, 214)
        self.centralwidget = QtGui.QWidget(observe)
        self.centralwidget.setObjectName(_fromUtf8("centralwidget"))
        self.tableWidget_script = QtGui.QTableWidget(self.centralwidget)
        self.tableWidget_script.setGeometry(QtCore.QRect(10, 120, 911, 61))
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.tableWidget_script.sizePolicy().hasHeightForWidth())
        self.tableWidget_script.setSizePolicy(sizePolicy)
        self.tableWidget_script.setMinimumSize(QtCore.QSize(50, 50))
        self.tableWidget_script.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAsNeeded)
        self.tableWidget_script.setHorizontalScrollBarPolicy(QtCore.Qt.ScrollBarAsNeeded)
        self.tableWidget_script.setAutoScroll(True)
        self.tableWidget_script.setAlternatingRowColors(True)
        self.tableWidget_script.setVerticalScrollMode(QtGui.QAbstractItemView.ScrollPerItem)
        self.tableWidget_script.setHorizontalScrollMode(QtGui.QAbstractItemView.ScrollPerItem)
        self.tableWidget_script.setRowCount(1)
        self.tableWidget_script.setColumnCount(17)
        self.tableWidget_script.setObjectName(_fromUtf8("tableWidget_script"))
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(0, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(1, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(2, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(3, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(4, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(5, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(6, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(7, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(8, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(9, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(10, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(11, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(12, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(13, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(14, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(15, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setHorizontalHeaderItem(16, item)
        item = QtGui.QTableWidgetItem()
        self.tableWidget_script.setItem(0, 1, item)
        self.tableWidget_script.horizontalHeader().setDefaultSectionSize(50)
        self.tableWidget_script.horizontalHeader().setMinimumSectionSize(30)
        self.tableWidget_script.horizontalHeader().setStretchLastSection(False)
        self.tableWidget_script.verticalHeader().setVisible(False)
        self.tableWidget_script.verticalHeader().setDefaultSectionSize(20)
        self.tableWidget_script.verticalHeader().setMinimumSectionSize(20)
        self.tableWidget_script.verticalHeader().setStretchLastSection(False)
        self.pushButton_run = QtGui.QPushButton(self.centralwidget)
        self.pushButton_run.setGeometry(QtCore.QRect(110, 50, 81, 31))
        font = QtGui.QFont()
        font.setBold(True)
        font.setWeight(75)
        self.pushButton_run.setFont(font)
        self.pushButton_run.setObjectName(_fromUtf8("pushButton_run"))
        self.pushButton_abort_script = QtGui.QPushButton(self.centralwidget)
        self.pushButton_abort_script.setGeometry(QtCore.QRect(650, 50, 81, 31))
        font = QtGui.QFont()
        font.setBold(False)
        font.setWeight(50)
        self.pushButton_abort_script.setFont(font)
        self.pushButton_abort_script.setStyleSheet(
            _fromUtf8("QPushButton {\n" "    background-color: rgb(255, 112, 114);\n" "}\n" "")
        )
        self.pushButton_abort_script.setObjectName(_fromUtf8("pushButton_abort_script"))
        self.spinBox_loops = QtGui.QSpinBox(self.centralwidget)
        self.spinBox_loops.setGeometry(QtCore.QRect(240, 50, 41, 31))
        self.spinBox_loops.setMinimum(1)
        self.spinBox_loops.setObjectName(_fromUtf8("spinBox_loops"))
        self.label_loops = QtGui.QLabel(self.centralwidget)
        self.label_loops.setGeometry(QtCore.QRect(200, 50, 31, 30))
        self.label_loops.setObjectName(_fromUtf8("label_loops"))
        self.plainTextEdit_filename = QtGui.QPlainTextEdit(self.centralwidget)
        self.plainTextEdit_filename.setGeometry(QtCore.QRect(10, 10, 721, 31))
        self.plainTextEdit_filename.setObjectName(_fromUtf8("plainTextEdit_filename"))
        self.pushButton_selectscript = QtGui.QPushButton(self.centralwidget)
        self.pushButton_selectscript.setGeometry(QtCore.QRect(750, 10, 91, 31))
        self.pushButton_selectscript.setObjectName(_fromUtf8("pushButton_selectscript"))
        self.label_status = QtGui.QLabel(self.centralwidget)
        self.label_status.setGeometry(QtCore.QRect(10, 90, 911, 20))
        self.label_status.setStyleSheet(
            _fromUtf8("QLabel {\n" "    background-color: rgb(199, 199, 199);\n" "}\n" "")
        )
        self.label_status.setFrameShape(QtGui.QFrame.StyledPanel)
        self.label_status.setFrameShadow(QtGui.QFrame.Sunken)
        self.label_status.setText(_fromUtf8(""))
        self.label_status.setObjectName(_fromUtf8("label_status"))
        self.pushButton_loadscript = QtGui.QPushButton(self.centralwidget)
        self.pushButton_loadscript.setGeometry(QtCore.QRect(10, 50, 91, 31))
        self.pushButton_loadscript.setObjectName(_fromUtf8("pushButton_loadscript"))
        self.label_counter = QtGui.QLabel(self.centralwidget)
        self.label_counter.setGeometry(QtCore.QRect(860, 50, 31, 31))
        font = QtGui.QFont()
        font.setBold(True)
        font.setWeight(75)
        self.label_counter.setFont(font)
        self.label_counter.setFrameShape(QtGui.QFrame.StyledPanel)
        self.label_counter.setFrameShadow(QtGui.QFrame.Sunken)
        self.label_counter.setText(_fromUtf8(""))
        self.label_counter.setAlignment(QtCore.Qt.AlignCenter)
        self.label_counter.setObjectName(_fromUtf8("label_counter"))
        self.pushButton_pause_script = QtGui.QPushButton(self.centralwidget)
        self.pushButton_pause_script.setGeometry(QtCore.QRect(550, 50, 91, 31))
        font = QtGui.QFont()
        font.setBold(False)
        font.setWeight(50)
        self.pushButton_pause_script.setFont(font)
        self.pushButton_pause_script.setStyleSheet(
            _fromUtf8("QPushButton {\n" "    background-color: rgb(255, 255, 127);\n" "}\n" "")
        )
        self.pushButton_pause_script.setObjectName(_fromUtf8("pushButton_pause_script"))
        self.pushButton_editscript = QtGui.QPushButton(self.centralwidget)
        self.pushButton_editscript.setGeometry(QtCore.QRect(750, 50, 91, 31))
        self.pushButton_editscript.setObjectName(_fromUtf8("pushButton_editscript"))
        self.doubleSpinBox_ExpTimeScale = QtGui.QDoubleSpinBox(self.centralwidget)
        self.doubleSpinBox_ExpTimeScale.setGeometry(QtCore.QRect(350, 50, 62, 30))
        self.doubleSpinBox_ExpTimeScale.setDecimals(3)
        self.doubleSpinBox_ExpTimeScale.setProperty("value", 1.0)
        self.doubleSpinBox_ExpTimeScale.setObjectName(_fromUtf8("doubleSpinBox_ExpTimeScale"))
        self.label_loops_2 = QtGui.QLabel(self.centralwidget)
        self.label_loops_2.setGeometry(QtCore.QRect(300, 50, 41, 30))
        self.label_loops_2.setObjectName(_fromUtf8("label_loops_2"))
        self.pushButton_scale_et = QtGui.QPushButton(self.centralwidget)
        self.pushButton_scale_et.setGeometry(QtCore.QRect(420, 50, 61, 31))
        font = QtGui.QFont()
        font.setBold(False)
        font.setWeight(50)
        self.pushButton_scale_et.setFont(font)
        self.pushButton_scale_et.setStyleSheet(_fromUtf8(""))
        self.pushButton_scale_et.setObjectName(_fromUtf8("pushButton_scale_et"))
        observe.setCentralWidget(self.centralwidget)
        self.statusbar = QtGui.QStatusBar(observe)
        self.statusbar.setObjectName(_fromUtf8("statusbar"))
        observe.setStatusBar(self.statusbar)
        self.actionSelect_Script = QtGui.QAction(observe)
        self.actionSelect_Script.setObjectName(_fromUtf8("actionSelect_Script"))

        self.retranslateUi(observe)
        QtCore.QMetaObject.connectSlotsByName(observe)

    def retranslateUi(self, observe):
        observe.setWindowTitle(_translate("observe", "Observe", None))
        self.tableWidget_script.setToolTip(_translate("observe", "script command table", None))
        item = self.tableWidget_script.horizontalHeaderItem(0)
        item.setText(_translate("observe", "#", None))
        item = self.tableWidget_script.horizontalHeaderItem(1)
        item.setText(_translate("observe", "Status", None))
        item.setToolTip(_translate("observe", "# => do not execute", None))
        item = self.tableWidget_script.horizontalHeaderItem(2)
        item.setText(_translate("observe", "Command", None))
        item = self.tableWidget_script.horizontalHeaderItem(3)
        item.setText(_translate("observe", "Argument", None))
        item = self.tableWidget_script.horizontalHeaderItem(4)
        item.setText(_translate("observe", "ExpTime", None))
        item = self.tableWidget_script.horizontalHeaderItem(5)
        item.setText(_translate("observe", "Type", None))
        item = self.tableWidget_script.horizontalHeaderItem(6)
        item.setText(_translate("observe", "Title", None))
        item = self.tableWidget_script.horizontalHeaderItem(7)
        item.setText(_translate("observe", "NumExps", None))
        item = self.tableWidget_script.horizontalHeaderItem(8)
        item.setText(_translate("observe", "Filter", None))
        item = self.tableWidget_script.horizontalHeaderItem(9)
        item.setText(_translate("observe", "RA", None))
        item = self.tableWidget_script.horizontalHeaderItem(10)
        item.setText(_translate("observe", "DEC", None))
        item = self.tableWidget_script.horizontalHeaderItem(11)
        item.setText(_translate("observe", "Epoch", None))
        item = self.tableWidget_script.horizontalHeaderItem(12)
        item.setText(_translate("observe", "EXPOSE", None))
        item = self.tableWidget_script.horizontalHeaderItem(13)
        item.setText(_translate("observe", "MOVETEL", None))
        item = self.tableWidget_script.horizontalHeaderItem(14)
        item.setText(_translate("observe", "STEPTEL", None))
        item = self.tableWidget_script.horizontalHeaderItem(15)
        item.setText(_translate("observe", "MOVEFILTER", None))
        item = self.tableWidget_script.horizontalHeaderItem(16)
        item.setText(_translate("observe", "MOVEFOCUS", None))
        __sortingEnabled = self.tableWidget_script.isSortingEnabled()
        self.tableWidget_script.setSortingEnabled(False)
        self.tableWidget_script.setSortingEnabled(__sortingEnabled)
        self.pushButton_run.setToolTip(_translate("observe", "execute the script", None))
        self.pushButton_run.setText(_translate("observe", "Run", None))
        self.pushButton_abort_script.setToolTip(
            _translate(
                "observe",
                "<html><head/><body><p>abort script execution as soon as possible</p></body></html>",
                None,
            )
        )
        self.pushButton_abort_script.setText(_translate("observe", "Abort Script", None))
        self.spinBox_loops.setToolTip(
            _translate(
                "observe",
                "<html><head/><body><p>Number of times to run the complete script</p></body></html>",
                None,
            )
        )
        self.label_loops.setText(_translate("observe", "Cycles", None))
        self.plainTextEdit_filename.setPlainText(
            _translate("observe", "C:/azcam/systems/90prime6/ObservingScripts/test.txt", None)
        )
        self.pushButton_selectscript.setToolTip(
            _translate("observe", "select a script on disk", None)
        )
        self.pushButton_selectscript.setText(_translate("observe", "Select Script", None))
        self.pushButton_loadscript.setToolTip(
            _translate("observe", "load the script into the table below", None)
        )
        self.pushButton_loadscript.setText(_translate("observe", "Load Script", None))
        self.label_counter.setToolTip(_translate("observe", "watchdog", None))
        self.pushButton_pause_script.setToolTip(
            _translate(
                "observe",
                "<html><head/><body><p>Pause/Resume a running script (toggle)</p></body></html>",
                None,
            )
        )
        self.pushButton_pause_script.setText(_translate("observe", "Pause/Resume", None))
        self.pushButton_editscript.setToolTip(_translate("observe", "edit the script file", None))
        self.pushButton_editscript.setText(_translate("observe", "Edit Script", None))
        self.doubleSpinBox_ExpTimeScale.setToolTip(
            _translate("observe", "scale to apply to all exposure times", None)
        )
        self.label_loops_2.setText(_translate("observe", "ET Scale", None))
        self.pushButton_scale_et.setToolTip(
            _translate(
                "observe",
                "<html><head/><body><p>Pause/Resume a running script (toggle)</p></body></html>",
                None,
            )
        )
        self.pushButton_scale_et.setStatusTip(
            _translate("observe", "apply ET Scale to exposure time", None)
        )
        self.pushButton_scale_et.setText(_translate("observe", "Scale ET", None))
        self.actionSelect_Script.setText(_translate("observe", "Select Script", None))
