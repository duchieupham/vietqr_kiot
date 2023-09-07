class SettingAccountDTO {
  final String id;

  final String userId;
  final bool guideWeb;
  final bool guideMobile;
  final bool voiceWeb;
  final bool voiceMobile;
  final bool voiceMobileKiot;
  final bool status;
  final int accessCount;
  final String edgeImgId;
  final String footerImgId;

  const SettingAccountDTO(
      {this.status = false,
      this.id = '',
      this.userId = '',
      this.guideMobile = false,
      this.guideWeb = false,
      this.voiceMobile = false,
      this.voiceMobileKiot = false,
      this.voiceWeb = false,
      this.accessCount = 0,
      this.edgeImgId = '',
      this.footerImgId = ''});

  factory SettingAccountDTO.fromJson(Map<String, dynamic> json) {
    return SettingAccountDTO(
      status: json['status'] ?? false,
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      guideMobile: json['guideMobile'] ?? false,
      guideWeb: json['guideWeb'] ?? false,
      voiceMobile: json['voiceMobile'] ?? false,
      voiceMobileKiot: json['voiceMobileKiot'] ?? false,
      voiceWeb: json['voiceWeb'] ?? false,
      accessCount: json['accessCount'] ?? 0,
      edgeImgId: json['edgeImgId'] ?? '',
      footerImgId: json['footerImgId'] ?? '',
    );
  }
  Map<String, dynamic> toSPJson() {
    final Map<String, dynamic> data = {};
    data['"userId"'] = (userId == '') ? '""' : '"$userId"';
    data['"id"'] = (id == '') ? '""' : '"$id"';
    data['"status"'] = '$status';
    data['"guideMobile"'] = '$guideMobile';
    data['"guideWeb"'] = '$guideWeb';
    data['"voiceMobile"'] = '$voiceMobile';
    data['"voiceMobileKiot"'] = '$voiceMobileKiot';
    data['"voiceWeb"'] = '$voiceWeb';
    data['"edgeImgId"'] = (edgeImgId == '') ? '""' : '"$edgeImgId"';
    data['"footerImgId"'] = (footerImgId == '') ? '""' : '"$footerImgId"';
    return data;
  }
}
