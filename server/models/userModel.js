const mongoose = require("mongoose")

/**
* @type {mongoose.SchemaDefinitionProperty}
*/
const userSchema = mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
    },
    profilePic: {
        type: String,
        required: true,
    }
})

const User=mongoose.model('User',userSchema);
module.exports=User
