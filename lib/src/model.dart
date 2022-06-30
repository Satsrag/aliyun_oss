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

extension StringEx on String {
  MediaType? get toMediaType {
    try {
      return MediaType.parse(this);
    } catch (e) {
      return null;
    }
  }
}

class OSSObject {
  OSSObject({
    required this.stream,
    this.length,
    MediaType? mediaType,
    String? objectPath,
  })  : mediaType = mediaType ??
            mime(objectPath)?.toMediaType ??
            MediaType('application', 'octet-stream'),
        objectPath = objectPath ??
            "${DateFormat('y/MM/dd').format(DateTime.now())}/${Uuid().v1()}.${extensionFromMime(mediaType.toString())}";

  OSSObject.fromBytes({
    required Uint8List bytes,
    MediaType? mediaType,
    String? objectPath,
  }) : this(
            stream: Stream.fromIterable(bytes.map((e) => [e])),
            length: Future.value(bytes.length),
            mediaType: mediaType,
            objectPath: objectPath);

  OSSObject.fromFile({
    required File file,
    MediaType? mediaType,
    String? objectPath,
  }) : this(
            stream: file.openRead(),
            length: file.length(),
            mediaType: mediaType,
            objectPath: objectPath);

  // stream = file.openRead(),
  // length = file.length(),
  // _mediaType = mediaType;

  Future<int>? length;
  final Stream<List<int>> stream;
  final MediaType mediaType;
  final String objectPath;
}

// class OSSImageObject extends OSSObject {
//   OSSImageObject.fromBytes({
//     required Uint8List bytes,
//     required MediaType mediaType,
//     String? uuid,
//   }) : super.fromBytes(bytes: bytes, mediaType: mediaType, uuid: uuid);
//
//   OSSImageObject._({
//     required File file,
//     required MediaType mediaType,
//     String? uuid,
//   }) : super.fromFile(file: file, mediaType: mediaType, uuid: uuid);
//
//   factory OSSImageObject.fromFile({
//     required File file,
//     MediaType? mediaType,
//     String? uuid,
//   }) {
//     String subtype = path.extension(file.path).toLowerCase();
//     subtype = subtype.isNotEmpty ? subtype.replaceFirst('.', '') : '*';
//     final type = mediaType ?? MediaType('image', subtype);
//     return OSSImageObject._(file: file, mediaType: type, uuid: uuid);
//   }
// }
//
// class OSSAudioObject extends OSSObject {
//   OSSAudioObject._({
//     required File file,
//     required MediaType mediaType,
//     String? uuid,
//   }) : super.fromFile(file: file, mediaType: mediaType, uuid: uuid);
//
//   factory OSSAudioObject.fromFile({
//     required File file,
//     MediaType? mediaType,
//     String? uuid,
//   }) {
//     String subtype = path.extension(file.path).toLowerCase();
//     subtype = subtype.isNotEmpty ? subtype.replaceFirst('.', '') : '*';
//     final type = mediaType ?? MediaType('audio', subtype);
//     return OSSAudioObject._(file: file, mediaType: type, uuid: uuid);
//   }
// }
//
// class OSSVideoObject extends OSSObject {
//   OSSVideoObject._({
//     required File file,
//     required MediaType mediaType,
//     String? uuid,
//   }) : super.fromFile(file: file, mediaType: mediaType, uuid: uuid);
//
//   factory OSSVideoObject.fromFile({
//     required File file,
//     MediaType? mediaType,
//     String? uuid,
//   }) {
//     String subtype = path.extension(file.path).toLowerCase();
//     subtype = subtype.isNotEmpty ? subtype.replaceFirst('.', '') : '*';
//     final type = mediaType ?? MediaType('audio', subtype);
//     return OSSVideoObject._(file: file, mediaType: type, uuid: uuid);
//   }
// }
