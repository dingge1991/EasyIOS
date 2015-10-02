//
//  YHDB.m
//
//  Created by wenyihong on 15/6/4.
//  Copyright (c) 2015年 yh. All rights reserved.
//

#import "YHDB.h"
#import <objc/runtime.h>

static YHDB *yhDB = nil;

@implementation YHDB

/**
 *  0 create path in document with a database name
 *
 *  @param name   0.a database:ever name you like
 *                  1.many databases:advise to use userId
 */
+ (void)createDB:(NSString *)name {
    if ([YHDB createFinderInDocumentWithFinderName:name]) {
        NSString *dBPath = [name stringByAppendingPathComponent:[name stringByAppendingString:@".db"]];
        [self userDefaultsSetObject:dBPath forKey:@"YHDBPATH"];
    }
    [self share];
}

/**
 *  1 create singleton
 *
 *  @return singleton
 */
+ (YHDB *)share {
    @synchronized(self) {
        if (!yhDB) {
            yhDB = [[YHDB alloc] initWithPath:[[self documentPath] stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] objectForKey:@"YHDBPATH"]]];
#if DEBUG
            NSLog(@"\n[YHDB Path]\n%@\n", yhDB.path);
#endif
        }
        return yhDB;
    }
}

/**
 *  2 set singleton = nil
 *
 *  @return result
 */
+ (void)shareRelease {
    if (yhDB) {
        yhDB = nil;
#if DEBUG
        NSLog(@"[YHDB Release]");
#endif
    }
}

/**
 *  3 create table
 *
 *  @param modelDic @{model : primarykey}
 *
 *  @return result of create
 */
+ (void)createTB:(NSDictionary *)modelDic {
    __weak __typeof(self)weakSelf = self;
    [[YHDB share] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [modelDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *sql = [strongSelf sqlOfCreateTB:key primaryKey:obj];
            BOOL result = [db executeUpdate:sql];
#if DEBUG
            NSString *log = result ? @"\n[YHDB CreateTBSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB CreateTBFailed]\n%@\n",sql];
            NSLog(@"%@",log);
#endif
        }];
    }];
}

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
     whereIn:(NSDictionary *)whereInDic {
    if (modelArray.count > 0) {
        if (modelArray.count == 1) {
            [self save:modelArray primaryKey:primaryKey];
        }
        else {
            if (primaryKey) {
                //全部主键
                NSMutableArray *allPkMArray = [self getPkArrayFromModelArray:modelArray
                                                                  primaryKey:primaryKey];
                //表中存在的主键:1条sql
                NSArray *updatePkArray = [self selectPrimaryKey:primaryKey
                                                           from:[modelArray lastObject]
                                              wherePrimaryKeyIn:allPkMArray];
                //如果存在更新的行
                if (updatePkArray.count > 0) {
                    NSMutableDictionary *KT_Dic = [self getKeysAndTypesFromModel:[modelArray lastObject]];
                    NSDictionary *whereIn = [NSDictionary dictionaryWithObject:updatePkArray forKey:primaryKey];
                    //表中存在的行
                    NSMutableArray *updataModelMArray = [self select:[modelArray lastObject]
                                                               where:nil
                                                             whereIn:whereIn
                                                             orderBy:nil
                                                             groupBy:nil
                                                               limit:nil];
                    __block BOOL haveUpdate;
                    NSMutableArray *modelMArray = [NSMutableArray arrayWithArray:modelArray];
                    __weak __typeof(self)weakSelf = self;
                    [[YHDB share] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        [modelMArray enumerateObjectsUsingBlock:^(id obj0, NSUInteger idx0, BOOL *stop0) {
                            haveUpdate = NO;
                            [updataModelMArray enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
                                if ([KT_Dic[primaryKey] isEqualToString:@"integer"] || [KT_Dic[primaryKey] isEqualToString:@"real"]) {
                                    if ([obj0 valueForKey:primaryKey] == [obj1 valueForKey:primaryKey]) {
                                        haveUpdate = YES;
                                    }
                                }
                                if ([KT_Dic[primaryKey] isEqualToString:@"text"]) {
                                    if ([[obj0 valueForKey:primaryKey] isEqualToString:[obj1 valueForKey:primaryKey]]) {
                                        haveUpdate = YES;
                                    }
                                }
                                if (haveUpdate) {
                                    NSString *sql = [strongSelf sqlOfUpdate:obj0
                                                                    tbModel:obj1
                                                                 whereArray:@[primaryKey]];
                                    if (sql.length > 0) {
                                        BOOL result = [db executeUpdate:sql];
#if DEBUG
                                        NSString *log = result ? @"\n[YHDB UpdateSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB UpdateFailed]\n%@\n",sql];
                                        NSLog(@"%@",log);
#endif
                                    }
                                    *stop1 = YES;
                                }
                            }];
                            if (!haveUpdate) {
                                NSString *sql = [strongSelf sqlOfInsert:obj0];
                                BOOL result = [db executeUpdate:sql];
#if DEBUG
                                NSString *log = result ? @"\n[YHDB InsertSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB InsertFailed]\n%@\n",sql];
                                NSLog(@"%@",log);
#endif
                            }
                        }];
                    }];
                }
                else {//全部都是插入
                    __weak __typeof(self)weakSelf = self;
                    [[YHDB share] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        [modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString *sql = [strongSelf sqlOfInsert:obj];
                            BOOL result = [db executeUpdate:sql];
#if DEBUG
                            NSString *log = result ? @"\n[YHDB InsertSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB InsertFailed]\n%@\n",sql];
                            NSLog(@"%@",log);
#endif
                        }];
                    }];
                }
            }
            else {//无主键:先删后插
                [self delete:[modelArray lastObject] where:whereDic whereIn:whereInDic];
                __weak __typeof(self)weakSelf = self;
                [[YHDB share] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    [modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *sql = [strongSelf sqlOfInsert:obj];
                        BOOL result = [db executeUpdate:sql];
#if DEBUG
                        NSString *log = result ? @"\n[YHDB InsertSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB InsertFailed]\n%@\n",sql];
                        NSLog(@"%@",log);
#endif
                        
                    }];
                }];
            }
        }
    }
}

