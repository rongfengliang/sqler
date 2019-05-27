// create a macro/endpoint called "_boot",
// this macro is private "used within other macros" 
// because it starts with "_".
_boot {
    // the query we want to execute
    exec = <<SQL
        CREATE TABLE IF NOT EXISTS `users` (
            `ID` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            `name` VARCHAR(30) DEFAULT "@anonymous",
            `email` VARCHAR(30) DEFAULT "@anonymous",
            `password` VARCHAR(200) DEFAULT "",
            `time` INT UNSIGNED
        );
    SQL
}

// adduser macro/endpoint, just hit `/adduser` with
// a `?user_name=&user_email=` or json `POST` request
// with the same fields.
adduser {
    validators {
        user_name_is_empty = "$input.user_name && $input.user_name.trim().length > 0"
        user_email_is_empty = "$input.user_email && $input.user_email.trim(' ').length > 0"
        user_password_is_not_ok = "$input.user_password && $input.user_password.trim(' ').length > 5"
    }

    bind {
        name = "$input.user_name"
        email = "$input.user_email"
        password = "$input.user_password"
    }

    methods = ["POST"]

    // authorizer = <<JS
    //     (function(){
    //         log("use this for debugging")
    //         token = $input.http_authorization
    //         response = fetch("http://requestbin.fullcontact.com/zxpjigzx", {
    //             headers: {
    //                 "Authorization": token
    //             }
    //         })
    //         if ( response.statusCode != 200 ) {
    //             return false
    //         }
    //         return true
    //     })()
    // JS

    // include some macros we declared before
    include = ["_boot"]

    exec = <<SQL
        INSERT INTO users(name, email, password, time) VALUES(:name, :email, :password, UNIX_TIMESTAMP());
        SELECT * FROM users WHERE id = LAST_INSERT_ID();
    SQL
}

// list all databases, and run a transformer function
databases {
    exec = "SHOW DATABASES"
}

// list all tables from all databases
tables {
    exec = "SELECT `table_schema` as `database`, `table_name` as `table` FROM INFORMATION_SCHEMA.tables"
}

// a macro that aggregates `databases` macro and `tables` macro into one macro
databases_tables {
    aggregate = ["databases", "tables"]
}