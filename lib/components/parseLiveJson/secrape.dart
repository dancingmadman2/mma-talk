// To parse this JSON data, do
//
//     final live = liveFromJson(jsonString);

import 'dart:convert';

Live liveFromJson(String str) => Live.fromJson(json.decode(str));

String liveToJson(Live data) => json.encode(data.toJson());

class Live {
  LiveEventDetail liveEventDetail;

  Live({
    required this.liveEventDetail,
  });

  factory Live.fromJson(Map<String, dynamic> json) => Live(
        liveEventDetail: LiveEventDetail.fromJson(json["LiveEventDetail"]),
      );

  Map<String, dynamic> toJson() => {
        "LiveEventDetail": liveEventDetail.toJson(),
      };
}

class LiveEventDetail {
  int eventId;
  String name;
  String startTime;
  String timeZone;
  String status;
  int? liveEventId;
  int? liveFightId;
  int? liveRoundNumber;
  String? liveRoundElapsedTime;
  Organization organization;
  Location location;
  List<FightCard> fightCard;

  LiveEventDetail({
    required this.eventId,
    required this.name,
    required this.startTime,
    required this.timeZone,
    required this.status,
    required this.liveEventId,
    required this.liveFightId,
    required this.liveRoundNumber,
    required this.liveRoundElapsedTime,
    required this.organization,
    required this.location,
    required this.fightCard,
  });

