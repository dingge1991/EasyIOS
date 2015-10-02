//
//  YHDB.h
//
//  Created by wenyihong on 15/6/4.
//  Copyright (c) 2015年 yh. All rights reserved.
//

#import "FMDatabase.h"

@interface YHDB : FMDatabaseQueue

/**
 *  0 create path in document with a database name
 *
 *  @param name   0.a database:ever name you like
 *                  1.many databases:advise to use userId
 */
+ (void)createDB:(NSString *)name;

/**
 *  1 create singleton
 *
 *  @return singleton
 */
+ (YHDB *)share;

/**
 *  2 set singleton = nil
 *
 *  @return result
 */
+ (void)shareRelease;

/**
 *  3 create table
 *
 *  @param modelDic @{model : primarykey}
 *
 *  @return result of create
 */
+ (void)createTB:(NSDictionary *)modelDic;

/**
 *  4 auto match to update or insert the data of a model or models which you input
 *
 *  @param modelArray NSArray of model has value
 *  @param primaryKey table has primary key ? primaryKey = a key from model : nil;
 *  @param whereDic   if primary key == nil, then you need to input a whereDic{key0 : value0, key1 : value1, ...} to select the data in table which equal to the data you input and then the method will delele the data in table and insert you data
 *  @param whereInDic if primary key == nil, like param "whereDic"
 */
+ (void)save:(NSArray *)modelArray
  primaryKey:(NSString *)primaryKey
       where:(NSDictionary *)whereDic
     whereIn:(NSDictionary *)whereInDic;

/**
 *  5 insert data into table
 *
 *  @param model [[Model alloc] init]
 *
 *  @return result of insert
 */
+(BOOL)insert:(id)model;

/**
 *  6 delete data from table
 *
 *  @param model      [[Model alloc] init]
 *  @param whereDic   like sql 'where whereDic.key = whereDic.value'
 *  @param whereInDic like sql 'where whereInDic.allKeys[0] in (whereInDic.allValues[0])'
 *
 *  @return rusult of delete
 */
+ (BOOL)delete:(id)model
where:(NSDictionary *)whereDic
whereIn:(NSDictionary *)whereInDic;

/**
 *  7 update table
 *
 *  @param model           [[Model alloc] init]
 *  @param tbModel         model select from table，if you just want to update,you do not mind the data has change or not.
 *  @param whereArray      whereArray
 *
 *  @return result of update
 */
+(BOOL)update:(id)model
      tbModel:(id)tbModel
   whereArray:(NSArray *)whereArray;

/**
 *  8 select data from table
 *
 *  @param model      [[Model alloc] init]
 *  @param whereDic   like sql 'where whereDic.key = whereDic.value'
 *  @param whereInDic like sql 'where whereInDic.allKeys[0] in (whereInDic.allValues[0])'
 *  @param orderByDic {"ASC||DESC" : "condition of order by"}
 *  @param groupByDic {"GROUP BY" : "condition of group by"}
 *  @param limitDic   {@(start) : @(count)}
 *
 *  @return modelArray with data
 */
+ (NSMutableArray *)select:(id)model
                     where:(NSDictionary *)whereDic
                   whereIn:(NSDictionary *)whereInDic
                   orderBy:(NSDictionary *)orderByDic
                   groupBy:(NSDictionary *)groupByDic
                     limit:(NSDictionary *)limitDic;

/**
 *  9 select data from table with sql
 *
 *  @param model [[Model alloc] init]
 *  @param sql   sql
 *
 *  @return modelArray with data
 */
+ (NSMutableArray *)select:(id)model sql:(NSString *)sql;

/**
 *  10 select primaryKey exist in table and primaryKeyArray
 *
 *  @param primaryKey      primaryKey
 *  @param model           [[Model alloc] init]
 *  @param primaryKeyArray primaryKeyArray
 *
 *  @return array of primaryKey exist in table and primaryKeyArray
 */
+ (NSMutableArray *)selectPrimaryKey:(NSString *)primaryKey
                                from:(id)model
                   wherePrimaryKeyIn:(NSArray *)primaryKeyArray;

/**
 *  11 select count from table
 *
 *  @param model    [[Model alloc] init]
 *  @param whereDic like sql 'where whereDic.key = whereDic.value'
 *
 *  @return count of table
 */
+ (int)selectCount:(id)model
          whereDic:(NSDictionary *)whereDic;

@end