/**
 * save one model
 */
+ (void)save:(NSArray *)modelArray
  primaryKey:(NSString *)primaryKey {
    id model = [modelArray lastObject];
    id value = [model valueForKey:primaryKey];
    if (value) {
        NSDictionary *whereDic = @{primaryKey : value};
        //表中存在的行
        NSMutableArray *updataModelMArray = [self select:model
                                                   where:whereDic
                                                 whereIn:nil
                                                 orderBy:nil
                                                 groupBy:nil
                                                   limit:nil];
        if (updataModelMArray.count > 0) {
            [self update:model tbModel:[updataModelMArray lastObject] whereArray:@[primaryKey]];
        }
        else {
            [self insert:model];
        }
    }
}

/**
 *  5 insert data into table
 *
 *  @param model [[Model alloc] init]
 *
 *  @return result of insert
 */
+(BOOL)insert:(id)model {
    __block BOOL result;
    NSString *sql = [self sqlOfInsert:model];
    
    [[YHDB share] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
        
    }];
#if DEBUG
    NSString *log = result ? @"\n[YHDB InsertSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB InsertFailed]\n%@\n",sql];
    NSLog(@"%@",log);
#endif
    return result;
}

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
       whereIn:(NSDictionary *)whereInDic {
    NSMutableDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    NSString *whereString = [self where:whereDic KT_Dic:KT_Dic];
    NSString *whereInString = [self whereIn:whereInDic KT_Dic:KT_Dic];
    NSString *sql= [NSString stringWithFormat:@"DELETE FROM %@ %@%@", [self tableName:model], whereString, whereInString];
    __block BOOL result;
    
    [[YHDB share] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sql];
    }];
#if DEBUG
    NSString *log = result ? @"\n[YHDB DeleteSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB DeleteFailed]\n%@\n",sql];
    NSLog(@"%@",log);
