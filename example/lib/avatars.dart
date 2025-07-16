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

class AvatarsDemo extends StatefulWidget {
  const AvatarsDemo({super.key});

  @override
  State<AvatarsDemo> createState() => _AvatarsDemoState();
}

class _AvatarsDemoState extends State<AvatarsDemo> {
  int _avatarCount = 5;
  double _spacing = -40;

  @override
  Widget build(BuildContext context) {
    final avatars = generateAvatars(_avatarCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OverflowView.flexible(
                spacing: _spacing,
                children: <Widget>[
                  for (int i = 0; i < avatars.length; i++)
                    AvatarWidget(text: avatars[i].initials, color: avatars[i].color)
                ],
                builder: (context, remaining) {
                  return AvatarWidget(
                    text: '+$remaining',
                    color: Colors.red,
                  );
                },
              ),
            ),
          ),
        ),
        Slider(
          value: _avatarCount.toDouble(),
          min: 1,
          max: 50,
          onChanged: (value) => setState(() => _avatarCount = value.toInt()),
        ),
        SizedBox(height: 20),
        Text('Spacing (${_spacing.toInt()})'),
        SizedBox(height: 10),
        SizedBox(
          width: 200,
          child: Slider(
            value: _spacing,
            min: -40,
            max: 40,
            onChanged: (value) => setState(
              () => _spacing = value,
            ),
          ),
        ),
      ],
    );
  }
}

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.text,
    required this.color,
  });

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
