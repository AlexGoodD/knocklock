import 'package:knocklock_flutter/core/imports.dart';

class SelectAvatarModal extends StatefulWidget {
  final String currentAvatar;

  const SelectAvatarModal({super.key, required this.currentAvatar});

  @override
  State<SelectAvatarModal> createState() => _SelectAvatarModalState();
}

class _SelectAvatarModalState extends State<SelectAvatarModal> {
  late String _selectedAvatar;

  final List<String> avatarPaths = [
    'avatar1.png',
    'avatar2.png',
    'avatar3.png',
    'avatar4.png',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Elige un nuevo look',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: avatarPaths.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final avatar = avatarPaths[index];
                final isSelected = avatar == _selectedAvatar;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : AppColors.helperColor,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/avatars/$avatar',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 50),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
        onPressed: () {
                Navigator.pop(context, _selectedAvatar);
              },
              child: Text('Seleccionar avatar', style: AppTextStyles.authButtonTextStyle.copyWith(fontWeight: FontWeight.w500, fontSize: 15),),
            )
          ],
        ),
      ),
    );
  }
}