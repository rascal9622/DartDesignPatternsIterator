import 'package:flutter/material.dart';
import 'dart:collection';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: IteratorExample(),
        ),
      ),
    );
  }
}

class Graph {
  final Map<int, Set<int>> adjacencyList = Map<int, Set<int>>();
  
  void addEdge(int source, int target) {
    if (adjacencyList.containsKey(source)) {
      adjacencyList[source].add(target);
    } else {
      adjacencyList[source] = {target};
    }
  }
}

abstract class ITreeCollection {
  ITreeIterator createIterator();
  String getTitle();
}

class DepthFirstTreeCollection implements ITreeCollection {
  final Graph graph;
  
  const DepthFirstTreeCollection(this.graph);
  
  @override
  ITreeIterator createIterator() {
    return DepthFirstIterator(this);
  }
  
  @override
  String getTitle() {
    return 'Depth-first';
  }
}

class BreadthFirstTreeCollection implements ITreeCollection {
  final Graph graph;
  
  const BreadthFirstTreeCollection(this.graph);
  
  @override
  ITreeIterator createIterator() {
    return BreadthFirstIterator(this);
  }
  
  @override
  String getTitle() {
    return 'Breadth-first';
  }
}

abstract class ITreeIterator {
  bool hasNext();
  int getNext();
  void reset();
}

class DepthFirstIterator implements ITreeIterator {
  final DepthFirstTreeCollection treeCollection;
  final Set<int> visitedNodes = <int>{};
  final ListQueue<int> nodeStack = ListQueue<int>();
  
  final int _initialNode = 1;
  int _currentNode;
  
  DepthFirstIterator(this.treeCollection) {
    _currentNode = _initialNode;
    nodeStack.add(_initialNode);
  }
  
  Map<int, Set<int>> get adjacencyList => treeCollection.graph.adjacencyList;
  
  @override
  bool hasNext() {
    return nodeStack.isNotEmpty;
  }
  
  @override
  int getNext() {
    if (!hasNext()) {
      return null;
    }
    
    _currentNode = nodeStack.removeLast();
    visitedNodes.add(_currentNode);
    
    if (adjacencyList.containsKey(_currentNode)) {
      for (var node in adjacencyList[_currentNode]
          .where((n) => !visitedNodes.contains(n))) {
        nodeStack.addLast(node);
      }
    }
  
    return _currentNode;
  }
  
  @override
  void reset() {
    _currentNode = _initialNode;
    visitedNodes.clear();
    nodeStack.clear();
    nodeStack.add(_initialNode);
  }
}

class BreadthFirstIterator implements ITreeIterator {
  final BreadthFirstTreeCollection treeCollection;
  final Set<int> visitedNodes = <int>{};
  final ListQueue<int> nodeQueue = ListQueue<int>();
  
  final int _initialNode = 1;
  int _currentNode;
  
  BreadthFirstIterator(this.treeCollection) {
    _currentNode = _initialNode;
    nodeQueue.add(_initialNode);
  }
  
  Map<int, Set<int>> get adjacencyList => treeCollection.graph.adjacencyList;
  
  @override
  bool hasNext() {
    return nodeQueue.isNotEmpty;
  }
  
  @override
  int getNext() {
    if (!hasNext()) {
      return null;
    }
    
    _currentNode = nodeQueue.removeFirst();
    visitedNodes.add(_currentNode);
    
    if (adjacencyList.containsKey(_currentNode)) {
      for (var node in adjacencyList[_currentNode]
        .where((n) => !visitedNodes.contains(n))) {
        nodeQueue.addLast(node);
      }
    }
    
    return _currentNode;
  }
  
  @override
  void reset() {
    _currentNode = _initialNode;
    visitedNodes.clear();
    nodeQueue.clear();
    nodeQueue.add(_initialNode);
  }
}

class IteratorExample extends StatefulWidget {
  @override
  _IteratorExampleState createState() => _IteratorExampleState();
}

class _IteratorExampleState extends State<IteratorExample> {
  final List<ITreeCollection> treeCollections = List<ITreeCollection>();
  
