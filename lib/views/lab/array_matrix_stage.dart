import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../curriculum/ch4_string_array_glist/array_matrix.dart';
import '../../engine/canvas/ds_stage_canvas.dart';
import '../../engine/vm/scene_interpolator.dart';
import '../../models/trace_model.dart';

class ArrayMatrixStage extends StatelessWidget {
  const ArrayMatrixStage({
    super.key,
    required this.input,
    required this.frame,
    required this.next,
    required this.progress,
    required this.onCell,
  });
  final MatrixInput input;
  final TraceFrame frame, next;
  final double progress;
  final void Function(int, int, int) onCell;
  @override
  Widget build(BuildContext context) {
    final sparse = input.mode == MatrixMode.transpose;
    final size = sparse
        ? Size(480, math.max(190, 80 + input.triples.length * 60.0))
        : Size(matrixWidth(input), matrixHeight(input));
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                frame.phaseTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(frame.explanation),
              if (sparse) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 6,
                    columnSpacing: 16,
                    headingRowHeight: 36,
                    dataRowMinHeight: 26,
                    dataRowMaxHeight: 40,
                    columns: [
                      const DataColumn(label: Text('列')),
                      for (final r in frame.scene.auxTables.first.rows)
                        DataColumn(label: Text(r[0])),
                    ],
                    rows: [
                      for (var k = 1; k <= 3; k++)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(frame.scene.auxTables.first.columns[k]),
                            ),
                            for (final r in frame.scene.auxTables.first.rows)
                              DataCell(
                                Text(
                                  r[k],
                                  style: TextStyle(
                                    fontWeight: r[0] == frame.inlineVars['col']
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                Text(
                  '原表检查次数  快速 ${frame.inlineVars["已检查原表项"]}　普通全程 ${frame.inlineVars["普通转置检查项"]}',
                ),
              ],
              SizedBox(
                height: (c.maxHeight - (sparse ? 230 : 80)).clamp(190.0, 580.0),
                child: DsStageCanvas(
                  key: ValueKey((
                    input.mode,
                    input.rows,
                    input.cols,
                    input.layers,
                  )),
                  scene: SceneInterpolator.lerp(
                    frame.scene,
                    next.scene,
                    progress,
                  ),
                  sceneSize: size,
                  onSelect: sparse
                      ? null
                      : (id) {
                          if (!id.startsWith('cell-')) return;
                          final p = id.split('-');
                          onCell(
                            int.parse(p[1]),
                            int.parse(p[2]),
                            int.parse(p[3]),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
