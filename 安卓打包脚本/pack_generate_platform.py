#!/usr/bin/python
#coding=utf-8

import os
import sys
import hashlib
import time
import codecs


webAddress = sys.argv[ 1 ]


#准备数据
#当前路径
currentPathDir = os.getcwd()
#print( currentPathDir )


#获得绝对路径
targetFileLocate = currentPathDir + "\\pack_temp_platform.lua"
#print( "targetFileLocate:"+targetFileLocate )

#判断是否存在目标文件configLocalText.txt
if os.path.exists( targetFileLocate ):
    #如果存在，删除
	os.remove( targetFileLocate )

#创建文件，打开
targetFile = codecs.open( targetFileLocate, 'w', "UTF-8" )

#生成内容
targetFile.write( "local data = {\n" )
targetFile.write( "\tchannel = 1,\n" )

targetFile.write( "\tweb = \"" + webAddress + "\",\n" )

targetFile.write( "\tdownloadUrl = \"http://192.168.2.171/upload/hqfy_local/\",\n" )
targetFile.write( "\tactive = 0\n" )
targetFile.write( "}\n" )
targetFile.write( "return data\n" )


targetFile.close()