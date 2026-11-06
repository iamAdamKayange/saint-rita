import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An animated, pseudo-3D figure of St. Rita of Cascia in her Augustinian
/// habit: black veil and habit, white wimple, holding a crucifix and a rose.
///
/// Depth comes from two effects combined:
///  * a perspective transform that turns the whole figure slightly, and
///  * parallax: every layer (halo, veil, face, hands) moves by a different
///    amount depending on how far "in front" it is, with the light shifting
///    across the habit as she turns.
///
/// Drag horizontally to turn her. Animation stops when the system asks for
/// reduced motion.
class AnimatedNun3D extends StatefulWidget {
  const AnimatedNun3D({
    super.key,
    this.height = 240,
    this.showPetals = true,
    this.interactive = true,
  });

  final double height;
  final bool showPetals;
  final bool interactive;

  @override
  State<AnimatedNun3D> createState() => _AnimatedNun3DState();
}

class _AnimatedNun3DState extends State<AnimatedNun3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  double _dragYaw = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_relaxDrag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _relaxDrag() {
    // Ease back to the idle sway after the user lets go.
    if (!_dragging && _dragYaw.abs() > .001) _dragYaw *= .94;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height;
    final width = height * 2 / 3;

    Widget figure = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final idleYaw = math.sin(t * 2 * math.pi) * .32;
        final yaw = (idleYaw + _dragYaw).clamp(-.85, .85);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0013)
            ..rotateY(yaw * .45),
          child: CustomPaint(
            size: Size(width, height),
            painter: _NunPainter(
              t: t,
              yaw: yaw,
              showPetals: widget.showPetals,
            ),
          ),
        );
      },
    );

    if (widget.interactive) {
      figure = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => _dragging = true,
        onHorizontalDragUpdate: (details) {
          _dragYaw = (_dragYaw + details.delta.dx * .012).clamp(-.85, .85);
          if (!_controller.isAnimating) setState(() {});
        },
        onHorizontalDragEnd: (_) => _dragging = false,
        onHorizontalDragCancel: () => _dragging = false,
        child: figure,
      );
    }

    return Semantics(
      label: 'St. Rita of Cascia',
      image: true,
      child: RepaintBoundary(
        child: SizedBox(width: width, height: height, child: figure),
      ),
    );
  }
}

class _Petal {
  const _Petal(this.x, this.phase, this.speed, this.z, this.spin);
  final double x;
  final double phase;
  final double speed;
  final double z; // -1 (behind) .. 1 (in front)
  final double spin;
}

final List<_Petal> _petals = () {
  final random = math.Random(22); // St. Rita's feast day: 22 May.
  return List.generate(16, (_) {
    return _Petal(
      random.nextDouble() * 190 - 95,
      random.nextDouble(),
      .6 + random.nextDouble() * .8,
      random.nextDouble() * 2 - 1,
      random.nextDouble() * 2 - 1,
    );
  });
}();

class _NunPainter extends CustomPainter {
  _NunPainter({required this.t, required this.yaw, required this.showPetals});

  final double t;
  final double yaw;
  final bool showPetals;

  static const _habitLight = Color(0xFF4A5366);
  static const _habitMid = Color(0xFF1C212C);
  static const _habitDark = Color(0xFF07090D);
  static const _linen = Color(0xFFFAFBFC);
  static const _linenShade = Color(0xFFC9D2DC);
  static const _skin = Color(0xFFF6D9C6);
  static const _skinShade = Color(0xFFD7A68B);
  static const _gold = Color(0xFFE3C07A);
  static const _goldDeep = Color(0xFF9C6E2E);
  static const _rose = Color(0xFFD9445E);
  static const _roseLight = Color(0xFFF28DA2);

  // Design space is 200 x 300 with x = 0 at the centre line.
  double _px(double depth) => yaw * depth * 18;

  double get _phase => t * 2 * math.pi;
  double get _bob => math.sin(_phase * 2) * 1.8;
  double get _breath => 1 + math.sin(_phase * 2 + .6) * .012;

