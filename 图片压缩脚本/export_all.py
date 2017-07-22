#!/usr/bin/python
#coding=utf-8

import os
import sys
import hashlib
import time
import codecs
import shutil

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

#只包含特定类型的路径
dirAndroidDict = { "ui\logo_shenzhenweishi\logo_shenzhenweishi.plist":"android" }
dirAndroidDict[ "ui\logo_shenzhenweishi\logo_shenzhenweishi.png" ] = "android"


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
	

if __name__ == '__main__':

	#获得当前路径
	currentPath = os.getcwd()
	#print( "currentPath:"+currentPath )

	#获得绝对路径
	targetFileLocate = currentPath + "\\fileMD5Dict.txt"
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

	#获得临时文件路径
	tempPath = currentPath + "\\temp\\"

	if os.path.exists( tempPath ):
		#删除
		shutil.rmtree( tempPath )

	#创建目录
	os.mkdir( tempPath )

	#是否有文件MD5改变的标记位
	ifMD5Changed = False

	os.chdir( "D:\\ARM\\Mali Developer Tools\\Mali Texture Compression Tool v4.2.0\\bin" )
	os.system( "dir" )
	print( "Searching for MD5 differences..." )

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
				

				#获得MD5值
				updateMD5 = getMD5FromFileWithUpdate( filePath )

				#根字典中的MD5值进行对比
				if shortFilePath in dictMD5.keys() and updateMD5 == dictMD5[ shortFilePath ]:
					#继续判断下一个文件
					continue
				#MD5值不一样
				else:
					print( "different!" )
					print( "filePath=" + filePath )

					if shortFilePath in dictMD5.keys():
						print( "oldmd5=" + dictMD5[ shortFilePath ] + '.' )
					else:
						print( "old file doesn't exist" )
					
					print( "newmd5=" + updateMD5 + '.' )

					#修改标记位
					ifMD5Changed = True

					#修改字典中的值
					dictMD5[ shortFilePath ] = updateMD5

					#根据后缀判断文件类型
					#获得文件后缀
					indexSymbol = shortFilePath.find( '.' )
					suffix = shortFilePath[ indexSymbol+1: ]
					
					#判断文件类型
					if suffix == "png":
						#前缀
						prefix =  filename[ :filename.find( '.' ) ]
						#print( prefix )
						#拼出pvr.ccz文件路径
						pathPVRCCZ = tempPath + prefix + ".pvr.ccz"
						#拼出alpha png的文件路径
						pathAlpha = tempPath + prefix + ".png"
						#拼出pkm文件的路径
						pathPkm = tempPath + prefix + ".pkm"
						#拼出alpha pkm的文件路径
						pathAlphaPkm = tempPath + prefix + "_alpha.pkm"

						#pack pvr.ccz 的命令
						commandPVRCCZ = "TexturePacker --texture-format pvr2ccz --premultiply-alpha --border-padding 0 --trim-mode None --shape-padding 0 --opt PVRTC4 --sheet " + pathPVRCCZ + ' ' + filePath
						#pack alpha png 的命令
						commandAlpha = "TexturePacker --texture-format png --premultiply-alpha --padding 0 --disable-rotation --inner-padding 0 --border-padding 0 --trim-mode None --shape-padding 0 --opt RGBA8888 --sheet " + pathAlpha + ' ' + filePath
						#pack pkm 的命令
						commandPkm = "etcpack " + pathAlpha + " " + tempPath[ :len(tempPath)-1 ] + " -v -c etc -as -s fast"
						
						print( "command=" + commandAlpha )
						os.system( commandAlpha )
						print( "command=" + commandPkm )
						os.system( commandPkm )
						print( "command=" + commandPVRCCZ )
						os.system( commandPVRCCZ )

						#拼出ios路径
						pathIOS = currentPath + "\\ios\\" + shortFilePath[ :shortFilePath.find(filename) ] + prefix + ".pvr.ccz"
						# print( "pathIOS=" + pathIOS )
						#拼出ANDROID路径
						pathANDROID = currentPath + "\\ios\\android\\" + shortFilePath[ :shortFilePath.find(filename) ] + prefix + ".pkm"
						# print( "pathANDROID=" + pathANDROID )
						pathANDROIDALPHA = currentPath + "\\ios\\android\\" + shortFilePath[ :shortFilePath.find(filename) ] + prefix + "_alpha.pkm"
						# print( "pathANDROIDALPHA=" + pathANDROIDALPHA )
						
						if shortFilePath in dirAndroidDict.keys() and dirAndroidDict[ shortFilePath ] == "android":
							print( "does not has ios res" )
						else:			
							checkIfFileExistDelete( pathIOS )
							shutil.copy( pathPVRCCZ, pathIOS )

						checkIfFileExistDelete( pathANDROID )
						shutil.copy( pathPkm, pathANDROID )

						checkIfFileExistDelete( pathANDROIDALPHA )
						shutil.copy( pathAlphaPkm, pathANDROIDALPHA )
					else:
						#拼出ios路径
						pathIOS = currentPath + "\\ios\\" + shortFilePath
						# print( "pathIOS=" + pathIOS )
						#拼出ANDROID路径
						pathANDROID = currentPath + "\\ios\\android\\" + shortFilePath
						# print( "pathANDROID=" + pathANDROID )
						if shortFilePath in dirAndroidDict.keys() and dirAndroidDict[ shortFilePath ] == "android":
							print( "does not has ios res" )
						else:			
							checkIfFileExistDelete( pathIOS )
							shutil.copy( filePath, pathIOS )
						
						checkIfFileExistDelete( pathANDROID )
						shutil.copy( filePath, pathANDROID )
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

		if os.path.exists( currentPath + "\\out.plist" ):
			os.remove( currentPath + "\\out.plist" )

	if os.path.exists( tempPath ):
		shutil.rmtree( tempPath )

	print( "Finish!" )