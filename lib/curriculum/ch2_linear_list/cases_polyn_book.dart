import '../../engine/vm/algorithm_module.dart';
import '../../models/trace_model.dart';
import 'polynomial_trace.dart';
import 'book_trace.dart';

enum CaseOperation { create, add, bookFind, bookInsert, bookDelete }

String numberText(double n) =>
    n.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

class PolyTerm {
  const PolyTerm(this.coefficient, this.exponent);
  final double coefficient;
  final int exponent;
  String get raw => '${numberText(coefficient)}:$exponent';
  String get label => '${numberText(coefficient)} · x^$exponent';
}

class BookRecord {
  const BookRecord(this.isbn, this.title, this.price);
  final String isbn, title;
  final double price;
  String get raw => '$isbn,$title,${numberText(price)}';
  String get label => '$isbn\n$title\n¥${price.toStringAsFixed(2)}';
}

class CasesInput {
  const CasesInput({
    this.operation = CaseOperation.add,
    this.a = const [
      PolyTerm(7, 0),
      PolyTerm(3, 1),
      PolyTerm(9, 8),
      PolyTerm(5, 17),
    ],
    this.b = const [PolyTerm(8, 1), PolyTerm(22, 7), PolyTerm(-9, 8)],
    this.books = const [
      BookRecord('DS01', '数据结构', 45),
      BookRecord('DS02', '算法基础', 52.5),
      BookRecord('DS03', '程序设计', 39),
    ],
    this.linked = true,
    this.position = 2,
    this.query = 'DS02',
    this.book = const BookRecord('DS04', '结构练习', 38),
  });
  final CaseOperation operation;
  final List<PolyTerm> a, b;
  final List<BookRecord> books;
  final bool linked;
  final int position;
  final String query;
  final BookRecord book;
  bool get isBook => operation.index >= CaseOperation.bookFind.index;
  CasesInput copyWith({
    CaseOperation? operation,
    bool? linked,
    List<BookRecord>? books,
    String? query,
  }) => CasesInput(
    operation: operation ?? this.operation,
    a: a,
    b: b,
    books: books ?? this.books,
    linked: linked ?? this.linked,
    position: position,
    query: query ?? this.query,
    book: book,
  );
  String get raw =>
      '${operation.name}|${linked ? 1 : 0}|$position|$query|${book.raw}|${books.map((v) => v.raw).join(';')}|${a.map((t) => t.raw).join(',')}|${b.map((t) => t.raw).join(',')}';
}

