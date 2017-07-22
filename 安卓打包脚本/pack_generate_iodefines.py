#!/usr/bin/python
#coding=utf-8

import os
import sys
import hashlib
import time
import codecs

print( sys.argv )

connectWay = sys.argv[ 1 ]
serverIP = ""
portID = ""
uid = ""

if connectWay == "server":
	serverIP = sys.argv[ 2 ]
	portID = sys.argv[ 3 ]
	uid = sys.argv[ 4 ]

#准备数据
#当前路径
currentPathDir = os.getcwd()
#print( currentPathDir )


#获得绝对路径
targetFileLocate = currentPathDir + "\\pack_temp_IODefines.lua"
#print( "targetFileLocate:"+targetFileLocate )

#判断是否存在目标文件configLocalText.txt
if os.path.exists( targetFileLocate ):
    #如果存在，删除
	os.remove( targetFileLocate )

#创建文件，打开
targetFile = codecs.open( targetFileLocate, 'w', "UTF-8" )

#生成内容
targetFile.write( "IODefines = {\n" )

if connectWay == "server":
	targetFile.write( "\tserver_ip = \"" + serverIP + "\",\n" )
	targetFile.write( "\tserver_port = " + portID + ",\n" )
	targetFile.write( "\tuid = \"" + uid + "\",\n" )
	targetFile.write( "\tconectNet = true,\n" )
else:
	targetFile.write( "\tserver_ip = \"ship.gz.1251006671.clb.myqcloud.com\",\n" )
	targetFile.write( "\tserver_port = 443,\n" )
	targetFile.write( "\tuid = \"72620548286727538\",\n" )
	targetFile.write( "\tconectNet = false,\n" )


targetFile.write( "\tsecret = \"8613910246800\",\n" )
targetFile.write( "\tregion = \"1\",\n" )
targetFile.write( "\topenkey = \"\",\n" )
targetFile.write( "\tisUpdate = false,\n" )
targetFile.write( "\tsite = 0,\n" )
targetFile.write( "\tstats_server = \"\",\n" )
targetFile.write( "\tcoin_server = \"\",\n" )
targetFile.write( "\tcoinserver = \"\",\n" )
targetFile.write( "\tres_base = \"http://192.168.0.128:9888/\",\n" )
targetFile.write( "\trc4KeyData = { sid = \"\", logintime = 0, level = 1 },\n" )
targetFile.write( "}\n" )


targetFile.close()