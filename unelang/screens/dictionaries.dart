import 'package:flutter/material.dart';
import 'package:unelang_test/models/dictionaries.dart';

// https://api.flutter.dev/flutter/widgets/SliverAnimatedList-class.html
class Dictionaries extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: DictionariesState.getDictionariesFromMem(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      title: Text('Словари'),
                    ),
                    SliverToBoxAdapter(
                      child: ButtonArea(),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return DictionariesScrollVievElement(index);
                        },
                        childCount: DictionariesState.currentDictsList.length,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}


class ButtonArea extends StatelessWidget {
  const ButtonArea({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
            Container(
              margin: EdgeInsets.fromLTRB(8, 8, 1, 0),
              height: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    ),
                ),
                onPressed: () => Navigator.pushNamed(context, '/dictionaries_add'),
                child: Text('Добавить словарь'),
              ),
            ),
        ),
        Expanded(
          child:
            Container(
              margin: EdgeInsets.fromLTRB(1, 8, 8, 0),
              height: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    ),
                ),
                onPressed: () {},
                child: Text('Подписки'),
              ),
            ),
        ),
      ],
    );
  }
}


class DictionariesScrollVievElement extends StatelessWidget {
  final int index;

  const DictionariesScrollVievElement(this.index, { Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Container(
      height: 60,
      margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
      padding: EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DictionariesState.currentDictsList[index],
            style: const TextStyle(fontSize: 20)
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Подтверждение'),
                content: const Text('Вы действительно хотите удалить этот словать?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: Text('Cancel',
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () => {
                      Navigator.pop(context, 'Ok'),
                      DictionariesState.removeDictionary(DictionariesState.currentDictsList[index])
                    },
                    child: Text('Ok',
                      style: TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ), 
        ]
      ),
    );
  }
}//