#endif
    return result;
}

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
   whereArray:(NSArray *)whereArray {
    __block BOOL result;
    NSString *sql = [self sqlOfUpdate:model tbModel:tbModel whereArray:whereArray];
    if (sql.length > 0) {
        [[YHDB share] inDatabase:^(FMDatabase *db) {
            result = [db executeUpdate:sql];
        }];
    }
#if DEBUG
    NSString *log = result ? @"\n[YHDB UpdateSucceed]\n" : [NSString stringWithFormat:@"\n[YHDB UpdateFailed]\n%@\n",sql];
    NSLog(@"%@",log);
#endif
    return result;
}

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
                     limit:(NSDictionary *)limitDic {
    __block id modelCopy;
    NSMutableArray *modelMArray = [NSMutableArray array];
    NSMutableDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    NSString *whereString = [self where:whereDic KT_Dic:KT_Dic];
    NSString *whereInString = [self whereIn:whereInDic KT_Dic:KT_Dic];
    NSString *orderByString = [NSString string];
    NSString *groupByString = [NSString string];
    NSString *limitString = [NSString string];
    
    //ORDER BY字典:ORDER BY ? ASC||DESC
    if (orderByDic && orderByDic.count == 1) {
        orderByString = [NSString stringWithFormat:@"ORDER BY %@ %@", [orderByDic.allValues[0]  componentsJoinedByString:@","], orderByDic.allKeys[0]];
    }
    
    if (groupByDic && groupByDic.count == 1) {
        groupByString = [NSString stringWithFormat:@"GROUP BY  %@", [groupByDic.allValues[0] componentsJoinedByString:@","]];
    }
    if (limitDic) {
        limitString = [NSString stringWithFormat:@"LIMIT %@, %@", limitDic.allKeys[0], limitDic.allValues[0]];
    }
    //查询所有字段:SELECT * FROM TABLENAME
    NSMutableString *sql= [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ %@ %@ %@ %@ %@", [KT_Dic.allKeys componentsJoinedByString:@", "], [self tableName:model], whereString, whereInString, orderByString, groupByString, limitString];
    
    [[YHDB share] inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:sql];
#if DEBUG
        if (!rs) {
            NSLog(@"\n[YHDB SelectFailed]\n%@\n", rs.query);
        }
#endif
        while ([rs next]) {
            modelCopy = [[[model class] alloc]init];
            [KT_Dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([KT_Dic[key] isEqualToString:@"text"]) {
                    [modelCopy setValue:[rs stringForColumn:key] forKey:key];
                }
                if ([KT_Dic[key] isEqualToString:@"integer"]) {
                    [modelCopy setValue:@([rs intForColumn:key]) forKey:key];
                }
                if ([KT_Dic[key] isEqualToString:@"real"]) {
                    [modelCopy setValue:@([rs doubleForColumn:key]) forKey:key];
                }
            }];
            [modelMArray addObject:modelCopy];
        }
        [rs close];
    }];
    return modelMArray;
}

/**
 *  9 select data from table with sql
 *
 *  @param model [[Model alloc] init]
 *  @param sql   sql
 *
 *  @return modelArray with data
 */
+ (NSMutableArray *)select:(id)model sql:(NSString *)sql {
    __block id modelCopy;
    NSMutableArray *modelMArray = [NSMutableArray array];
    NSMutableDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    [[YHDB share] inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:sql];
#if DEBUG
        if (!rs) {
            NSLog(@"\n[YHDB SelectFailed]\n%@\n", rs.query);
        }
#endif
        while ([rs next]) {
            modelCopy = [[[model class] alloc]init];
            [KT_Dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([KT_Dic[key] isEqualToString:@"text"]) {
                    [modelCopy setValue:[rs stringForColumn:key] forKey:key];
                }
                if ([KT_Dic[key] isEqualToString:@"integer"]) {
                    [modelCopy setValue:@([rs intForColumn:key]) forKey:key];
                }
                if ([KT_Dic[key] isEqualToString:@"real"]) {
                    [modelCopy setValue:@([rs doubleForColumn:key]) forKey:key];
                }
            }];
            [modelMArray addObject:modelCopy];
        }
        [rs close];
    }];
    return modelMArray;
}

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
                   wherePrimaryKeyIn:(NSArray *)primaryKeyArray {
    __block NSMutableArray *marray = [NSMutableArray array];
    NSDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    
    NSMutableArray *inArray = [NSMutableArray array];
    [primaryKeyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [inArray addObject:[NSString stringWithFormat:@" %@ ", [self dbValue:obj type:KT_Dic[primaryKey]]]];
    }];
    NSString *primaryKeyString = [inArray componentsJoinedByString:@","];
    
    NSMutableString *sql= [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ in (%@)", primaryKey, [self tableName:model], primaryKey, primaryKeyString];
    [[YHDB share] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
#if DEBUG
        if (!rs) {
            NSLog(@"\n[YHDB SelectFailed]\n%@\n", rs.query);
        }
#endif
        if ([KT_Dic[primaryKey] isEqualToString:@"integer"]) {
            while ([rs next]) {
                [marray addObject:@([rs intForColumn:primaryKey])];
            }
        }
        if ([KT_Dic[primaryKey] isEqualToString:@"real"]) {
            while ([rs next]) {
                [marray addObject:@([rs doubleForColumn:primaryKey])];
            }
        }
        if ([KT_Dic[primaryKey] isEqualToString:@"text"]) {
            while ([rs next]) {
                [marray addObject:[rs stringForColumn:primaryKey]];
            }
        }
    }];
    return marray;
}

/**
 *  11 select count from table
 *
 *  @param model    [[Model alloc] init]
 *  @param whereDic like sql 'where whereDic.key = whereDic.value'
 *
 *  @return count of table
 */
