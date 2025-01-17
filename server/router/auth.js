const express = require("express");
const User = require("../models/userModel");
const jwt=require("jsonwebtoken");
const auth = require("../middleware/auth_middleware");

const authRouter = express.Router();

authRouter.post('/api/signup', async (req, res) => {
    try {
        const { name, email, profilePic } = req.body;

        let user = await User.findOne({ email: email })
        if (!user) {
            user = new User({
                email: email,
                name: name,
                profilePic: profilePic
            });
            user = await user.save();
        }

        const token=jwt.sign({id:user._id},"passwordKey");

        res.json({user,token});
    } catch (e) {
        res.statusCode(500).json({ error: e.message });
    }
})

authRouter.get("/",auth,async(req,res)=>{
    const user=await User.findById(req.user);
    res.json({user,token:req.token})
});

module.exports = authRouter;