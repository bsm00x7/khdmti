import 'package:khdmti_project/model/profile_model.dart';
import 'package:khdmti_project/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataBase {
  final supabase = Supabase.instance.client;

  Future<ProfileModel> profileData({required String value}) async {
    final response =
        await supabase.from('userProfile').select().eq('id', value).single();

    return ProfileModel.fromJson(response);
  }

  Future<void> insertToDataBase(AuthResponse userData) async {
    final profile = ProfileModel(
      id: userData.user!.id,
      jobTitle: "Job",
      description: "Hello My Name ${userData.user!.userMetadata!["name"]}",
      skills: "",
      completedProject: 0,
      succesProject: 0,
      numberofYearsExperince: 0,
    );

    await supabase.from('userProfile').insert(profile.toJson());
  }
}