  int _selectedTreeCollectionIndex = 0;
  int _currentNodeIndex = 0;
  bool _isTraversing = false;
  
  @override
  void initState() {
    super.initState();
    
    var graph = _buildGraph();
    treeCollections.add(BreadthFirstTreeCollection(graph));
    treeCollections.add(DepthFirstTreeCollection(graph));
  }
  
  Graph _buildGraph() {
    var graph = Graph();
    
    graph.addEdge(1, 2);
    graph.addEdge(1, 3);
    graph.addEdge(1, 4);
    graph.addEdge(2, 5);
    graph.addEdge(3, 6);
    graph.addEdge(3, 7);
    graph.addEdge(4, 8);
    
    return graph;
  }
  
  void _setSelectedTreeCollectionIndex(int index) {
    setState(() {
      _selectedTreeCollectionIndex = index;
    });
  }
  
  Future _traverseTree() async {
    _toggleIsTraversing();
    
    var iterator = treeCollections[_selectedTreeCollectionIndex].createIterator();
    
    while (iterator.hasNext()) {
      setState(() {
        _currentNodeIndex = iterator.getNext();
      });
      
      await Future.delayed(const Duration(seconds: 1));
    }
    
    _toggleIsTraversing();
  }
  
  void _toggleIsTraversing() {
    setState(() {
      _isTraversing = !_isTraversing;
    });
  }
  
  void _reset() {
    setState(() {
      _currentNodeIndex = 0;
    });
  }
  
  Color _getBackgroundColor(int index) {
    return _currentNodeIndex == index ? Colors.red[800] : Colors.white;
  }
  
  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: <Widget>[
            TreeCollectionSelection(
              treeCollections: treeCollections,
              selectedIndex: _selectedTreeCollectionIndex,
              onChanged: !_isTraversing ? _setSelectedTreeCollectionIndex : null,
            ),
            const SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  child: const Text('Traverse'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                  ),
                  onPressed: _currentNodeIndex == 0 ? _traverseTree : null,
                ),
                ElevatedButton(
                  child: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                  ),
                  onPressed: _isTraversing || _currentNodeIndex == 0 ? null : _reset,
                ),
              ]
            ),
            const SizedBox(height: 10.0),
            Box(
              nodeId: 1,
              color: _getBackgroundColor(1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Box(
                    nodeId: 2,
                    color: _getBackgroundColor(2),
                    child: Box(
                      nodeId: 5,
                      color: _getBackgroundColor(5),
                    ),
                  ),
                  Box(
                    nodeId: 3,
                    color: _getBackgroundColor(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Box(
                          nodeId: 6,
                          color: _getBackgroundColor(6),
                        ),
                        Box(
                          nodeId: 7,
                          color: _getBackgroundColor(7),
                        )
                      ]
                    ),
                  ),
                  Box(
                    nodeId: 4,
                    color: _getBackgroundColor(4),
                    child: Box(
                      nodeId: 8,
                      color: _getBackgroundColor(8),
                    )
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}

class TreeCollectionSelection extends StatelessWidget {
  final List<ITreeCollection> treeCollections;
  final int selectedIndex;
  final ValueSetter<int> onChanged;
  
  const TreeCollectionSelection({
    @required this.treeCollections,
    @required this.selectedIndex,
    @required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i=0; i<treeCollections.length; i++)
          RadioListTile(
            title: Text(treeCollections[i].getTitle()),
            value: i,
            groupValue: selectedIndex,
            selected: i == selectedIndex,
            activeColor: Colors.black,
            controlAffinity: ListTileControlAffinity.platform,
            onChanged: onChanged,
          )
      ]
    );
  }
}

class Box extends StatelessWidget {
  final int nodeId;
  final Color color;
  final Widget child;
  
  const Box({
    @required this.nodeId,
    @required this.color,
    this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: color,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: <Widget>[
            Text(
              nodeId.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 3.0),
            if (child != null) child,
          ]
        )
      )
    );
  }
}
