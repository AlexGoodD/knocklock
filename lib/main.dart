import 'imports.dart';

void main() {
  runApp(MaterialApp(
    home: LockListScreen(),
    theme: ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        bodyLarge: AppTextStyles.primaryTextStyle,
        bodyMedium: AppTextStyles.secondaryTextStyle,
      ),
    ),
  ));
}

class LockListScreen extends StatefulWidget {
  @override
  State<LockListScreen> createState() => _LockListScreenState();
}

class _LockListScreenState extends State<LockListScreen> {
  List<Lock> locks = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController ipController = TextEditingController();

  void addLock() {
    final String name = nameController.text;
    final String ip = ipController.text;

    if (name.isNotEmpty && ip.isNotEmpty) {
      setState(() {
        locks.add(Lock(name: name, ip: ip));
      });

      nameController.clear();
      ipController.clear();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  void showAddLockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Agregar Candado"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nombre del Candado"),
                  style: AppTextStyles.secondaryTextStyle
              ),
              TextField(
                controller: ipController,
                decoration: InputDecoration(labelText: "IP del Candado"),
                  style: AppTextStyles.secondaryTextStyle

              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: addLock,
              child: Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  void navigateToDetail(Lock lock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LockDetailScreen(lock: lock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KnockLock"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddLockDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: locks.length,
              itemBuilder: (context, index) {
                final lock = locks[index];
                return ListTile(
                  title: Text(lock.name),
                  subtitle: Text(lock.ip),
                  onTap: () => navigateToDetail(lock),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}