#!/usr/bin/python
#coding=utf-8

import os
import sys
import hashlib
import time
import codecs

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

#准备数据
#当前路径
currentPathDir = os.getcwd()
#print( currentPathDir )
assetsPathDir = currentPathDir + "\\assets\\"
#print( assetsPathDir )
resAssetsDir = assetsPathDir + "res\\"
#print( resAssetsDir )
normalAssetsDir = resAssetsDir + "normal\\"
#print( normalAssetsDir )
basePathDir = currentPathDir[ :currentPathDir.rfind( "\\" ) + 1 ]
# print( basePathDir )
resBasePathDir = basePathDir + "res\\"
#print( resBasePathDir )
normalBaseDir = resBasePathDir + "normal\\"
#print( normalBaseDir )
androidBaseDir = normalBaseDir + "ios\\android\\"

#Assets 向 原始文件的映射
dictAssetsToRes = {	resAssetsDir + "config":resBasePathDir + "config" }

dictAssetsToRes[ resAssetsDir + "config" ] = resBasePathDir + "config"
dictAssetsToRes[ normalAssetsDir + "base" ] = androidBaseDir + "base"
dictAssetsToRes[ normalAssetsDir + "battle" ] = androidBaseDir + "battle"
dictAssetsToRes[ normalAssetsDir + "battleWorld" ] = androidBaseDir + "battleWorld"
dictAssetsToRes[ normalAssetsDir + "campBattle" ] = androidBaseDir + "campBattle"
dictAssetsToRes[ normalAssetsDir + "captain" ] = androidBaseDir + "captain"
dictAssetsToRes[ normalAssetsDir + "guildBattle" ] = androidBaseDir + "guildBattle"
dictAssetsToRes[ normalAssetsDir + "headImg" ] = androidBaseDir + "headImg"
dictAssetsToRes[ normalAssetsDir + "icon" ] = androidBaseDir + "icon"
dictAssetsToRes[ normalAssetsDir + "loading" ] = androidBaseDir + "loading"
dictAssetsToRes[ normalAssetsDir + "localization" ] = androidBaseDir + "localization"
dictAssetsToRes[ normalAssetsDir + "ship" ] = androidBaseDir + "ship"
dictAssetsToRes[ normalAssetsDir + "tutorial" ] = androidBaseDir + "tutorial"
dictAssetsToRes[ normalAssetsDir + "ui" ] = androidBaseDir + "ui"
dictAssetsToRes[ normalAssetsDir + "audio" ] = normalBaseDir + "audio"
dictAssetsToRes[ normalAssetsDir + "fnt" ] = normalBaseDir + "fnt"
dictAssetsToRes[ normalAssetsDir + "font" ] = normalBaseDir + "font"
dictAssetsToRes[ normalAssetsDir + "layout" ] = normalBaseDir + "layout"
dictAssetsToRes[ normalAssetsDir + "particle" ] = normalBaseDir + "particle"
dictAssetsToRes[ normalAssetsDir + "video" ] = normalBaseDir + "video"

#生成原始文件 向 assets的映射
dictResToAssets = { resBasePathDir + "config":resAssetsDir + "config" }

assetsKeys = dictAssetsToRes.keys()
for key in assetsKeys:
	dictResToAssets[ dictAssetsToRes[key] ] = key

# print( dictAssetsToRes )
# print( dictResToAssets )

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
for dirName in dictResToAssets.keys():
	#log
	#print( dirName )

	#获得需要遍历的文件夹名字
	baseDir = currentPath + "/assets/" + dirName

	#遍历
	for ( dirpath, dirnames, filenames ) in os.walk( dirName ):

		for filename in filenames:
			#log
			#print( "filename=" + filename )
			
			#获得文件路经
			filePath = dirpath + '\\' + filename
			#获得相对路径
			shortFilePath = filePath[ len(dirName)+1 : ]
			# print( "shortFilePath=" + shortFilePath )

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