+ (int)selectCount:(id)model
          whereDic:(NSDictionary *)whereDic {
    __block int count;
    NSDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    NSString *whereString = [self where:whereDic KT_Dic:KT_Dic];
    
    NSString *sql= [NSString stringWithFormat:@"SELECT COUNT(1) AS count FROM %@ %@", [self tableName:model], whereString];
    
    [[YHDB share] inDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:sql];
#if DEBUG
        if (!rs) {
            NSLog(@"\n[YHDB SelectFailed]\n%@\n", rs.query);
        }
#endif
        while ([rs next]) {
            count = [rs intForColumn:@"count"];
        }
        [rs close];
    }];
    return count;
}

#pragma utils
+ (void)userDefaultsSetObject:(id)obj forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)createFinderInDocumentWithFinderName:(NSString *)finderName {
    NSString *finderPath = [[self documentPath] stringByAppendingPathComponent:finderName];
    if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:finderPath])
    {
        return [[NSFileManager defaultManager] createDirectoryAtPath:finderPath
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:NULL];
    }
    return NO;
}

+ (NSString *)documentPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(NSString *)tableName:(id)model {
    return NSStringFromClass([model class]);
}

+ (NSMutableDictionary *)getKeysAndTypesFromModel:(id)model {
    NSMutableDictionary *keysAndTypesDic = [[[NSUserDefaults standardUserDefaults] objectForKey:[self tableName:model]] mutableCopy];
    if (keysAndTypesDic) {
        return keysAndTypesDic;
    }
    else {
        return [self getAllPropertyNamesAndTypesOfObject:model];
    }
}

//得到实体的Key和类型
+ (NSMutableDictionary *)getAllPropertyNamesAndTypesOfObject:(id)model {
    unsigned int outCount, i;
    NSMutableArray *propertyName = [NSMutableArray array];
    NSMutableArray *propertyType = [NSMutableArray array];
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    
    for (i=0; i<outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *name = [NSString stringWithCString:propName
                                                encoding:[NSString defaultCStringEncoding]];
            NSString *type = [self translateToDBType:[NSString stringWithCString:propType
                                                                        encoding:[NSString defaultCStringEncoding]]];
            [propertyName addObject:name];
            [propertyType addObject:type];
            if (type.length == 0) {
                NSLog(@"YHDB Warning:(Property Type Warning)YHDB have not type of '%s' in property:'%@'",propType, name);
            }
        }
    }
    free(properties);
    NSMutableDictionary *namesAndTypesDic = [NSMutableDictionary dictionaryWithObjects:propertyType forKeys:propertyName];
    [self userDefaultsSetObject:namesAndTypesDic forKey:[self tableName:model]];
    return namesAndTypesDic;
}

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

+ (NSString *)translateToDBType:(NSString *)modelType {
    if ([modelType hasPrefix:@"NSString"]){
        return @"text";
    }
    if ([modelType isEqualToString:@"i"] || [modelType isEqualToString:@"q"] || [modelType isEqualToString:@"B"]){
        return @"integer";
    }
    if ([modelType isEqualToString:@"d"]) {
        return @"real";
    }
    return @"";
}

//返回实体数组的所有主键
+ (NSMutableArray *)getPkArrayFromModelArray:(NSArray *)modelArray primaryKey:(NSString *)primaryKey {
    NSMutableArray *pkArray = [NSMutableArray array];
    [modelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [pkArray addObject:[obj valueForKey:primaryKey]];
    }];
    return pkArray;
}

+ (NSString *)dbValue:(id)value type:(id)type {
    if ([type isEqualToString:@"text"]) {
        return [NSString stringWithFormat:@" '%@' ",value];
    }
    if ([type isEqualToString:@"integer"] || [type isEqualToString:@"real"]) {
        return [NSString stringWithFormat:@" %@ ",value];
    }
    return @"";
}

+ (NSMutableString *)mergeSqlString:(NSMutableString *)superString subString:(NSString *)subString withString:(NSString *)withString {
    if (superString.length > 0) {
        [superString appendFormat:@"%@ %@", withString, subString];
    }
    else {
        [superString appendFormat:@"%@", subString];
    }
    return superString;
}

+ (NSString *)sqlOfCreateTB:(id)model primaryKey:(NSString *)primaryKey {
    NSMutableDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    NSMutableString *memberString = primaryKey.length > 0 ? [[NSString stringWithFormat:@"%@ %@ PRIMARY KEY", primaryKey, KT_Dic[primaryKey]] mutableCopy] : @"id integer PRIMARY KEY AUTOINCREMENT";
    if (primaryKey.length > 0) {
        [KT_Dic removeObjectForKey:primaryKey];
    }
    [KT_Dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [memberString appendFormat:@",%@ %@", key, obj];
    }];
    NSString *sql=[NSString stringWithFormat:@"CREATE TABLE if not exists %@ (%@)", [self tableName:model], memberString];
    return sql;
}