class CasesPolynBookModule implements AlgorithmModule<CasesInput> {
  const CasesPolynBookModule();
  @override
  String get id => 'ch2_cases_polyn_book';
  static const names = ['升序建多项式', '稀疏多项式相加', '图书按编号查找', '图书按位序插入', '图书按位序删除'];
  @override
  List<AlgorithmPreset<CasesInput>> get presets => const [
    AlgorithmPreset(
      id: 'add',
      name: '教材 · 9x^8 与 −9x^8 相消',
      input: CasesInput(),
    ),
    AlgorithmPreset(
      id: 'create',
      name: '建表 · 乱序指数 17,1,8,0',
      input: CasesInput(
        operation: CaseOperation.create,
        a: [PolyTerm(5, 17), PolyTerm(3, 1), PolyTerm(9, 8), PolyTerm(7, 0)],
      ),
    ),
    AlgorithmPreset(
      id: 'cancel',
      name: '边界 · 完全相消为空',
      input: CasesInput(
        a: [PolyTerm(2, 0), PolyTerm(3, 2)],
        b: [PolyTerm(-2, 0), PolyTerm(-3, 2)],
      ),
    ),
    AlgorithmPreset(
      id: 'empty',
      name: '边界 · A 为空',
      input: CasesInput(a: [], b: [PolyTerm(2, 5)]),
    ),
    AlgorithmPreset(
      id: 'both-empty',
      name: '边界 · 两多项式为空',
      input: CasesInput(a: [], b: []),
    ),
    AlgorithmPreset(
      id: 'book-insert',
      name: '图书 · 链式插入第二位',
      input: CasesInput(operation: CaseOperation.bookInsert),
    ),
    AlgorithmPreset(
      id: 'book-array',
      name: '对比 · 顺序插入第二位',
      input: CasesInput(operation: CaseOperation.bookInsert, linked: false),
    ),
    AlgorithmPreset(
      id: 'book-delete',
      name: '图书 · 删除唯一记录',
      input: CasesInput(
        operation: CaseOperation.bookDelete,
        books: [BookRecord('DS01', '数据结构', 45)],
        position: 1,
      ),
    ),
    AlgorithmPreset(
      id: 'book-miss',
      name: '查找 · 编号未命中',
      input: CasesInput(operation: CaseOperation.bookFind, query: 'NONE'),
    ),
    AlgorithmPreset(
      id: 'invalid',
      name: '边界 · 删除位序 0',
      input: CasesInput(operation: CaseOperation.bookDelete, position: 0),
    ),
  ];
  @override
  ValidationResult<CasesInput> validateInput(String raw) {
    final p = raw.split('|');
    if (p.length != 8) {
      return const ValidationResult.failure('输入字段不完整；标题与编号不能包含 |。');
    }
    final op = CaseOperation.values.where((v) => v.name == p[0]).firstOrNull;
    final pos = int.tryParse(p[2]);
    if (op == null ||
        !['0', '1'].contains(p[1]) ||
        pos == null ||
        pos < -1 ||
        pos > 10) {
      return const ValidationResult.failure('位序范围 −1～10，合法位序从 1 开始。');
    }
    List<PolyTerm>? terms(String raw) {
      if (raw.trim().isEmpty) return [];
      final result = <PolyTerm>[];
      for (final item in raw.split(RegExp(r'[,，;；]+'))) {
        final v = item.trim().split(':');
        if (v.length != 2) return null;
        final c = double.tryParse(v[0]), e = int.tryParse(v[1]);
        if (c == null ||
            !c.isFinite ||
            c == 0 ||
            c.abs() > 99 ||
            !RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(v[0].trim()) ||
            e == null ||
            e < 0 ||
            e > 99) {
          return null;
        }
        result.add(PolyTerm(c, e));
      }
      if (result.length > 6 ||
          result.map((t) => t.exponent).toSet().length != result.length) {
        return null;
      }
      return result;
    }

    BookRecord? book(String text) {
      final v = text.trim().split(RegExp(r'[,，]'));
      if (v.length != 3) return null;
      final price = double.tryParse(v[2]);
      final isbn = v[0].trim(), title = v[1].trim();
      if (!RegExp(r'^[A-Za-z0-9-]{1,16}$').hasMatch(isbn) ||
          title.isEmpty ||
          title.runes.length > 16 ||
          title.contains(RegExp(r'[;；\n\r]')) ||
          price == null ||
          !price.isFinite ||
          price < 0 ||
          price > 9999 ||
          !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(v[2].trim())) {
        return null;
      }
      return BookRecord(isbn, title, price);
    }

    final a = terms(p[6]), b = terms(p[7]), newBook = book(p[4]);
    final books = p[5].trim().isEmpty
        ? <BookRecord?>[]
        : p[5].split(';').map(book).toList();
    if (a == null || b == null) {
      return const ValidationResult.failure(
        '多项式每表最多 6 项：系数:指数。系数非零、绝对值≤99、最多两位小数；指数 0～99 且不重复。',
      );
    }
    if (op == CaseOperation.add) {
      bool sorted(List<PolyTerm> t) {
        for (var i = 1; i < t.length; i++) {
          if (t[i].exponent < t[i - 1].exponent) return false;
        }
        return true;
      }

      if (!sorted(a) || !sorted(b)) {
        return const ValidationResult.failure('相加要求两表各自按指数升序；乱序请先选择升序建表。');
      }
    }
    if (newBook == null ||
        books.any((b) => b == null) ||
        books.length > 8 ||
        books.map((b) => b?.isbn).toSet().length != books.length ||
        !RegExp(r'^[A-Za-z0-9-]{1,16}$').hasMatch(p[3])) {
      return const ValidationResult.failure(
        '图书最多 8 本、编号唯一（1～16 字母/数字/短横线）；书名 1～16 字，价格 0～9999、最多两位小数。格式：编号,书名,价格。',
      );
    }
    return ValidationResult.success(
      CasesInput(
        operation: op,
        a: a,
        b: b,
        books: books.cast<BookRecord>(),
        linked: p[1] == '1',
        position: pos,
        query: p[3],
        book: newBook,
      ),
    );
  }

  @override
  TraceTimeline generateTrace(CasesInput input) {
    if (!validateInput(input.raw).isValid) {
      throw ArgumentError('Invalid cases input');
    }
    return input.isBook
        ? generateBookTrace(input)
        : generatePolynomialTrace(input);
  }
}
