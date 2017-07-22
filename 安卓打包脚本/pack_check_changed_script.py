#!/usr/bin/python
#coding=utf-8

import os
import sys
import hashlib
import time
import codecs
import shutil

#声明函数
#判断某路径下是否存在除了输入之外的其他路径
def checkIfExistOtherFile( filePath, nameList ):
	#列出文件路径
	fileList = os.listdir( filePath )

	#列表转字典
	nameList = dict.fromkeys( nameList, True )

	#遍历
	for fileName in fileList:
		#是否存在
		if fileName not in nameList:
			#处理不存在的文件
			print( "different! file:" + filePath + fileName )
			#判断是文件还是文件夹
			if os.path.isdir( filePath + fileName ):
				#删除文件夹
				shutil.rmtree( filePath + fileName )
			else:
				#删除
				os.remove( filePath + fileName )

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

#检查文件是否存在，存在就删除
def checkIfFileExistDelete( filePath ):

	if not os.path.exists( filePath[:filePath.rfind('\\')] ):

		os.makedirs( filePath[:filePath.rfind('\\')] )

	if os.path.exists( filePath ):

		os.remove( filePath )

#准备数据
#当前路径
currentPathDir = os.getcwd()
#print( currentPathDir )
assetsPathDir = currentPathDir + "\\assets\\"
#print( assetsPathDir )
scriptsAssetsDir = assetsPathDir + "scripts\\"
#print( scriptsAssetsDir )

basePathDir = currentPathDir[ :currentPathDir.rfind( "\\" ) + 1 ]
# print( basePathDir )
scriptBasePathDir = basePathDir + "scripts\\"
#print( scriptBasePathDir )
bScriptDir = basePathDir + "bScript\\"
#print( bScriptDir )


#遍历
for ( dirpath, dirnames, filenames ) in os.walk( scriptsAssetsDir ):

	for filename in filenames:
		#log
		# print( "filename=" + filename )

		#获得目标文件路径
		filePath = dirpath + '\\' + filename
		#print( filePath )

		#获得相对路径
		shortFilePath = filePath[ len( scriptsAssetsDir ) : ]
		# print( "shortFilePath=" + shortFilePath )

		#获得目标路径下的文件路径
		targetFilePath = scriptBasePathDir + shortFilePath
		# print( targetFilePath )

		if not os.path.exists( targetFilePath ):
			print( "different! file:" + filePath )

			#删除
			os.remove( filePath )


#判断主要文件是不是有变化
#获得绝对路径
targetFileLocate = currentPathDir + "\\scriptMD5Dict.txt"
#print( "targetFileLocate:"+targetFileLocate )

#判断是否存在目标文件configLocalText.txt
if not os.path.exists( targetFileLocate ):
    #提示先运行创建字典
	print( "please create dict first!" )

	sys.exit()

#创建文件，打开
targetFile = open( targetFileLocate )

#创建字典
dictMD5 = { 'filepath':'md5' }

#填入字典内容
for line in targetFile:
	#去除换行符
	line = line.replace( '\n', '' )
	#去除空行
	if line == "":
		continue
	#按制表符分隔
	lineSplit = line.split( '\t' )
	#存入字典
	dictMD5[ lineSplit[0] ] = lineSplit[ 1 ]

#log
#print( dictMD5 )
targetFile.close()

#是否有文件MD5改变的标记位
ifMD5Changed = False

#遍历
for ( dirpath, dirnames, filenames ) in os.walk( scriptBasePathDir ):

	#按文件遍历
	for filename in filenames:
		#log
		# print( "filename=" + filename )

		#获得目标文件路径
		filePath = dirpath + '\\' + filename
		#print( filePath )

		#获得相对路径
		shortFilePath = filePath[ len( scriptBasePathDir ): ]
		# print( "pathname=" + shortFilePath )

		#获得MD5码
		updateMD5 = getMD5FromFileWithUpdate( filePath )

		#是否要复制文件的标记位
		ifCopyFile = False

		if shortFilePath in dictMD5:
			#获得旧MD5
			oldMD5 = dictMD5[ shortFilePath ]

			if oldMD5 != updateMD5:
				print( "different!\nshortFilePath:" + shortFilePath )
				print( "oldMD5=" + oldMD5 )
				print( "updateMD5=" + updateMD5 )

				ifCopyFile = True

				ifMD5Changed = True
				dictMD5[ shortFilePath ] = updateMD5

		else:
			print( "new!\nshortFilePath:" + shortFilePath )
			print( "updateMD5=" + updateMD5 )

			ifCopyFile = True

			ifMD5Changed = True
			dictMD5[ shortFilePath ] = updateMD5

		#如果要复制文件
		if ifCopyFile:
			#获得目标路径下的文件路径
			targetFilePath = scriptsAssetsDir + shortFilePath

			#查看有没有这个路径
			if not os.path.exists( targetFilePath[:targetFilePath.rfind('\\')] ):

				os.makedirs( targetFilePath[:targetFilePath.rfind('\\')] )

			if not os.path.exists( targetFilePath ):

				shutil.copy( filePath, targetFilePath )

			#拼出命令
			commandLuaJIT = "luajit -b " + filePath + " " + targetFilePath
			
			os.system( commandLuaJIT )


#判断标记位
if ifMD5Changed == True:
	#判断是否存在目标文件configLocalText.txt
	if os.path.exists( targetFileLocate ):
        #如果存在，删除
		os.remove( targetFileLocate )

	#创建文件，打开
	targetFile = codecs.open( targetFileLocate, 'w', "UTF-8" )

	#写入前两行
	headLine = "STRING\tSTRING\npath\tmd5\n"
	targetFile.write( headLine )

	#获得字典key的列表
	keyList = dictMD5.keys()

	for key in keyList:
		#拼出写入文件的内容
		writeLine = key + '\t' + dictMD5[ key ] + '\n'

		#写入文件
		targetFile.write( writeLine )

	targetFile.close()

print( "Finish!" )




































