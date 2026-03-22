import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'tela_video_model.dart';
export 'tela_video_model.dart';

class TelaVideoWidget extends StatefulWidget {
  const TelaVideoWidget({super.key});

  static String routeName = 'telaVideo';
  static String routePath = '/telaVideo';

  @override
  State<TelaVideoWidget> createState() => _TelaVideoWidgetState();
}

class _TelaVideoWidgetState extends State<TelaVideoWidget> {
  late TelaVideoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TelaVideoModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryText,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.CustomVidPlayer(
                width: double.infinity,
                height: double.infinity,
                videoPath: 'https://live.brascast.com/player/gente8322',
                playPauseVideoAction: true,
                autoPlay: true,
                looping: false,
                showControls: true,
                allowFullScreen: true,
                allowPlayBackSpeedChanging: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
