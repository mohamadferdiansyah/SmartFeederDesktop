class CctvModel {
  final String cctvId;
  final String ipAddress;
  final int port;
  final String username;
  final String password;

  CctvModel({
    required this.cctvId,
    required this.ipAddress,
    required this.port,
    required this.username,
    required this.password,
  });

  factory CctvModel.fromMap(Map<String, dynamic> map) => CctvModel(
        cctvId: map['cctv_id'],
        ipAddress: map['ip_address'],
        port: map['port'] is int ? map['port'] : int.parse(map['port'].toString()),
        username: map['username'],
        password: map['password'],
      );

  Map<String, dynamic> toMap() => {
        'cctv_id': cctvId,
        'ip_address': ipAddress,
        'port': port,
        'username': username,
        'password': password,
      };
}