+ (NSString *)sqlOfInsert:(id)model {
    NSMutableDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    __block NSMutableString *keyString = [NSMutableString string];
    __block NSMutableString *objString = [NSMutableString string];
    __weak __typeof(self)weakSelf = self;
    [KT_Dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        id value = [model valueForKey:key];
        keyString = [strongSelf mergeSqlString:keyString subString:key withString:@","];
        objString = value ? [strongSelf mergeSqlString:objString subString:[self dbValue:value type:obj] withString:@","] : [strongSelf mergeSqlString:objString subString:@"''" withString:@","];
    }];
    NSMutableString *sql= [NSMutableString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", [self tableName:model], keyString, objString];
    return sql;
}

+(NSString *)sqlOfUpdate:(id)model
                 tbModel:(id)tbModel
              whereArray:(NSArray *)whereArray {
    NSMutableDictionary *KT_Dic = [self getKeysAndTypesFromModel:model];
    __block NSMutableString *memberString = [NSMutableString string];
    __weak __typeof(self)weakSelf = self;
    //有变化才更新
    if (tbModel) {
        [KT_Dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            id value = [model valueForKey:key];
            id tbValue = [tbModel valueForKey:key];
            if (value) {
                BOOL hasUpdate = NO;
                if ([obj isEqualToString:@"integer"] || [obj isEqualToString:@"real"]) {
                    if (![value isEqualToNumber:tbValue]) {
                        hasUpdate = YES;
                    }
                }
                else if ([obj isEqualToString:@"text"]) {
                    if (![value isEqualToString:tbValue]) {
                        hasUpdate = YES;
                    }
                }
                if (hasUpdate) {
                    NSString *subString = [NSString stringWithFormat:@" %@ = %@ ", key, [self dbValue:[model valueForKey:key] type:obj]];
                    memberString = [strongSelf mergeSqlString:memberString subString:subString withString:@","];
                }
            }
        }];
    }
    //有没有变化都更新
    else {
        [KT_Dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            id value = [model valueForKey:key];
            if (value) {
                NSString *subString = [NSString stringWithFormat:@" %@ = %@ ", key, [self dbValue:[model valueForKey:key] type:obj]];
                memberString = [strongSelf mergeSqlString:memberString subString:subString withString:@","];
            }
        }];
    }
    if (memberString.length > 0) {
        NSString *sql;
        __block NSMutableString *whereString = [NSMutableString string];
        if (whereArray) {
            [whereArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                NSString *subString = [NSString stringWithFormat:@" %@ = %@ ", obj, [self dbValue:[model valueForKey:obj] type:KT_Dic[obj]]];
                whereString = [strongSelf mergeSqlString:whereString subString:subString withString:@"AND"];
            }];
        }
        sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ %@", [self tableName:model], memberString, whereString];
        return sql;
    }
    return @"";
}

+ (NSString *)where:(NSDictionary *)whereDic KT_Dic:(NSDictionary *)KT_Dic {
    //WHERE字典:WHERE ? = ?
    if (whereDic) {
        __block NSMutableString *whereString = [NSMutableString string];
        __weak __typeof(self)weakSelf = self;
        [whereDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            NSString *subString = [NSString stringWithFormat:@" %@ = %@ ", key, [self dbValue:obj type:KT_Dic[key]]];
            whereString = [strongSelf mergeSqlString:whereString subString:subString withString:@"AND"];
        }];
        return whereString;
    }
    return @"";
}

+ (NSString *)whereIn:(NSDictionary *)whereInDic KT_Dic:(NSDictionary *)KT_Dic {
    //WHERE IN (?)
    if (whereInDic && whereInDic.count == 1) {
        __block NSMutableString *whereInString = [NSMutableString string];
        __block NSMutableString *inString = [NSMutableString string];
        __weak __typeof(self)weakSelf = self;
        [whereInDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]) {
                NSArray *objArray = obj;
                [objArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    NSString *subString = [NSString stringWithFormat:@" %@ ", [self dbValue:obj type:KT_Dic[key]]];
                    inString = [strongSelf mergeSqlString:inString subString:subString withString:@","];
                }];
            }
        }];
        whereInString = [NSMutableString stringWithFormat:@"WHERE %@ IN (%@)", whereInDic.allKeys[0], inString];
        return whereInString;
    }
    return @"";
}

@end