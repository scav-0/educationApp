abstract class User {
  final int id;
  final String firstName;
  final String lastName;
  

   User({
    required this.id,
    required this.firstName,
    required this.lastName,
    
  });
}

class Teacher extends User{
  final String email;
  
  Teacher({
    required super.id,
    required super.firstName,
    required super.lastName,
    required this.email
    
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }
}

class Student extends User{
  final String username;
  
  Student({
    required super.id,
    required super.firstName,
    required super.lastName,
    required this.username
    
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
    );

  }
}



