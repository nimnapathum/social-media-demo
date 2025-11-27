import ballerina/http;
import ballerina/time;

listener http:Listener httpDefaultListener = http:getDefaultListener();

type User record {|
    readonly int id;
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

type NewUser record {|
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

type ErrorDetails record {
    string message;
    string details;
    time:Utc timesStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

table<User> key(id) users = table [
    {
        id: 1,
        name: "Joe",
        birthDate: {year: 2002, month: 5, day: 7},
        mobileNumber: "+1234567890"
    }
];

service /social\-media on httpDefaultListener {

    // social-media/users
    resource function get users() returns User[]|error {
        return users.toArray();
    }

    resource function get users/[int id]() returns User|UserNotFound|error {
        User? user = users[id];
        if user is () {
            UserNotFound userNotFound = {
                body: {message: string `id: ${id}`, details: string `user/${id}`, timesStamp: time:utcNow()}
            };
            return userNotFound;
        }
        return user;
    }

    resource function post users(NewUser newUser) returns http:Created|error {
        users.add({id: users.length() + 1, ...newUser});
        return http:CREATED;
    }


}
