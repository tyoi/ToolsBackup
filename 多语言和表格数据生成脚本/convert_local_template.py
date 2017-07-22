#!/usr/bin/python
#coding=utf-8

import os
import sys
import codecs
import chardet
import hashlib
import shutil
import sys
reload(sys)
sys.setdefaultencoding('UTF-8')

#增量获得文件的MD5值
def getMD5FromFileWithUpdate( filePath ):
    #判断是否存在文件
    if not os.path.exists( filePath ):
        #不存在
        return
    #获得hashlib的对象
    myhash = hashlib.md5()
    #打开文件
    file = open( filePath, 'rb' )
    #增量获得Md5
    while True:
        b = file.read(8096)
        if not b :
            break
        myhash.update(b)
    #关闭文件
    file.close()

    #返回MD5值
    return myhash.hexdigest()

if __name__ == '__main__':
    
    #通过参数获得基础文件名
    #print("sys.argv:")
    #print(sys.argv)

    #获得当前路径
    currentPath = os.getcwd()
    #print("currentPath:"+currentPath)
    #-----------            声明重要变量          ----------
    #表示是否有内容被改变
    ifContentChange = False
    
    #数据生成的目标位置
    templateLocate = currentPath + "\\LuaTemplate\\"

    #目标数据文件的位置
    destTemplateLocate = "E:\\worldshipsclient\\trunk\\worldship\\scripts\\Template\\"
    #-----------            声明重要变量          ----------


    #-----------            处理目标文件          ----------
    #获得目标文件绝对路径
    targetFileLocate = currentPath + "\\configLocalText.txt"
    # print( "targetFileLocate:"+targetFileLocate )

    #判断是否存在目标文件configLocalText.txt
    if not os.path.exists( targetFileLocate ):
        print( "no target file:configLocalText.txt!" )
        sys.exit()

    #打开文件,读出文件内容,关闭文件,删除文件
    targetFile = codecs.open( targetFileLocate, 'r', "UTF-8" )
    targetData = targetFile.readlines()
    targetFile.close()
    os.remove( targetFileLocate )
    print( "len:" + str( len( targetData ) ) )
    print( "str:" + str( targetData[ len( targetData ) - 1 ] ) )

    #再创建文件，打开
    targetFile = codecs.open( targetFileLocate, 'w', "UTF-8" )

    #写入前两行
    headLine = "STRING\tSTRING\nkey\tvalue\n"
    targetFile.write( headLine )

    #记录文件index行号
    indexForFile = 2
    #-----------            处理目标文件          ----------


    #-----------            处理索引文件          ----------
    #获得索引文件绝对路径
    indexFileLocate = currentPath + "\\configLocalText_index.txt"

    #创建字典，填入字典内容
    dictIndexStart = { 'filename':'index' }
    dictIndexEnd = { 'filename':'index' }

    #判断是否存在目标文件configLocalText_index.txt
    if not os.path.exists( indexFileLocate ):
        print( "no index file!" )
    else:
        #打开文件
        indexFile = open( indexFileLocate )

        #填入字典内容
        for line in indexFile:
            line = line.replace( '\n', '' )
            if line == "":
                continue
            lineSplit = line.split( '\t' )
            dictIndexStart[ lineSplit[0] ] = lineSplit[ 1 ]
            dictIndexEnd[ lineSplit[0] ] = lineSplit[ 2 ]

        #关闭文件
        indexFile.close()
    #-----------            处理索引文件          ----------


    #-----------            处理MD5文件          ----------
    #获得MD5文件的绝对路径
    MD5FileLocate = currentPath + "\\configLocalText_md5.txt"

    #创建字典
    dictMD5 = { 'filename':'MD5' }

    #判断是否存在目标文件configLocalText_md5.txt
    if not os.path.exists( MD5FileLocate ):
        print( "no md5 file!" )
    else:
        #打开文件
        md5File = open( MD5FileLocate )

        #填入字典内容
        for line in md5File:
            line = line.replace( '\n', '' )
            if line == "":
                continue
            lineSplit = line.split( '\t' )
            dictMD5[ lineSplit[0] ] = lineSplit[ 1 ]

        #关闭文件
        md5File.close()
    #-----------            处理MD5文件          ----------


    #-----------            处理数据文件临时文件夹          ----------
    #如果存在
    if os.path.exists( templateLocate ):
        #删除
        shutil.rmtree( templateLocate )

    #创建目录
    os.mkdir( templateLocate )
    #-----------            处理数据文件临时文件夹          ----------

   
    #-----------            遍历处理文件          ----------    
    #拼出基础文件路径
    baseFilePath = currentPath + "\\config"

    #循环基础文件夹中的文件
    for fileName in os.listdir( baseFilePath ):
        #调试，输出文件名
        
        fileNameShort = fileName.replace( ".txt", "" )

        #去掉某些不会包含本地化字符串的文件
        if fileName == "CheckNameData.txt":
            continue

        #标记是否记录索引的标记位
        ifRecordIndex = False

        #记录文件MD5码
        updateMD5 = getMD5FromFileWithUpdate( baseFilePath + "\\" + fileName )
        # dictMD5[ fileNameShort ] = updateMD5

        #如果MD5值一样，就从旧的数据里复制过来
        if fileNameShort in dictMD5.keys() and updateMD5 == dictMD5[ fileNameShort ]:

            # print( "no change" )

            if fileNameShort in dictIndexStart.keys():
                # print( "have content" )

                #将过去文件的内容写入
                for i in range( int(dictIndexStart[ fileNameShort ]), int(dictIndexEnd[ fileNameShort ]) + 1 ):
                    # print( "i:" + str(i) )

                    #写入
                    targetFile.write( targetData[ i ] )

                    #判断有没有记录过索引
                    if ifRecordIndex == False:
                        
                        #记录开始位置
                        dictIndexStart[ fileNameShort ] = indexForFile

                        #改变标记位
                        ifRecordIndex = True

                    #记录结束位置
                    dictIndexEnd[ fileNameShort ] = indexForFile

                    #索引增加
                    indexForFile = indexForFile + 1
            # else:
            #     print( "no content" )
        #如果MD5不一样，就重新生成多语言和数据文件
        else:
            print( fileName + "Change!" )

            #改变修改标记位
            ifContentChange = True

            #记录新的MD5码
            dictMD5[ fileNameShort ] = updateMD5

            #打开文件
            baseFile = open( baseFilePath + "\\" + fileName )

            data = baseFile.read()
            detectResult = chardet.detect(data)

            print( detectResult )
            baseFile.seek(0, 0)

            #读出第一行,第二行
            firstLine = baseFile.readline()
            secondLine = baseFile.readline()
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

            #拼出临时数据文件的路径
            templateFileLocate = templateLocate + fileNameShort + "Template.lua"

            #在临时文件夹创建文件
            # templateFile = codecs.open( templateFileLocate, 'w', "UTF-8" )
            templateFile = open( templateFileLocate, 'w' )
            
            #写入文件头
            templateFile.write( "-- 自动生成文件，请勿手动修改\n\nlocal " + fileNameShort + "Template = {\n\t\n" )  

            #记录行数用于数据文件
            countForTemplate = 0

            #如果已经记录过列号，则需要继续操作，否则检查下一个表格
            # if len( arrLocal ) == 0:
            #     continue
            # else:
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

                    #行数加一
                    countForTemplate = countForTemplate + 1
                    
                    #如果包含多语言内容
                    if len( arrLocal ) > 0:

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

                            #判断有没有记录过索引
                            if ifRecordIndex == False:
                                
                                #记录开始位置
                                dictIndexStart[ fileNameShort ] = indexForFile

                                #改变标记位
                                ifRecordIndex = True

                            #记录结束位置
                            dictIndexEnd[ fileNameShort ] = indexForFile

                            #索引增加
                            indexForFile = indexForFile + 1

                    #生成行首
                    templateFile.write( "\t{" )

                    #遍历
                    for i in range( len(firstLineSplit) ):
                        if firstLineSplit[ i ] == "INT":
                            lineSplit[i] = lineSplit[i].replace( ' ', '' )

                        if firstLineSplit[i] == "STRING" or secondLineSplit[i].find( "_l" ) == (len( secondLineSplit[i] ) - 2):
                            lineSplit[i] = lineSplit[i].lstrip()

                            lineSplit[i] = lineSplit[i].replace( '\"', '&quot;' )

                        if firstLineSplit[i] == "" and secondLineSplit[i].find( "_l" ) != (len( secondLineSplit[i] ) - 2):
                            continue

                        #如果是空行
                        if lineSplit[i] == "":
                            #如果是字符
                            if firstLineSplit[i] == "STRING" or secondLineSplit[i].find( "_l" ) == (len( secondLineSplit[i] ) - 2):
                                #写入一个空字符
                                templateFile.write( "\"\", " )
                            else:
                                #写入一个零
                                templateFile.write( "0, " )
                        else:
                            #如果是字符
                            if firstLineSplit[i] == "STRING" or secondLineSplit[i].find( "_l" ) == (len( secondLineSplit[i] ) - 2):
                                writeLine = ""

                                secondLineStr = secondLineSplit[i]

                                #判断是否有分隔符
                                if lineSplit[i].find( "|" ) != -1 and lineSplit[i] == "|":
                                    writeLine = writeLine + "{\"\"}, "

                                elif lineSplit[i].find( "|" ) != -1 and secondLineStr.find( "_l" ) != (len( secondLineStr ) - 2):
                                    tempStr = lineSplit[i]
                                    #大括号开始
                                    writeLine = writeLine + "{"
                                    #分隔
                                    contentSplit = tempStr.split( '|' )
                                    #遍历
                                    for i in range( len( contentSplit ) ):
                                        if contentSplit[i] != "":
                                            #添加
                                            writeLine = writeLine + "\"" + str( contentSplit[i] ) + "\""
                                            #如果不是最后一个
                                            if i != len( contentSplit ) - 1:
                                                writeLine = writeLine + ", "
                                        
                                    #大括号结尾
                                    writeLine = writeLine + "}, "
                                else:
                                    writeLine = writeLine + "\"" + str( lineSplit[i] ) + "\", "

                                #处理编码
                                if detectResult['encoding'] == 'utf-8':
                                    unicodeWriteLine = writeLine
                                else:
                                    unicodeWriteLine = writeLine.decode( 'gbk' )
                                    unicodeWriteLine = unicodeWriteLine.encode( 'UTF-8' )

                                templateFile.write( unicodeWriteLine )
                            else:
                                writeLine = ""

                                #判断是否有分隔符
                                if lineSplit[i].find( "|" ) != -1 and secondLineStr.find( "_l" ) != (len( secondLineStr ) - 2):
                                    tempStr = lineSplit[i]
                                    #大括号开始
                                    writeLine = writeLine + "{"
                                    #分隔
                                    contentSplit = tempStr.split( '|' )
                                    #遍历
                                    for i in range( len( contentSplit ) ):
                                        if contentSplit[i] != "":
                                            #添加
                                            writeLine = writeLine + str( contentSplit[i] )
                                            #如果不是最后一个
                                            if i != len( contentSplit ) - 1:
                                                writeLine = writeLine + ", "
                                        
                                    #大括号结尾
                                    writeLine = writeLine + "}, "
                                else:
                                    writeLine = writeLine + str( lineSplit[i] ) + ", "

                                #处理编码
                                if detectResult['encoding'] == 'utf-8':
                                    unicodeWriteLine = writeLine
                                else:
                                    unicodeWriteLine = writeLine.decode( 'gbk' )
                                    unicodeWriteLine = unicodeWriteLine.encode( 'UTF-8' )

                                templateFile.write( unicodeWriteLine )

                    #生成行尾
                    templateFile.write( "},\n" )

            #生成数据末尾
            templateFile.write( "\n}\n\nlocal KEYS = {\n" )

            #生成键
            indexForKey = 1
            for i in range( len(secondLineSplit) ):
                if firstLineSplit[i] == "" and secondLineSplit[i].find( "_l" ) != (len( secondLineSplit[i] ) - 2):
                    continue
                
                wordSecond = secondLineSplit[i]

                #判断是不是以“_l”结尾
                if wordSecond.find( "_l" ) == (len( wordSecond ) - 2):
                    #写入键的内容
                    templateFile.write( "\t" + wordSecond[0:len( wordSecond ) - 2] + " = " + str( indexForKey ) + ",\n" )
                else:
                    #写入键的内容
                    templateFile.write( "\t" + wordSecond + " = " + str( indexForKey ) + ",\n" )

                indexForKey = indexForKey + 1

            #生成尾部内容
            templateFile.write( "\t\n}\n\n" )
            templateFile.write( "_G." + fileNameShort + "Template_Len = " + str( countForTemplate ) + "\n\n" )
            templateFile.write( "_G." + fileNameShort + "Template = " + fileNameShort + "Template" + "\n\n" )
            templateFile.write( "return " + fileNameShort + "Template" )

            #关闭文件
            templateFile.close()

            #目标文件路径
            destTemplateFileLocate = destTemplateLocate + fileNameShort + "Template.lua"

            #复制文件
            shutil.copy( templateFileLocate, destTemplateFileLocate )

    #关闭目标文件
    targetFile.close()
    #-----------            遍历处理文件          ----------    


    #-----------            处理索引文件          ----------
    #如果内容改变
    if ifContentChange == True:

        #判断是否存在目标文件configLocalText.txt
        if os.path.exists( indexFileLocate ):

            #如果存在，删除
            os.remove( indexFileLocate )

        #再创建文件，打开
        indexFile = codecs.open( indexFileLocate, 'w', "UTF-8" )

        #获得字典key的列表
        keyList = dictIndexStart.keys()

        #遍历全部文件名
        for key in keyList:

            #拼出写入文件的内容
            writeLine = key + '\t' + str( dictIndexStart[ key ] ) + '\t' + str( dictIndexEnd[ key ] ) + '\n'

            #写入文件
            indexFile.write( writeLine )

        #关闭索引文件
        indexFile.close()
    #-----------            处理索引文件          ----------


    #-----------            处理MD5文件          ----------
    if ifContentChange == True:
    #判断是否存在目标文件configLocalText.txt
        if os.path.exists( MD5FileLocate ):

            #如果存在，删除
            os.remove( MD5FileLocate )

        #再创建文件，打开
        md5File = codecs.open( MD5FileLocate, 'w', "UTF-8" )

        #获得字典key的列表
        keyList = dictMD5.keys()

        #遍历全部文件名
        for key in keyList:

            #拼出写入文件的内容
            writeLine = key + '\t' + dictMD5[ key ] + '\n'

            #写入文件
            md5File.write( writeLine )

        #关闭索引文件
        md5File.close()
    #-----------            处理MD5文件          ----------