  @override
  void paint(Canvas canvas, Size size) {
    // 300 units of figure plus headroom so the halo never clips.
    final scale = size.height / 312;
    canvas.save();
    canvas.translate(size.width / 2, 0);
    canvas.scale(scale);
    canvas.translate(0, 10);

    _paintShadow(canvas);
    if (showPetals) _paintPetals(canvas, front: false);
    _paintHalo(canvas);

    // Breathing: a gentle vertical swell anchored at the feet.
    canvas.save();
    canvas.translate(0, 288);
    canvas.scale(1, _breath);
    canvas.translate(0, -288);
    _paintVeilBack(canvas);
    _paintHabit(canvas);
    _paintBib(canvas);
    _paintHead(canvas);
    _paintSleevesAndHands(canvas);
    canvas.restore();

    if (showPetals) _paintPetals(canvas, front: true);
    canvas.restore();
  }

  void _paintShadow(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: .22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_px(-.2), 289),
        width: 150 - _bob * 2,
        height: 16,
      ),
      paint,
    );
  }

  void _paintHalo(Canvas canvas) {
    final center = Offset(_px(-1.1), 64 + _bob);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          _gold.withValues(alpha: .55),
          _gold.withValues(alpha: .18),
          _gold.withValues(alpha: 0),
        ],
        stops: const [.35, .7, 1],
      ).createShader(Rect.fromCircle(center: center, radius: 66));
    canvas.drawCircle(center, 66, glow);

    // Slowly turning rays.
    final rays = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;
    for (var i = 0; i < 24; i++) {
      final angle = _phase * .25 + i * math.pi / 12;
      final long = i.isEven;
      const inner = 47.0;
      final outer = long ? 62.0 : 55.0;
      rays.color = _gold.withValues(alpha: long ? .45 : .28);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        rays,
      );
    }

    // The ring is an ellipse that narrows as she turns: reads as a 3D disc.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..shader = const LinearGradient(
        colors: [_gold, Color(0xFFFFF1C9), _goldDeep],
      ).createShader(Rect.fromCircle(center: center, radius: 46));
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: 92 * (1 - yaw.abs() * .22),
        height: 92,
      ),
      ring,
    );

    // Twinkle.
    final twinkle = (math.sin(_phase * 3) + 1) / 2;
    final sparkle = Paint()..color = Colors.white.withValues(alpha: .4 + twinkle * .5);
    final sparkleAt = center + Offset(math.cos(_phase) * 46, math.sin(_phase) * 46);
    canvas.drawCircle(sparkleAt, 1.6 + twinkle * 1.4, sparkle);
  }

  Shader _clothShader(Rect bounds, {double shift = 0}) {
    // The lit side follows the turn: turning right lights the left side.
    final light = (.38 - yaw * .35 + shift).clamp(.08, .8);
    return LinearGradient(
      colors: const [_habitLight, _habitMid, _habitDark],
      stops: [0, light, 1],
    ).createShader(bounds);
  }

  void _paintVeilBack(Canvas canvas) {
    final dx = _px(-.55);
    final dy = _bob * .7;
    final path = Path()
      ..moveTo(dx - 36, 40 + dy)
      ..quadraticBezierTo(dx, 14 + dy, dx + 36, 40 + dy)
      ..cubicTo(dx + 62, 74 + dy, dx + 74, 146, dx + 70, 214)
      ..quadraticBezierTo(dx, 224, dx - 70, 214)
      ..cubicTo(dx - 74, 146, dx - 62, 74 + dy, dx - 36, 40 + dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..shader = _clothShader(path.getBounds(), shift: -.08),
    );
  }

  void _paintHabit(Canvas canvas) {
    final dx = _px(0);
    final path = Path()
      ..moveTo(dx - 44, 106)
      ..quadraticBezierTo(dx, 94, dx + 44, 106)
      ..cubicTo(dx + 62, 170, dx + 78, 236, dx + 86, 287)
      ..quadraticBezierTo(dx, 296, dx - 86, 287)
      ..cubicTo(dx - 78, 236, dx - 62, 170, dx - 44, 106)
      ..close();
    final bounds = path.getBounds();
    canvas.drawPath(path, Paint()..shader = _clothShader(bounds));

    // Folds, with a soft highlight that slides as she turns.
    final fold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final x in [-46.0, -20.0, 8.0, 34.0, 58.0]) {
      final fx = dx + x + _px(.12);
      final lit = (1 - ((x / 60) + yaw).abs()).clamp(0.0, 1.0);
      fold.color = Colors.white.withValues(alpha: .03 + lit * .07);
      canvas.drawPath(
        Path()
          ..moveTo(fx * .55, 196)
          ..quadraticBezierTo(fx * .85, 240, fx, 286),
        fold,
      );
    }

    // Black leather belt of the Augustinian habit.
    final belt = Paint()
      ..color = Colors.black.withValues(alpha: .55)
      ..strokeWidth = 3.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(dx - 55, 204)
        ..quadraticBezierTo(dx + _px(.2), 212, dx + 55, 204),
      belt,
    );
  }

  void _paintBib(Canvas canvas) {
    final dx = _px(.28);
    final dy = _bob * .5;
    final path = Path()
      ..moveTo(dx - 25, 90 + dy)
      ..cubicTo(dx - 34, 104 + dy, dx - 44, 122, dx - 40, 132)
      ..quadraticBezierTo(dx, 150, dx + 40, 132)
      ..cubicTo(dx + 44, 122, dx + 34, 104 + dy, dx + 25, 90 + dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_linen, _linenShade],
        ).createShader(path.getBounds()),
    );
  }

  void _paintHead(Canvas canvas) {
    final dy = _bob;
    // Hood of the veil framing the face.
    final hoodCenter = Offset(_px(.2), 64 + dy);
    final hood = Rect.fromCenter(center: hoodCenter, width: 74, height: 86);
    canvas.drawOval(hood, Paint()..shader = _clothShader(hood, shift: -.05));

    // White wimple.
    final wimpleCenter = Offset(_px(.35), 68 + dy);
    final wimple = Rect.fromCenter(
      center: wimpleCenter,
      width: 58 * (1 - yaw.abs() * .08),
      height: 70,
    );
    canvas.drawOval(
      wimple,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(-yaw * .9, -.2),
          radius: .9,
          colors: const [_linen, _linenShade],
        ).createShader(wimple),
    );

    // Face, narrowing slightly as it turns away.
    final faceCenter = Offset(_px(.55), 70 + dy);
    final face = Rect.fromCenter(
      center: faceCenter,
      width: 40 * (1 - yaw.abs() * .12),
      height: 50,
    );
    canvas.drawOval(
      face,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(-.25 - yaw * .7, -.35),
          radius: 1,
          colors: const [_skin, _skinShade],
        ).createShader(face),
    );

    // Forehead band of the wimple.
    canvas.drawArc(
      Rect.fromCenter(center: faceCenter.translate(0, 2), width: 44, height: 54),
      math.pi * 1.12,
      math.pi * .76,
      false,
      Paint()
        ..color = _linen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Features ride in front of the face surface (extra parallax).
    final f = Offset(_px(.75), 70 + dy);
    final line = Paint()
      ..color = const Color(0xFF5B3A2C)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;

    // Peaceful closed eyes.
    for (final side in [-1.0, 1.0]) {
      final eye = f.translate(side * 8.2, -2);
      canvas.drawArc(
        Rect.fromCenter(center: eye, width: 9, height: 5),
        .15,
        math.pi - .3,
        false,
        line,
      );
      canvas.drawLine(
        eye.translate(-4, -6.5),
        eye.translate(4, -7.2 + side * .2),
        line..color = const Color(0xFF8A6450),
      );
      line.color = const Color(0xFF5B3A2C);
    }

    // Nose and gentle smile.
    canvas.drawLine(f.translate(.5, 2), f.translate(-.5, 8), line..strokeWidth = 1);
    canvas.drawArc(
      Rect.fromCenter(center: f.translate(0, 12.5), width: 9, height: 4.5),
      .2,
      math.pi - .4,
      false,
      line
        ..color = const Color(0xFFB3505A)
        ..strokeWidth = 1.5,
    );

    // Blush.
    final blush = Paint()
      ..color = _rose.withValues(alpha: .16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawCircle(f.translate(-11, 7), 4, blush);
    canvas.drawCircle(f.translate(11, 7), 4, blush);

    // The thorn wound on her forehead, her best-known sign.
    final wound = Paint()
      ..color = const Color(0xFF9E1F33)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.3;
    canvas.drawLine(f.translate(5.5, -15), f.translate(7, -12.5), wound);
  }

  void _paintSleevesAndHands(Canvas canvas) {
    final dx = _px(.9);

    // Wide habit sleeves meeting in front of the chest.
    for (final side in [-1.0, 1.0]) {
      final sleeve = Path()
        ..moveTo(_px(0) + side * 44, 110)
        ..cubicTo(
          _px(0) + side * 66,
          150,
          dx + side * 58,
          190,
          dx + side * 30,
          200,
        )
        ..lineTo(dx + side * 8, 190)
        ..cubicTo(
          dx + side * 16,
          170,
          _px(0) + side * 28,
          148,
          _px(0) + side * 30,
          122,
        )
        ..close();
      canvas.drawPath(
        sleeve,
        Paint()..shader = _clothShader(sleeve.getBounds(), shift: side * .1),
      );
    }

    // Crucifix held upright.
    final crossTop = Offset(dx + _px(.15), 136);
    final crossPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF2D592), _goldDeep],
      ).createShader(Rect.fromLTWH(crossTop.dx - 12, 136, 24, 64))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.2;
    canvas.drawLine(crossTop, crossTop.translate(0, 62), crossPaint);
    canvas.drawLine(
      crossTop.translate(-12, 15),
      crossTop.translate(12, 15),
      crossPaint,
    );
    canvas.drawCircle(
      crossTop.translate(0, 15),
      9,
      Paint()
        ..color = _gold.withValues(alpha: .25 + (math.sin(_phase * 2) + 1) * .1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Hands clasped around the cross.
    for (final side in [-1.0, 1.0]) {
      final hand = Rect.fromCenter(
        center: Offset(dx + side * 6.5, 184),
        width: 13,
        height: 17,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(hand, const Radius.circular(6.5)),
        Paint()
          ..shader = LinearGradient(
            colors: side < 0
                ? const [_skin, _skinShade]
                : const [_skinShade, _skin],
          ).createShader(hand),
      );
    }

    // A rose, the saint's emblem, resting in her hands.
    _paintRose(canvas, Offset(dx - 17, 196), 7.5);
  }

  void _paintRose(Canvas canvas, Offset center, double radius) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + 2, center.dy + 4)
        ..quadraticBezierTo(center.dx + 10, center.dy + 18, center.dx + 4, center.dy + 26),
      Paint()
        ..color = const Color(0xFF3F7A4A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawCircle(center, radius, Paint()..color = _rose);
    final swirl = Paint()
      ..color = _roseLight.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 3; i++) {
      final r = radius * (.75 - i * .22);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        i * 1.9 + _phase * .1,
        math.pi * 1.3,
        false,
        swirl,
      );
    }
  }

  void _paintPetals(Canvas canvas, {required bool front}) {
    for (final petal in _petals) {
      if ((petal.z >= 0) != front) continue;
      final progress = (t * petal.speed * 2 + petal.phase) % 1;
      final y = 290 - progress * 300;
      final sway = math.sin(_phase * 2 + petal.phase * 9) * 9;
      final x = petal.x + sway + _px(petal.z * 1.6);
      final depthScale = 1 + petal.z * .35;
      final fade = math.sin(progress * math.pi);
      final paint = Paint()
        ..color = Color.lerp(_rose, _roseLight, (petal.z + 1) / 2)!
            .withValues(alpha: fade * (front ? .85 : .5));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(petal.spin * _phase * 2 + petal.phase * 6);
      // Squash on one axis to fake a tumbling petal.
      canvas.scale(1, .45 + .55 * math.cos(_phase * 3 + petal.phase * 7).abs());
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 7 * depthScale, height: 4.5 * depthScale),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_NunPainter old) =>
      old.t != t || old.yaw != yaw || old.showPetals != showPetals;
}
