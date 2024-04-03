import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

///where
/// = (equal)
/// like [%value] (*) [fadjksfjaklfjaklsjdfalsjfklsjfask|hello]
/// ilike [value%] (*) [hello|fafjdkasjfkjaskdfjalskfjkldsaf]
/// is null

const List<String> tableSql = [
  ///user
  '''
        Create table users (
          id integer primary key autoincrement,
          username varchar not null unique,
          password varchar not null
        );
      ''',

  ///posts
  '''
          Create table posts (

            id integer primary key autoincrement,
            user_id integer,
            content text not null,
            like_count integer default 0,
            share_count integer default 0,

            foreign key(user_id) references users(id)

          );
      ''',

  ///like posts
  '''
    Create table like_posts(
      
      id integer primary key autoincrement,
      user_id integer,
      post_id integer,

      foreign key(user_id) references users(id),
      foreign key(post_id) references posts(id) 

    );
  ''',

  ///share posts
  '''
    Create table share_posts(
      
      id integer primary key autoincrement,
      user_id integer,
      post_id integer,

      foreign key(user_id) references users(id),
      foreign key(post_id) references posts(id)

    );
  ''',
];

Future<void> seedData(Database db, int count) async {
  await seedUsers(db, count);
  await seedPosts(db, count);
  await seedLikePosts(db, count);
  await seedSharePosts(db, count);
}

Future<void> seedUsers(Database db, int count) async {
  await Future.wait(List.generate(count, (index) {
    return db.rawInsert(
      "insert into users(username,password) values (?,?)",
      [
        'user_${index + 1}',
        'root',
      ],
    );
  }));
}

Future<void> seedPosts(Database db, int count) async {
  await Future.wait(List.generate(count, (index) {
    return db.rawInsert(
      'insert into posts(user_id,content) values(?,?)',
      [
        Random.secure().nextInt(count) + 1,
        'Hello World! ${DateTime.now().toIso8601String()}_$index',
      ],
    );
  }));
}

///select column from table
///delete from table where

Future<void> seedLikePosts(Database db, int count) async {
  await Future.wait(List.generate(count, (index) {
    return db.rawInsert(
      'insert into like_posts(user_id,post_id) values(?,?)',
      [
        Random.secure().nextInt(count) + 1,
        Random.secure().nextInt(count) + 1,
      ],
    );
  }));
}

Future<void> seedSharePosts(Database db, int count) async {
  await Future.wait(List.generate(count, (index) {
    return db.rawInsert(
      'insert into share_posts(user_id,post_id) values(?,?)',
      [
        Random.secure().nextInt(count) + 1,
        Random.secure().nextInt(count) + 1,
      ],
    );
  }));
}

/// delete from table where id = ?
Future<void> deleteDataById(Database db, String tableName, int id) async {
  await db.rawDelete('delete from $tableName where id = ?', [id]);
}

///UPDATE tablename SET column = value
Future<void> updateDataById(Database db, int id) async {
  await db.rawUpdate(
    'Update posts set content=? where id=?',
    ['Update Data ${DateTime.now()}', id],
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Directory appDocDir = await getApplicationDocumentsDirectory();

  final File dbFile = File("${appDocDir.path}/test.db");

  if (!(await dbFile.exists())) {
    await dbFile.create();
  }

  // await deleteDatabase(dbFile.path);

  final Database db = await openDatabase(
    dbFile.path,
    version: 1,
    onCreate: (db, _) async {
      // primary key [not null,unique]
      await Future.wait(tableSql.map((query) {
        return db.execute(query);
      }));
    },
  );

  // await seedData(db, 100);
  // await seedPosts(db, 100);
  // await seedLikePosts(db, 100);
  // await seedSharePosts(db, 100);
  /// join,left join,right join
// ///select posts.id as post_id,users.id as user_id,like_posts.id as like_post_id,share_posts.id as share_post_id from posts
// join users on posts.user_id = users.id
// left join like_posts on posts.id = like_posts.post_id
// left join share_posts on posts.id = share_posts.post_id
// limit 1;

  final beforeResult = await db.rawQuery('''
  select * from posts where id=2 limit 1
''');

  print("Before: $beforeResult");

  await updateDataById(db, 2);

  // await deleteDataById(db, "posts", 1);

  final afterResult = await db.rawQuery('''
  select * from posts where id=2 limit 1
''');
  print("After: $afterResult");

  print(db);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
