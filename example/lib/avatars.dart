import 'dart:math';

import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

class Avatar {
  const Avatar(this.initials, this.color);
  final String initials;
  final Color color;
}

String getInitials(int index) {
  return String.fromCharCode(65 + (index % 26 + 1));
}

Color getColor(int index) {
  return Colors.primaries[index % Colors.primaries.length].shade500;
}

List<Avatar> generateAvatars(int count) {
  return List.generate(count + 1, (index) => Avatar(getInitials(index), getColor(index)));
}

class Avatars extends StatefulWidget {
  const Avatars({super.key});

  @override
  State<Avatars> createState() => _AvatarsState();
}

class _AvatarsState extends State<Avatars> {
  int _avatarCount = 5;

  @override
  Widget build(BuildContext context) {
    final avatars = generateAvatars(_avatarCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OverflowView.flexible(
          spacing: -40,
          children: <Widget>[
            for (int i = 0; i < avatars.length; i++) AvatarWidget(text: avatars[i].initials, color: avatars[i].color)
          ],
          builder: (context, remaining) {
            return AvatarWidget(
              text: '+$remaining',
              color: Colors.red,
            );
          },
        ),
        Slider(
          value: _avatarCount.toDouble(),
          min: 1,
          max: 50,
          onChanged: (value) => setState(() => _avatarCount = value.toInt()),
        ),
      ],
    );
  }
}

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    Key? key,
    required this.text,
    required this.color,
  }) : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: Text(
        text,
        style: TextStyle(fontSize: 30),
      ),
    );
  }
}
