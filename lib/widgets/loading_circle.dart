import 'package:flutter/material.dart';

class LoadingCircle extends StatelessWidget {
  const LoadingCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      transformAlignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffDDDADA)),
            strokeWidth: 5.0,
            strokeCap: StrokeCap.square,
            backgroundColor: Color.fromARGB(159, 0, 0, 0),
            constraints: BoxConstraints(minHeight: 100, minWidth: 100),
            padding: EdgeInsets.only(bottom: 100),
          ),
        ],
      ),
    );
  }
}
