import 'dart:math' show Random;

class Board {
  Board(this.row, this.column);

  final int row;
  final int column;
  late int score;

  List<List<Tile>> _boardTiles = [];

  void initBoard() {
    _boardTiles = List.generate(
      4,
      (r) => List.generate(
        4,
        (c) => Tile(
          row: r,
          column: c,
          isTileNew: false,
          canMerge: false,
        ),
      ),
    );

    score = 0;
    resetCanMerge();
    randomEmptyTile();
    randomEmptyTile();
  }

  void moveLeft() {
    if (!canMoveLeft()) {
      return;
    }

    for (var r = 0; r < row; ++r) {
      for (var c = 0; c < column; ++c) {
        mergeLeft(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveRight() {
    if (!canMoveRight()) {
      return;
    }

    for (var r = 0; r < row; ++r) {
      for (var c = column - 2; c >= 0; --c) {
        mergeRight(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveUp() {
    if (!canMoveUp()) {
      return;
    }

    for (var r = 0; r < row; ++r) {
      for (var c = 0; c < column; ++c) {
        mergeUp(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  void moveDown() {
    if (!canMoveDown()) {
      return;
    }

    for (var r = row - 2; r >= 0; --r) {
      for (var c = 0; c < column; ++c) {
        mergeDown(r, c);
      }
    }
    randomEmptyTile();
    resetCanMerge();
  }

  bool canMoveLeft() {
    for (var r = 0; r < row; ++r) {
      for (var c = 1; c < column; ++c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r][c - 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveRight() {
    for (var r = 0; r < row; ++r) {
      for (var c = column - 2; c >= 0; --c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r][c + 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveUp() {
    for (var r = 1; r < row; ++r) {
      for (var c = 0; c < column; ++c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r - 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveDown() {
    for (var r = row - 2; r >= 0; --r) {
      for (var c = 0; c < column; ++c) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r + 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  void mergeLeft(int row, int col) {
    var c = col;
    while (c > 0) {
      merge(_boardTiles[row][c], _boardTiles[row][c - 1]);
      c--;
    }
  }

  void mergeRight(int row, int col) {
    var c = col;
    while (c < column - 1) {
      merge(_boardTiles[row][c], _boardTiles[row][c + 1]);
      c++;
    }
  }

  void mergeUp(int row, int col) {
    var r = row;
    while (r > 0) {
      merge(_boardTiles[r][col], _boardTiles[r - 1][col]);
      r--;
    }
  }

  void mergeDown(int r, int col) {
    while (r < row - 1) {
      merge(_boardTiles[r][col], _boardTiles[r + 1][col]);
      r++;
    }
  }
  bool canMerge(Tile a, Tile b) {
    return !a.canMerge && ((b.isEmpty() && !a.isEmpty()) || (!a.isEmpty() && a == b));
  }

  void merge(Tile a, Tile b) {
    if (!canMerge(a, b)) {
      if (!a.isEmpty() && !b.canMerge) {
        b.canMerge = true;
      }
      return;
    }

    if (b.isEmpty()) {
      b.value = a.value;
      a.value = 0;
    } else if (a == b) {
      b.value = b.value * 2;
      a.value = 0;
      score += b.value;
      b.canMerge = true;
    } else {
      b.canMerge = true;
    }
  }

  bool gameOver() {
    return !canMoveLeft() && !canMoveRight() && !canMoveUp() && !canMoveDown();
  }

  Tile getTile(int row, int column) {
    return _boardTiles[row][column];
  }

  void randomEmptyTile() {
    final empty = <Tile>[];

    for (final rows in _boardTiles) {
      empty.addAll(rows.where((tile) => tile.isEmpty()));
    }

    if (empty.isEmpty) {
      return;
    }

    final rng = Random();
    final index = rng.nextInt(empty.length);
    empty[index].value = rng.nextInt(9) == 0 ? 4 : 2;
    empty[index].isTileNew = true;
    empty.removeAt(index);
  }

  void resetCanMerge() {
    for (final rows in _boardTiles) {
      for (final tile in rows) {
        tile.canMerge = false;
      }
    }
  }
}

class Tile {
  Tile({required this.row, required this.column, required this.canMerge, required this.isTileNew, this.value = 0});

  int row;
  int column;
  int value;
  bool canMerge;
  bool isTileNew;

  bool isEmpty() {
    return value == 0;
  }

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is Tile && value == other.value;
  }
}
