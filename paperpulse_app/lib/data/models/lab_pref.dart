class LabPref {
  final bool displayed;
  final bool favourited;

  const LabPref({this.displayed = false, this.favourited = false});

  LabPref copyWith({bool? displayed, bool? favourited}) => LabPref(
        displayed: displayed ?? this.displayed,
        favourited: favourited ?? this.favourited,
      );

  Map<String, dynamic> toJson() =>
      {'displayed': displayed, 'favourited': favourited};

  factory LabPref.fromJson(Map<String, dynamic> json) => LabPref(
        displayed: json['displayed'] as bool? ?? false,
        favourited: json['favourited'] as bool? ?? false,
      );
}
