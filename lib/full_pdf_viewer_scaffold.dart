import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_plugin.dart';

class PDFViewerScaffold extends StatefulWidget {
  final PreferredSizeWidget appBar;
  final String path;
  final bool primary;

  const PDFViewerScaffold({
    Key key,
    this.appBar,
    @required this.path,
    this.primary = true,
  }) : super(key: key);

  @override
  _PDFViewScaffoldState createState() => new _PDFViewScaffoldState();
}

class _PDFViewScaffoldState extends State<PDFViewerScaffold> {
  final pdfViwerRef = new PDFViewerPlugin();
  Rect _rect;
  Timer _resizeTimer;

  @override
  void initState() {
    super.initState();
    pdfViwerRef.close();
  }

  @override
  void dispose() {
    super.dispose();
    pdfViwerRef.close();
    pdfViwerRef.dispose();
  }

  void removeProfile(context) async {
    pdfViwerRef.resize(Rect.zero);
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Titulo'),
          content: Text('Contenido'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text('Confirmar'),
              onPressed: () async {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
    // pdfViwerRef.resize(_buildRect(context));
    if (confirm != null && confirm) {
      print('firmando...');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rect == null) {
      _rect = _buildRect(context);
      pdfViwerRef.launch(
        widget.path,
        rect: _rect,
      );
    } else {
      final rect = _buildRect(context);
      if (_rect != rect) {
        _rect = rect;
        _resizeTimer?.cancel();
        _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
          pdfViwerRef.resize(_rect);
        });
      }
    }
    return new Scaffold(
        appBar: AppBar(
          title: Text("Document"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => removeProfile(context),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0.0,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => print('hellow'),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: const Center(child: const CircularProgressIndicator()));
  }

  Rect _buildRect(BuildContext context) {
    final fullscreen = false;

    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    final top = fullscreen ? 0.0 : 56.0 + topPadding;
    final bottomPadding = widget.primary ? mediaQuery.padding.bottom : 0.0;
    final bottom = fullscreen ? 0.0 : 56.0 + bottomPadding;
    var height = mediaQuery.size.height - (top + bottom);
    if (height < 0.0) {
      height = 0.0;
    }

    return new Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }
}
