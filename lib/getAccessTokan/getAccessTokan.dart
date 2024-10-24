import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class GetServerToken {
  Future<String> getAccessToken() async {
    final servicesAccountJson = {
      "type": "service_account",
      "project_id": "grubb-ba0e4",
      "private_key_id": "7b9171c5ad107d5a3511d9d2f5dd8a181cdbf25d",
      "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEugIBADANBgkqhkiG9w0BAQEFAASCBKQwggSgAgEAAoIBAQCh/wUc4Ck0if/m\nzQGpZc5r0iLoDpRGEIHQFbG9rx7VNUVYm37aG8jxNZYyxLppREJALTZl7/1zZj+P\n1dYfKgFafX7uDOGV9VhMQPkjumrRXPmP73J4lHMYir7FJVjsUfy2Dc2H8CPbpAVM\n2NLITVy/BqBVCMSkRDP3dPEFNKy9RGZ80KO28KsKlxMWRZRlDOvEg7SAQE4UAH6k\nnWV7mkM4uWnZFQPoA/niNycedFGfbVgkydeJhYLPzbtVc1E0gD101emJP4PoEepE\nrXXRliLBSqDAvn3ibHD6S43MCMEJdj9r0Zb2lycW/W/ZNw45beZgcsjS5etk9zj3\nPCgdjmUVAgMBAAECgf8kYE4tJWEswIKAMrr8NSQ2MW6Qaa76tvB81R3r4mQBAcCx\n0txyrxOYwK+2NBBMwUHIFVr2iE2bb6G9dsgOYv124NF18BK74cFyb3kHJ/hV23O8\n23TOl22oIY0fia+gtdMX1he+jTpxWGfW8DRsysIsqm9pylb2hUoV9bGEpaIoaQOg\neg7ylbk7qUMEJn7I1OoRwQjbIiM6UhYaRyzznV0JzsXKV3jxi6IOcvKvZz0ceA1X\nJv6xfTDXJwyL9E/U01VaN/lcUCe2IxFJC0bdY0IuKSzfE/meN2dqVyR5GXi/Fxhp\nzfJmvUko5kyOy3gmhCgUopI2PQGFjYeNrBHXX7ECgYEA4IBKiFuSzO23SNj46OzO\njnm5nq5hpoulkOzLljOqDRGPdCcJs3c1JsKIuUzPtrBJ36a3R8WgtTNzEUJIhQf0\nKQ+r+oYqdLQReABRARmMK9nkFZzupyUM+7ABm1MU7ytBFVEDmFI06BanfL/GilNK\niH1hnN3D1JakzytbPmlmmTECgYEAuLmnbvimxuoWUbTFANaq2kj2EtjAe7wOl9Oi\nCFZsp50DqpoV3xwQN2NH9dVlCTYArGKVDuG40kaLhmUVW/jB84I+3lsMxUa9n3Fz\nxM/Yi7RXxOUYdQfpSK7oyKcxp4BvtBIxS4YrsZAgH08dJVjf5NCRPTd7MvkusWpK\nYYbuESUCgYB+jdN2KqkGfLrlhepK47NM/bF1kjfZ+r7Kg7IAaf9ifpOvlpIRaRG9\nV8xbKMGu6pG6UfDftLhzbR1gjUz0MReiTgNUpm0ofJmcXBFN3Wj3D01UIbMm5ev7\ntawyMxOJ/4ggzBqKs0y/yIWB/VmegHVzm7p7A0hxfrpJTteQxznfAQKBgEwIZok/\noW3YZi1lSX0p3pMQWvCw9LE5W4xUmKnz4K8w6pRq7buykl4p6DGgjwC2kJpjzVSd\nxfQPA1ji/GKpxjMTlgrx0RTWJDCfgvYsUsZWCZZKccGh6vx2uev1HXQDYnbs0gtz\nA0MHvqEEcEuyBB3rVwyqbHQzqmtuA4WXAyBdAoGAVsu1pnDpJEox9hcDqwcIA1fX\n0sA6E3smHphFQhCH5DuKrF2zW/pzutkz2KHJa1RpUkVVkwW1Cx+IjHTOxBDhPQxS\nlSrJO1LtRBaPhXLoB0wYME7lLQbopnSuPpeTZ3gZLrgkX+XzZCa3IhWvhkdNAesY\nlDtNlgzaIqg7VzZuMEk=\n-----END PRIVATE KEY-----\n",
      "client_email":
      "notificationv121-10-2024@grubb-ba0e4.iam.gserviceaccount.com",
      "client_id": "111739671260084357853",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
      "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/notificationv121-10-2024%40grubb-ba0e4.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(servicesAccountJson), scopes);

    /// Get Access Token
    auth.AccessCredentials credentials =
    await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(servicesAccountJson),
        scopes,
        client);

    client.close();

    return credentials.accessToken.data;
  }
}
