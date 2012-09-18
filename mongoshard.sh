#!/bin/sh

## 以下の設定でMongoDBのシャーディング環境を起動させます
## localhost:10000 => mongos  
## localhost:10001 => config  
## localhost:10010 => shard0(shard0000)  
## localhost:10011 => shard1(shard0001)  
## localhost:10012 => shard2(shard0002)  

MONGOHOME=/usr/local/mongodb-2.2
TMP=/tmp/mongodb

mkdir -p $TMP/log
mkdir -p $TMP/config
mkdir -p $TMP/shard0
mkdir -p $TMP/shard1
mkdir -p $TMP/shard2

## shardサーバ起動
$MONGOHOME/bin/mongod --shardsvr --port 10010 --dbpath $TMP/shard0 --logpath $TMP/log/shard0.log --rest --fork;
$MONGOHOME/bin/mongod --shardsvr --port 10011 --dbpath $TMP/shard1 --logpath $TMP/log/shard1.log --rest --fork;
$MONGOHOME/bin/mongod --shardsvr --port 10012 --dbpath $TMP/shard2 --logpath $TMP/log/shard2.log --rest --fork;

## configサーバ起動
$MONGOHOME/bin/mongod --configsvr --port 10001 --dbpath $TMP/config --logpath $TMP/log/config.log --rest --fork;

## mongosサーバ起動
$MONGOHOME/bin/mongos --configdb localhost:10001 --port 10000 --logpath $TMP/log/mongos.log --chunkSize 1 --fork;

## 起動確認
ps axu |grep [m]ongo |grep -v [m]ongoshard
ps axu |grep [m]ongo |grep -v [m]ongoshard | wc -l ## 5だったら成功

## addShard
mkdir $TMP/js

echo "db.runCommand( { addshard : 'localhost:10010' } );" >>  $TMP/js/addshard.js
echo "db.runCommand( { addshard : 'localhost:10011' } );" >>  $TMP/js/addshard.js
echo "db.runCommand( { addshard : 'localhost:10012' } );" >>  $TMP/js/addshard.js

## データのinsert、Index作成
echo "for(var i=1; i<=100000; i++) db.logs.insert({'uid':i, 'value':Math.floor(Math.random()*100000+1)});" >>  $TMP/js/insert.js
echo "db.logs.ensureIndex( { 'uid' : 1 } );" >>  $TMP/js/insert.js

## enablesharding
echo "db.runCommand( { enablesharding : 'logdb' });" >>  $TMP/js/enablesharding.js
echo "db.runCommand( { shardcollection : 'logdb.logs' , key : { uid : 1 } } );" >>  $TMP/js/enablesharding.js


## 実行
$MONGOHOME/bin/mongo localhost:10000/admin  $TMP/js/addshard.js
$MONGOHOME/bin/mongo localhost:10000/logdb  $TMP/js/insert.js
$MONGOHOME/bin/mongo localhost:10000/admin  $TMP/js/enablesharding.js

echo ""
echo "==== Setting is done ===="
echo "Please check your Sharding Status after connecting to mongos."
echo ""
echo "         $ mongo localhost:10000/admin"
echo "         mongos> db.printShardingStatus();"
echo ""
