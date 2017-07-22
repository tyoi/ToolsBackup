#!/usr/bin/python
#coding=utf-8

import os
import sys
import hashlib
import time
import codecs

#准备数据
dirArr = []

dirArr.append( "base" )
dirArr.append( "battle" )
dirArr.append( "battleWorld" )
dirArr.append( "campBattle" )
dirArr.append( "captain" )
dirArr.append( "guildBattle" )
dirArr.append( "headImg" )
dirArr.append( "icon" )
dirArr.append( "loading" )
dirArr.append( "localization" )
dirArr.append( "ship" )
dirArr.append( "tutorial" )
dirArr.append( "ui" )

#print( dirArr )

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

	#获得当前路径
	currentPath = os.getcwd()
	print( "currentPath:"+currentPath )

	#获得绝对路径
	targetFileLocate = currentPath + "\\fileMD5Dict.txt"
    #print( "targetFileLocate:"+targetFileLocate )

    #判断是否存在目标文件configLocalText.txt
	if os.path.exists( targetFileLocate ):
        #如果存在，删除
		os.remove( targetFileLocate )

    #创建文件，打开
	targetFile = codecs.open( targetFileLocate, 'w', "UTF-8" )

    #写入前两行
	headLine = "STRING\tSTRING\npath\tmd5\n"
	targetFile.write( headLine )

	#创建字典
	dictMD5 = { 'filepath':'md5' }

	#根据dirArr遍历文件夹
	for dirName in dirArr:
		#log
		#print( dirName )

		#获得需要遍历的文件夹名字
		baseDir = currentPath + '\\' + dirName

		#遍历
		for ( dirpath, dirnames, filenames ) in os.walk( baseDir ):

			for filename in filenames:
				#log
				#print( "filename=" + filename )
				
				#获得文件路经
				filePath = dirpath + '\\' + filename
				#获得相对路径
				shortFilePath = filePath[ len(currentPath)+1 : ]
				#print( "filePath=" + filePath )

				#获得MD5值
				updateMD5 = getMD5FromFileWithUpdate( filePath )

				#拼出写入文件的内容
				writeLine = shortFilePath + '\t' + updateMD5 + '\n'

				#写入文件
				targetFile.write( writeLine )

				#加入字典
				dictMD5[ shortFilePath ] = updateMD5

	#print( dictMD5 )
	targetFile.close()