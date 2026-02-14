/// Environment variables and shared app constants.
abstract class Constants {
  static const String supabaseUrl = String.fromEnvironment(
    'https://elpnvbmkkoxwgmnwrjyq.supabase.co',
  );

  static const String supabaseAnnonKey = String.fromEnvironment(
    'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVscG52Ym1ra294d2dtbndyanlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA5MzUyNjQsImV4cCI6MjA4NjUxMTI2NH0',
  );
}
