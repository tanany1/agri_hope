import 'package:flutter/material.dart';

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){},
                child: Row(
                  children: [
                    Text("Profile"),
                    Spacer(),
                    Image.asset("assets/img/profile.png", width: 50,height: 50,),
                  ],
                ),
              ),
            ),
            Container(color: Colors.black,height: 2,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){},
                child: Row(
                  children: [
                    Text("History Log"),
                    Spacer(),
                    Image.asset("assets/img/history.png", width: 50,height: 50,),
                  ],
                ),
              ),
            ),
            Container(color: Colors.black,height: 2,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){},
                child: Row(
                  children: [
                    Text("Setting"),
                    Spacer(),
                    Image.asset("assets/img/setting_icon.png", width: 50,height: 50,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
