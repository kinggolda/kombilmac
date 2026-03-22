class SpreadsheetMatrix {
  SpreadsheetMatrix(List<List<String>> rows)
      : rows = rows
            .map(
              (row) => row.map((cell) => _normalizeCell(cell)).toList(growable: false),
            )
            .toList(growable: false);

  final List<List<String>> rows;

  int get rowCount => rows.length;

  int get columnCount {
    var max = 0;
    for (final row in rows) {
      if (row.length > max) {
        max = row.length;
      }
    }
    return max;
  }

  bool get isEmpty => rowCount == 0 || columnCount == 0;

  String cell(int row, int column) {
    if (row < 0 || row >= rows.length) {
      return '';
    }
    final currentRow = rows[row];
    if (column < 0 || column >= currentRow.length) {
      return '';
    }
    return currentRow[column];
  }

  SpreadsheetMatrix rectangular() {
    final width = columnCount;
    final padded = rows
        .map((row) {
          if (row.length == width) {
            return row;
          }
          final extended = <String>[...row];
          while (extended.length < width) {
            extended.add('');
          }
          return extended;
        })
        .toList(growable: false);

    return SpreadsheetMatrix(padded);
  }

  static String _normalizeCell(String input) {
    return input
        .replaceAll('\u00A0', ' ')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
  }
}

