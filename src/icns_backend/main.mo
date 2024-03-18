import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Result "mo:base/Result";
import List "mo:base/List";
import Option "mo:base/Option";

actor {
  /// @title ICNS (Internet Computer Name Service)
  /// @author Ugochi Jacinta Ike
  /// @notice

  /// @desc A user-friendly alias for ICP wallets
  type Username = Text;
  type UserData = {
    principal : Principal;
    expiry_date : Time.Time;
  };

  type ICNSRegistry = HashMap.HashMap<Username, UserData>;
  type ICNSRegistryList = [var (Username, UserData)];

  type ICNSError = {
    #UsernameInUse;
    #UsernameNotInUse;
  };

  var registry : ICNSRegistry = HashMap.HashMap(10, Text.equal, Text.hash);
  stable var registryList : ICNSRegistryList = [var];

  public query func register_user(username : Username, user_principal_id : Text) : async Result.Result<Text, ICNSError> {
    let user_principal : Principal = Principal.fromText(user_principal_id);

    // Ensure that the username is not in use
    switch (registry.get(username)) {
      case (?data_of_existing_user) {
        if (data_of_existing_user.expiry_date >= Time.now()) {
          return #err(#UsernameInUse);
        };
      };
      case (null) {};
    };

    let expiry_date = Time.now() + 10000;
    let user_data : UserData = {
      principal = user_principal;
      expiry_date = expiry_date;
    };

    registry.put(username, user_data);

    return #ok(username);
  };

  public func lookup_username(username : Username) : async Result.Result<Principal, ICNSError> {
    switch (registry.get(username)) {
      case (?user_data) {
        if (user_data.expiry_date >= Time.now()) {
          return #ok(user_data.principal);
        };

        return #err(#UsernameNotInUse);
      };
      case (null) {
        return #err(#UsernameNotInUse);
      };
    };
  };
};
