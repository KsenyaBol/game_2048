import 'package:flutter/material.dart';
import 'package:game_2048/model.dart';
import 'package:game_2048/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game 2048',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(child: BoardWidget()),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({required this.state, super.key});

  final _BoardWidgetState state;

  @override
  Widget build(BuildContext context) {
    final boardSize = MediaQuery.sizeOf(context);
    final width = boardSize.width;
    // (boardSize.width - (state._column + 1) * state.tilePadding) / state._column
    final backgroundBox = <TileBox>[];
    for (var r = 0; r < state._row; ++r) {
      for (var c = 0; c < state._column; ++c) {
        backgroundBox.add(
          TileBox(
            left: c * width * state.tilePadding * (c + 1),
            top: r * width * state.tilePadding * (r + 1),
            size: width,
            color: Colors.grey.shade300,
            text: '',
          ),
        );
      }
    }

    return Positioned.fill(
      left: 0,
      top: 0,
      child: Stack(
        children: backgroundBox,
      ),
    );
  }
}

class BoardWidget extends StatefulWidget {
  const BoardWidget({super.key});

  @override
  _BoardWidgetState createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  late Board _board;
  late int _row;
  late int _column;
  late bool _isMoving;
  late bool _gameOver;
  double tilePadding = 5;

  @override
  void initState() {
    super.initState();

    _row = 4;
    _column = 4;
    _isMoving = false;
    _gameOver = false;

    _board = Board(_row, _column);
    newGame();
  }

  void newGame() {
    setState(() {
      _board.initBoard();
      _gameOver = false;
    });
  }

  void gameOver() {
    setState(() {
      if (_board.gameOver()) {
        _gameOver = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tileWidgets = <TileWidget>[];

    for (var r = 0; r < _row; ++r) {
      for (var c = 0; c < _column; ++c) {
        tileWidgets.add(TileWidget(tile: _board.getTile(r, c), state: this));
      }
    }
    final children = <Widget>[MyHomePage(state: this), ...tileWidgets];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              color: Colors.orange.shade100,
              width: 120,
              height: 60,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Score: '),
                    Text(_board.score.toString()),
                  ],
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: const ContinuousRectangleBorder(),
                backgroundColor: Colors.transparent,
              ),
              onPressed: newGame,
              child: Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  color: Colors.orange.shade100,
                ),
                child: const Center(
                  child: Text('New game', style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
          child: Opacity(
            opacity: _gameOver ? 1.0 : 0.0,
            child: const Center(
              child: Text('Game Over'),
            ),
          ),
        ),
        SizedBox.square(
          dimension: MediaQuery.sizeOf(context).width,
          child: GestureDetector(
            onVerticalDragUpdate: (detail) {
              if (detail.delta.distance == 0 || _isMoving) {
                return;
              }
              _isMoving = true;
              if (detail.delta.direction < 0) {
                setState(() {
                  _board.moveUp();
                  gameOver();
                });
              } else {
                setState(() {
                  _board.moveDown();
                  gameOver();
                });
              }
            },
            onVerticalDragEnd: (d) {
              _isMoving = false;
            },
            onVerticalDragCancel: () {
              _isMoving = false;
            },
            onHorizontalDragUpdate: (detail) {
              if (detail.delta.distance == 0 || _isMoving) {
                return;
              }
              _isMoving = true;
              if (detail.delta.direction > 0) {
                setState(() {
                  _board.moveLeft();
                  gameOver();
                });
              } else {
                setState(() {
                  _board.moveRight();
                  gameOver();
                });
              }
            },
            onHorizontalDragEnd: (d) {
              _isMoving = false;
            },
            onHorizontalDragCancel: () {
              _isMoving = false;
            },
            child: Stack(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class TileWidget extends StatefulWidget {
  const TileWidget({required this.tile, required this.state, super.key});

  final Tile tile;
  final _BoardWidgetState state;

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    widget.tile.isTileNew = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.isTileNew && !widget.tile.isEmpty()) {
      _controller
        ..reset()
        ..forward();
      widget.tile.isTileNew = false;
    } else {
      _controller.animateTo(1);
    }

    return AnimatedTileWidget(
      tile: widget.tile,
      state: widget.state,
      animation: _animation,
    );
  }
}

class AnimatedTileWidget extends AnimatedWidget {
  const AnimatedTileWidget({required this.tile, required this.state, required Animation<double> animation, super.key})
      : super(listenable: animation);
  final Tile tile;
  final _BoardWidgetState state;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final animationValue = animation.value;
    final boardSize = MediaQuery.sizeOf(context);
    final width = (boardSize.width - (state._column + 1) * state.tilePadding) / state._column;

    if (tile.value == 0) {
      return const SizedBox();
    } else {
      return TileBox(
        left: (tile.column * width + state.tilePadding * (tile.column + 1)) + width / 2 * (1 - animationValue),
        top: tile.row * width + state.tilePadding * (tile.row + 1) + width / 2 * (1 - animationValue),
        size: width * animationValue,
        color: (tileColors.containsKey(tile.value) ? tileColors[tile.value] : Colors.black)!,
        text: '${tile.value}',
      );
    }
  }
}

class TileBox extends StatelessWidget {
  const TileBox({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.text,
    super.key,
  });

  final double left;
  final double top;
  final double size;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
