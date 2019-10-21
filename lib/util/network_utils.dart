class EbayApi {
  static final appId = "";
  static final certId = "";

  static String accessToken;

  static void setToken(String token) {
    accessToken = token;
  }

  static String getToken() {
    return accessToken;
  }
}