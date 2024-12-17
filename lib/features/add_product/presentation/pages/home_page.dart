import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/profile_page.dart'; // Import Profile Page

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to GehnaMall',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        actions: [
          // Profile Icon with login data
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginSuccess) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to the ProfilePage and pass login data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(loginData: state.login),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, size: 100, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                'Welcome to the Home Screen!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Explore, shop, and manage your products with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // Handle navigation or other side effects on state change
          }
        },
        builder: (context, state) {
          return BottomNavigationBar(
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add, color: Colors.green),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              if (index == 1) {
                Navigator.pushNamed(context, '/add_product');
              } else if (index == 3) {
                // Navigate to Profile when the Profile tab is tapped
                if (state is LoginSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        loginData: state.login, // Pass the login data
                      ),
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
