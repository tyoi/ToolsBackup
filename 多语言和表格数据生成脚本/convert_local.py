#!/usr/bin/python
#coding=utf-8

import os
import sys
import codecs
import chardet
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

    #获得绝对路径
    targetFileLocate = currentPath + "\\configLocalText.txt"
    print( "targetFileLocate:"+targetFileLocate )

    #判断是否存在目标文件configLocalText.txt
    if os.path.exists( targetFileLocate ):
        #如果存在，删除
        os.remove( targetFileLocate )

    #创建文件，打开
    targetFile = codecs.open( targetFileLocate, 'w', "UTF-8" )

    #写入前两行
    headLine = "STRING\tSTRING\nkey\tvalue\n"
    targetFile.write( headLine )

    #拼出基础文件路径
    baseFilePath = currentPath + "\\config"

    #循环基础文件夹中的文件
    for fileName in os.listdir( baseFilePath ):
        #调试，输出文件名
        print( fileName )
        fileNameShort = fileName.replace( ".txt", "" )

        #去掉某些不会包含本地化字符串的文件
        if fileName == "CheckNameData.txt":
            continue

        #打开文件
        baseFile = open( baseFilePath + "\\" + fileName )

        data = baseFile.read()
        detectResult = chardet.detect(data)

        print( detectResult )
        baseFile.seek(0, 0)

        #读出第一行,第二行
        firstLine = baseFile.readline()
        secondLine = baseFile.readline()
        #调试用
        #print( "firstLine:"+firstLine )
        #print( "secondLine:"+secondLine )

        #去掉换行符号
        firstLine = firstLine.replace( '\n', '' )
        secondLine = secondLine.replace( '\n', '' )

        #按制表符分隔
        firstLineSplit = firstLine.split( '\t' )
        secondLineSplit = secondLine.split( '\t' )

        #记录需要本地化的列号的数组
        arrLocal = []

        for i in range( len(firstLineSplit) ):
            #获得标题
            wordFirst = firstLineSplit[i]
            #如果是STRING类型
            if wordFirst == "STRING":
                #获得格式说明
                wordSecond = secondLineSplit[i]
                #判断是不是中文，是不是以“_l”结尾
                if wordSecond.find( "_l" ) == (len( wordSecond ) - 2):
                    #print( wordSecond )
                    arrLocal.append( i )


        if fileNameShort == "FakeBroadcastName":
            print( arrLocal )
        #如果已经记录过列号，则需要继续操作，否则检查下一个表格
        if len( arrLocal ) == 0:
            continue
        else:
            for line in baseFile:
                #如果是注释行，跳过
                if line.find( '#' ) == 0:
                    continue
                else:
                    #去掉换行符
                    line = line.replace( '\n', '' )
                    #如果是空行，跳过
                    if line == "":
                        continue
                    #按制表符分隔
                    lineSplit = line.split( '\t' )
                    #判断该位置是不是空
                    for i in arrLocal:
                        # if lineSplit[i] != "":
                            #拼字符串
                            writeLine = "Config_" + fileNameShort + '_' + str(i) + '_' + lineSplit[0] + '\t' + lineSplit[i] + '\n'
                            #处理编码
                            if detectResult['encoding'] == 'utf-8':
                                unicodeWriteLine = writeLine
                            else:
                                unicodeWriteLine = writeLine.decode( 'gbk' )
                                unicodeWriteLine = unicodeWriteLine.encode( 'UTF-8' )

                            #写入
                            targetFile.write( unicodeWriteLine )
    #关闭目标文件
    targetFile.close()
