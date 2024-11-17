import 'package:flutter/material.dart';
import 'package:unelang_test/models/dictionaries.dart';


class DictionariesAdd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: DictionariesState.getDictionariesFromCloud(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      title: Text('Добавление словаря'),
                    ),
                    SliverToBoxAdapter(
                      child: SearchArea(),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return DictionariesScrollVievElement(index);
                        },
                        childCount: DictionariesState.availDictsList.length,
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


class SearchArea extends StatelessWidget {
  const SearchArea({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        onPressed: () {},
        child: Text('Search'),
      ),
    );
  }
}


class DictionariesScrollVievElement extends StatelessWidget {
  final int index;

  const DictionariesScrollVievElement(this.index, { Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final dictName = DictionariesState.availDictsList[index];
      final isInProgress = DictionariesState.isInProgress(dictName);
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
          Text(DictionariesState.availDictsList[index],
            style: const TextStyle(fontSize: 20)
          ),
          IconButton(
            icon: isInProgress ? Icon(Icons.download_done) : Icon(Icons.download),
            onPressed: () => {DictionariesState.setupDictionary(dictName)},
          ), 
        ]
      ),
    );
  }
}//