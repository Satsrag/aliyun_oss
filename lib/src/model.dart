part of aliyun_oss_flutter;

class Credentials {
  Credentials({
    required this.accessKeyId,
    required this.accessKeySecret,
    this.securityToken,
    this.expiration,
  }) {
    if (!useSecurityToken) {
      clearSecurityToken();
    }
  }

  factory Credentials.fromJson(String str) =>
      Credentials.fromMap(json.decode(str) as Map<String, dynamic>);

  factory Credentials.fromMap(Map<String, dynamic> json) {
    return Credentials(
      accessKeyId: json['accessKeyId'] as String,
      accessKeySecret: json['accessKeySecret'] as String,
      securityToken: json['securityToken'] as String,
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'] as String)
          : null,
    );
  }

  final String accessKeyId;
  final String accessKeySecret;
  String? securityToken;
  DateTime? expiration;

  bool get useSecurityToken => securityToken != null && expiration != null;

  void clearSecurityToken() {
    securityToken = null;
    expiration = null;
  }
}

class OSSObject {
  OSSObject({
    required this.stream,
    this.length,
    MediaType? mediaType,
    this.uuid,
  }) : _mediaType = mediaType ?? MediaType('application', 'octet-stream');

  OSSObject.fromBytes({
    required Uint8List bytes,
    required MediaType mediaType,
    this.uuid,
  })  : stream = Stream.fromIterable(bytes.map((e) => [e])),
        length = Future.value(bytes.length),
        _mediaType = mediaType;

  OSSObject.fromFile({
    required File file,
    required MediaType mediaType,
    this.uuid,
  })  : stream = file.openRead(),
        length = file.length(),
        _mediaType = mediaType;

  final Stream<List<int>> stream;

  final MediaType _mediaType;

  MediaType get mediaType => _mediaType;

  final String? uuid;

  String objectPath = '';
  String bucket = '';
  String endPoint = '';

  Future<int>? length;

  String get type => _mediaType == MediaType('application', 'octet-stream')
      ? 'file'
      : _mediaType.type;

  String get name =>
      (uuid ?? Uuid().v1()) + (type == 'file' ? '' : '.${_mediaType.subtype}');

  String get folderPath => [
        type,
        DateFormat('y/MM/dd').format(DateTime.now()),
      ].join('/');

  String resourcePath(String? path) => '${path ?? folderPath}/$name';

  void uploadSuccessful(String endPoint, String bucket, String objectPath) {
    this.endPoint = endPoint;
    this.bucket = bucket;
    this.objectPath = objectPath;
  }
}

class OSSImageObject extends OSSObject {
  OSSImageObject.fromBytes({
    required Uint8List bytes,
    required MediaType mediaType,
    String? uuid,
  }) : super.fromBytes(bytes: bytes, mediaType: mediaType, uuid: uuid);

  OSSImageObject._({
    required File file,
    required MediaType mediaType,
    String? uuid,
  }) : super.fromFile(file: file, mediaType: mediaType, uuid: uuid);

  factory OSSImageObject.fromFile({
    required File file,
    MediaType? mediaType,
    String? uuid,
  }) {
    String subtype = path.extension(file.path).toLowerCase();
    subtype = subtype.isNotEmpty ? subtype.replaceFirst('.', '') : '*';
    final type = mediaType ?? MediaType('image', subtype);
    return OSSImageObject._(file: file, mediaType: type, uuid: uuid);
  }
}

class OSSAudioObject extends OSSObject {
  OSSAudioObject._({
    required File file,
    required MediaType mediaType,
    String? uuid,
  }) : super.fromFile(file: file, mediaType: mediaType, uuid: uuid);

  factory OSSAudioObject.fromFile({
    required File file,
    MediaType? mediaType,
    String? uuid,
  }) {
    String subtype = path.extension(file.path).toLowerCase();
    subtype = subtype.isNotEmpty ? subtype.replaceFirst('.', '') : '*';
    final type = mediaType ?? MediaType('audio', subtype);
    return OSSAudioObject._(file: file, mediaType: type, uuid: uuid);
  }
}

class OSSVideoObject extends OSSObject {
  OSSVideoObject._({
    required File file,
    required MediaType mediaType,
    String? uuid,
  }) : super.fromFile(file: file, mediaType: mediaType, uuid: uuid);

  factory OSSVideoObject.fromFile({
    required File file,
    MediaType? mediaType,
    String? uuid,
  }) {
    String subtype = path.extension(file.path).toLowerCase();
    subtype = subtype.isNotEmpty ? subtype.replaceFirst('.', '') : '*';
    final type = mediaType ?? MediaType('audio', subtype);
    return OSSVideoObject._(file: file, mediaType: type, uuid: uuid);
  }
}
