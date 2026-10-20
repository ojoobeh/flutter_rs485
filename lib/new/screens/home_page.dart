// import 'package:flutter/material.dart';
// import 'package:untitled4/new/models/home_button_config.dart';
// import 'package:untitled4/new/screens/home_button_list.dart';
// import 'package:untitled4/new/serial_command_mixin.dart';
// import 'package:untitled4/widgets/long_press_button.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> with SerialCommandMixin {
//   @override
//   void initState() {
//     super.initState();
//     initSerial();
//   }
//
//   @override
//   void dispose() {
//     disposeSerial();
//     super.dispose();
//   }
//
//   // ============ اجرای اکشن دکمه ============
//
//   void _runAction(ButtonAction action, dynamic payload) {
//     switch (action) {
//       case ButtonAction.command:
//         sendCommand(payload as int);
//         break;
//       case ButtonAction.rawCommand:
//         sendRawCommand(List<int>.from(payload as List));
//         break;
//       case ButtonAction.navigate:
//         break; // در _buildButton مدیریت می‌شود
//     }
//   }
//
//   // ============ ساخت دکمه از کانفیگ ============
//
//   Widget _buildButton(HomeButtonConfig config) {
//     // دکمه ناوبری => ElevatedButton ساده
//     if (config.action == ButtonAction.navigate) {
//       return ElevatedButton(
//         onPressed: () {
//           if (config.screenBuilder != null) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: config.screenBuilder!),
//             );
//           }
//         },
//         child: Text(config.label),
//       );
//     }
//
//     // دکمه با قابلیت long press
//     if (config.longPressAction != null) {
//       return LongPressButton(
//         label: config.label,
//         onTap: () => _runAction(config.action, config.payload),
//         onLongPress: () =>
//             _runAction(config.longPressAction!, config.longPressPayload),
//       );
//     }
//
//     // دکمه ساده
//     return ElevatedButton(
//       onPressed: () => _runAction(config.action, config.payload),
//       child: Text(config.label),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 for (final button in homeButtons) ...[
//                   _buildButton(button),
//                   const SizedBox(height: 20),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }