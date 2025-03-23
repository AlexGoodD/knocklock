import 'imports.dart';

void main() {
  runApp(MaterialApp(
    home: LockListScreen(),
    theme: ThemeData(
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        bodyLarge: AppTextStyles.primaryTextStyle,
        bodyMedium: AppTextStyles.secondaryTextStyle,
      ),
    ),
  ));
}

class LockListScreen extends StatefulWidget {
  const LockListScreen({super.key});

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
      Navigator.of(context).pop();
    }
  }

  void showAddLockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateDialog(
          nameController: nameController,
          ipController: ipController,
          onAdd: addLock,
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
        title: Text("Knock Lock", style: AppTextStyles.appBarTextStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: locks.length,
              itemBuilder: (context, index) {
                final lock = locks[index];
                return LockItem(name: lock.name, ip: lock.ip, lock: lock);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: showAddLockDialog,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: Colors.black,
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class LockDetailScreen extends StatelessWidget {
  final Lock lock;

  const LockDetailScreen({super.key, required this.lock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lock.name),
      ),
      body: Center(
        child: Text('IP: ${lock.ip}'),
      ),
    );
  }
}