#!/usr/bin/python
#coding=utf-8

import os
import sys
import codecs
import chardet
import shutil
import sys
reload(sys)
sys.setdefaultencoding('UTF-8')

if __name__ == '__main__':
    
    #通过参数获得基础文件名
    #print("sys.argv:")
    #print(sys.argv)

    #获得当前路径
    currentPath = os.getcwd()
    #print("currentPath:"+currentPath)

    #目标数据文件路径
    # oriDataPath = "E:\\worldshipsconfig\\数据表\\"
    oriDataPath = "E:\\worldshipsconfig\\测试环境数据表\\"
    oriDataPath = unicode(oriDataPath , "utf8")

    #拼出基础文件路径
    baseFilePath = currentPath + "\\config"
    print( "baseFilePath:" + baseFilePath )

    #循环基础文件夹中的文件
    for fileName in os.listdir( baseFilePath ):
        #调试，输出文件名
        # print( fileName )
        
        #生成文件名
        dstFile = baseFilePath + "\\" + fileName
        dstFile1 = baseFilePath + "\\temp\\" + fileName
        srcFile = oriDataPath + fileName

        if os.path.exists( srcFile ):

            print( "copy:" + fileName )
            #从oriDataPath拷贝过来
            os.remove( dstFile )
            shutil.copyfile( srcFile, dstFile )
            # shutil.copyfile( srcFile, dstFile1 )