  factory LiveEventDetail.fromJson(Map<String, dynamic> json) =>
      LiveEventDetail(
        eventId: json["EventId"],
        name: json["Name"],
        startTime: json["StartTime"],
        timeZone: json["TimeZone"],
        status: json["Status"],
        liveEventId: json["LiveEventId"],
        liveFightId: json["LiveFightId"],
        liveRoundNumber: json["LiveRoundNumber"],
        liveRoundElapsedTime: json["LiveRoundElapsedTime"],
        organization: Organization.fromJson(json["Organization"]),
        location: Location.fromJson(json["Location"]),
        fightCard: List<FightCard>.from(
            json["FightCard"].map((x) => FightCard.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "EventId": eventId,
        "Name": name,
        "StartTime": startTime,
        "TimeZone": timeZone,
        "Status": status,
        "LiveEventId": liveEventId,
        "LiveFightId": liveFightId,
        "LiveRoundNumber": liveRoundNumber,
        "LiveRoundElapsedTime": liveRoundElapsedTime,
        "Organization": organization.toJson(),
        "Location": location.toJson(),
        "FightCard": List<dynamic>.from(fightCard.map((x) => x.toJson())),
      };
}

class FightCard {
  int fightId;
  int fightOrder;
  String status;
  String cardSegment;
  String cardSegmentStartTime;
  String cardSegmentBroadcaster;
  List<FightCardFighter> fighters;
  Result result;
  FightCardWeightClass weightClass;
  List<Accolade> accolades;
  Referee referee;
  RuleSet ruleSet;
  List<FightNightTracking> fightNightTracking;

  FightCard({
    required this.fightId,
    required this.fightOrder,
    required this.status,
    required this.cardSegment,
    required this.cardSegmentStartTime,
    required this.cardSegmentBroadcaster,
    required this.fighters,
    required this.result,
    required this.weightClass,
    required this.accolades,
    required this.referee,
    required this.ruleSet,
    required this.fightNightTracking,
  });

  factory FightCard.fromJson(Map<String, dynamic> json) => FightCard(
        fightId: json["FightId"],
        fightOrder: json["FightOrder"],
        status: json["Status"],
        cardSegment: json["CardSegment"],
        cardSegmentStartTime: json["CardSegmentStartTime"],
        cardSegmentBroadcaster: json["CardSegmentBroadcaster"],
        fighters: List<FightCardFighter>.from(
            json["Fighters"].map((x) => FightCardFighter.fromJson(x))),
        result: Result.fromJson(json["Result"]),
        weightClass: FightCardWeightClass.fromJson(json["WeightClass"]),
        accolades: List<Accolade>.from(
            json["Accolades"].map((x) => Accolade.fromJson(x))),
        referee: Referee.fromJson(json["Referee"]),
        ruleSet: RuleSet.fromJson(json["RuleSet"]),
        fightNightTracking: List<FightNightTracking>.from(
            json["FightNightTracking"]
                .map((x) => FightNightTracking.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "FightId": fightId,
        "FightOrder": fightOrder,
        "Status": status,
        "CardSegment": cardSegment,
        "CardSegmentStartTime": cardSegmentStartTime,
        "CardSegmentBroadcaster": cardSegmentBroadcaster,
        "Fighters": List<dynamic>.from(fighters.map((x) => x.toJson())),
        "Result": result.toJson(),
        "WeightClass": weightClass.toJson(),
        "Accolades": List<dynamic>.from(accolades.map((x) => x.toJson())),
        "Referee": referee.toJson(),
        "RuleSet": ruleSet.toJson(),
        "FightNightTracking":
            List<dynamic>.from(fightNightTracking.map((x) => x.toJson())),
      };
}

class Accolade {
  String type;
  String name;

  Accolade({
    required this.type,
    required this.name,
  });

  factory Accolade.fromJson(Map<String, dynamic> json) => Accolade(
        type: json["Type"],
        name: json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "Type": type,
        "Name": name,
      };
}

class FightNightTracking {
  int actionId;
  int? fighterId;
  String type;
  int? roundNumber;
  String? roundTime;
  DateTime timestamp;

  FightNightTracking({
    required this.actionId,
    required this.fighterId,
    required this.type,
    required this.roundNumber,
    required this.roundTime,
    required this.timestamp,
  });

  factory FightNightTracking.fromJson(Map<String, dynamic> json) =>
      FightNightTracking(
        actionId: json["ActionId"],
        fighterId: json["FighterId"],
        type: json["Type"],
        roundNumber: json["RoundNumber"],
        roundTime: json["RoundTime"],
        timestamp: DateTime.parse(json["Timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "ActionId": actionId,
        "FighterId": fighterId,
        "Type": type,
        "RoundNumber": roundNumber,
        "RoundTime": roundTime,
        "Timestamp": timestamp.toIso8601String(),
      };
}

class FightCardFighter {
  int fighterId;
  int mmaId;
  Name name;
  Born born;
  Born fightingOutOf;
  Record record;
  DateTime dob;
  int age;
  String stance;
  double weight;
  double height;
  double reach;
  String ufcLink;
  List<WeightClassElement> weightClasses;
  String? corner;
  double weighIn;
  Outcome outcome;
  bool koOfTheNight;
  bool submissionOfTheNight;
  bool performanceOfTheNight;

  FightCardFighter({
    required this.fighterId,
    required this.mmaId,
    required this.name,
    required this.born,
    required this.fightingOutOf,
    required this.record,
    required this.dob,
    required this.age,
    required this.stance,
    required this.weight,
    required this.height,
    required this.reach,
    required this.ufcLink,
    required this.weightClasses,
    required this.corner,
    required this.weighIn,
    required this.outcome,
    required this.koOfTheNight,
    required this.submissionOfTheNight,
    required this.performanceOfTheNight,
  });

  factory FightCardFighter.fromJson(Map<String, dynamic> json) =>
      FightCardFighter(
        fighterId: json["FighterId"],
        mmaId: json["MMAId"],
        name: Name.fromJson(json["Name"]),
        born: Born.fromJson(json["Born"]),
        fightingOutOf: Born.fromJson(json["FightingOutOf"]),
        record: Record.fromJson(json["Record"]),
        dob: DateTime.parse(json["DOB"]),
        age: json["Age"],
        stance: json["Stance"],
        weight: json["Weight"],
        height: json["Height"],
        reach: json["Reach"],
        ufcLink: json["UFCLink"],
        weightClasses: List<WeightClassElement>.from(
            json["WeightClasses"].map((x) => WeightClassElement.fromJson(x))),
        corner: json["Corner"],
        weighIn: json["WeighIn"]?.toDouble(),
        outcome: Outcome.fromJson(json["Outcome"]),
        koOfTheNight: json["KOOfTheNight"],
        submissionOfTheNight: json["SubmissionOfTheNight"],
        performanceOfTheNight: json["PerformanceOfTheNight"],
      );

  Map<String, dynamic> toJson() => {
        "FighterId": fighterId,
        "MMAId": mmaId,
        "Name": name.toJson(),
        "Born": born.toJson(),
        "FightingOutOf": fightingOutOf.toJson(),
        "Record": record.toJson(),
        "DOB":
            "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
        "Age": age,
        "Stance": stance,
        "Weight": weight,
        "Height": height,
        "Reach": reach,
        "UFCLink": ufcLink,
        "WeightClasses":
            List<dynamic>.from(weightClasses.map((x) => x.toJson())),
        "Corner": corner,
        "WeighIn": weighIn,
        "Outcome": outcome.toJson(),
        "KOOfTheNight": koOfTheNight,
        "SubmissionOfTheNight": submissionOfTheNight,
        "PerformanceOfTheNight": performanceOfTheNight,
      };
}

class Born {
  String? city;
  String? state;
  String? country;
  String? triCode;

  Born({
    required this.city,
    required this.state,
    required this.country,
    required this.triCode,
  });

  factory Born.fromJson(Map<String, dynamic> json) => Born(
        city: json["City"],
        state: json["State"],
        country: json["Country"],
        triCode: json["TriCode"],
      );

  Map<String, dynamic> toJson() => {
        "City": city,
        "State": state,
        "Country": country,
        "TriCode": triCode,
      };
}

class Name {
  String firstName;
  String lastName;
  String? nickName;

  Name({
    required this.firstName,
    required this.lastName,
    required this.nickName,
  });

  factory Name.fromJson(Map<String, dynamic> json) => Name(
        firstName: json["FirstName"],
        lastName: json["LastName"],
        nickName: json["NickName"],
      );

  Map<String, dynamic> toJson() => {
        "FirstName": firstName,
        "LastName": lastName,
        "NickName": nickName,
      };
}

class Outcome {
  int? outcomeId;
  String? outcome;

  Outcome({
    required this.outcomeId,
    required this.outcome,
  });

  factory Outcome.fromJson(Map<String, dynamic> json) => Outcome(
        outcomeId: json["OutcomeId"],
        outcome: json["Outcome"],
      );

  Map<String, dynamic> toJson() => {
        "OutcomeId": outcomeId,
        "Outcome": outcome,
      };
}

class Record {
  int wins;
  int losses;
  int draws;
  int noContests;

  Record({
    required this.wins,
    required this.losses,
    required this.draws,
    required this.noContests,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        wins: json["Wins"],
        losses: json["Losses"],
        draws: json["Draws"],
        noContests: json["NoContests"],
      );

  Map<String, dynamic> toJson() => {
        "Wins": wins,
        "Losses": losses,
        "Draws": draws,
        "NoContests": noContests,
      };
}

class WeightClassElement {
  int weightClassId;
  int weightClassOrder;
  String description;
  String abbreviation;

  WeightClassElement({
    required this.weightClassId,
    required this.weightClassOrder,
    required this.description,
    required this.abbreviation,
  });

  factory WeightClassElement.fromJson(Map<String, dynamic> json) =>
      WeightClassElement(
        weightClassId: json["WeightClassId"],
        weightClassOrder: json["WeightClassOrder"],
        description: json["Description"],
        abbreviation: json["Abbreviation"],
      );

  Map<String, dynamic> toJson() => {
        "WeightClassId": weightClassId,
        "WeightClassOrder": weightClassOrder,
        "Description": description,
        "Abbreviation": abbreviation,
      };
}

class Referee {
  int refereeId;
  String firstName;
  String lastName;

  Referee({
    required this.refereeId,
    required this.firstName,
    required this.lastName,
  });

  factory Referee.fromJson(Map<String, dynamic> json) => Referee(
        refereeId: json["RefereeId"],
        firstName: json["FirstName"],
        lastName: json["LastName"],
      );

  Map<String, dynamic> toJson() => {
        "RefereeId": refereeId,
        "FirstName": firstName,
        "LastName": lastName,
      };
}

class Result {
  String? method;
  int? endingRound;
  String? endingTime;
  dynamic endingStrike;
  dynamic endingTarget;
  dynamic endingPosition;
  dynamic endingSubmission;
  dynamic endingNotes;
  bool? fightOfTheNight;
  List<FightScore> fightScores;

  Result({
    required this.method,
    required this.endingRound,
    required this.endingTime,
    required this.endingStrike,
    required this.endingTarget,
    required this.endingPosition,
    required this.endingSubmission,
    required this.endingNotes,
    required this.fightOfTheNight,
    required this.fightScores,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        method: json["Method"],
        endingRound: json["EndingRound"],
        endingTime: json["EndingTime"],
        endingStrike: json["EndingStrike"],
        endingTarget: json["EndingTarget"],
        endingPosition: json["EndingPosition"],
        endingSubmission: json["EndingSubmission"],
        endingNotes: json["EndingNotes"],
        fightOfTheNight: json["FightOfTheNight"],
        fightScores: List<FightScore>.from(
            json["FightScores"].map((x) => FightScore.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Method": method,
        "EndingRound": endingRound,
        "EndingTime": endingTime,
        "EndingStrike": endingStrike,
        "EndingTarget": endingTarget,
        "EndingPosition": endingPosition,
        "EndingSubmission": endingSubmission,
        "EndingNotes": endingNotes,
        "FightOfTheNight": fightOfTheNight,
        "FightScores": List<dynamic>.from(fightScores.map((x) => x.toJson())),
      };
}

class FightScore {
  int judgeId;
  String judgeFirstName;
  String judgeLastName;
  List<FightScoreFighter> fighters;

  FightScore({
    required this.judgeId,
    required this.judgeFirstName,
    required this.judgeLastName,
    required this.fighters,
  });

  factory FightScore.fromJson(Map<String, dynamic> json) => FightScore(
        judgeId: json["JudgeId"],
        judgeFirstName: json["JudgeFirstName"],
        judgeLastName: json["JudgeLastName"],
        fighters: List<FightScoreFighter>.from(
            json["Fighters"].map((x) => FightScoreFighter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "JudgeId": judgeId,
        "JudgeFirstName": judgeFirstName,
        "JudgeLastName": judgeLastName,
        "Fighters": List<dynamic>.from(fighters.map((x) => x.toJson())),
      };
}

class FightScoreFighter {
  int fighterId;
  int score;

  FightScoreFighter({
    required this.fighterId,
    required this.score,
  });

  factory FightScoreFighter.fromJson(Map<String, dynamic> json) =>
      FightScoreFighter(
        fighterId: json["FighterId"],
        score: json["Score"],
      );

  Map<String, dynamic> toJson() => {
        "FighterId": fighterId,
        "Score": score,
      };
}

class RuleSet {
  int? possibleRounds;
  String? description;

  RuleSet({
    required this.possibleRounds,
    required this.description,
  });

  factory RuleSet.fromJson(Map<String, dynamic> json) => RuleSet(
        possibleRounds: json["PossibleRounds"],
        description: json["Description"],
      );

  Map<String, dynamic> toJson() => {
        "PossibleRounds": possibleRounds,
        "Description": description,
      };
}

class FightCardWeightClass {
  int weightClassId;
  dynamic catchWeight;
  String weight;
  String description;
  String abbreviation;

  FightCardWeightClass({
    required this.weightClassId,
    required this.catchWeight,
    required this.weight,
    required this.description,
    required this.abbreviation,
  });

  factory FightCardWeightClass.fromJson(Map<String, dynamic> json) =>
      FightCardWeightClass(
        weightClassId: json["WeightClassId"],
        catchWeight: json["CatchWeight"],
        weight: json["Weight"],
        description: json["Description"],
        abbreviation: json["Abbreviation"],
      );

  Map<String, dynamic> toJson() => {
        "WeightClassId": weightClassId,
        "CatchWeight": catchWeight,
        "Weight": weight,
        "Description": description,
        "Abbreviation": abbreviation,
      };
}

class Location {
  String city;
  String state;
  String country;
  String triCode;
  int venueId;
  String venue;

  Location({
    required this.city,
    required this.state,
    required this.country,
    required this.triCode,
    required this.venueId,
    required this.venue,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        city: json["City"],
        state: json["State"],
        country: json["Country"],
        triCode: json["TriCode"],
        venueId: json["VenueId"],
        venue: json["Venue"],
      );

  Map<String, dynamic> toJson() => {
        "City": city,
        "State": state,
        "Country": country,
        "TriCode": triCode,
        "VenueId": venueId,
        "Venue": venue,
      };
}

class Organization {
  int organizationId;
  String name;

  Organization({
    required this.organizationId,
    required this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        organizationId: json["OrganizationId"],
        name: json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "OrganizationId": organizationId,
        "Name": name,
      };
}
