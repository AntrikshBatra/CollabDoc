const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http")
const authRouter = require("./router/auth");
const documentRouter = require("./router/document");
const document = require("./models/document");
require('dotenv').config();


const PORT = process.env.PORT | 3001

const app = express()
var server = http.createServer(app);
var io = require("socket.io")(server);

app.use(cors())
app.use(express.json())
app.use(authRouter);
app.use(documentRouter);

const DB=process.env.DB

mongoose.connect(DB).
    then(() => { console.log("Connection Successful") })
    .catch((err) => { console.log(err) });

io.on('connection', (socket) => {
    socket.on('join', (documentID) => {
        socket.join(documentID);
        console.log(`Client joined document: ${documentID}`);
    });


    socket.on('typing', (data) => {
       // console.log(`Typing event in document ID: ${data.room}`, data);
        socket.broadcast.to(data.room).emit("changes", data.content); // Sends to all, including sender
    });


    socket.on('disconnect', () => {
        console.log("Client disconnected");
    });

    socket.on('save', (data) => {
        console.log('1');
        savedata(data);
        
    });

    const savedata = async (data) => {
        console.log('2');
        let documents=await document.findById(data.room);
        console.log('3');
        if (!documents) {
            console.error("Document not found");
            return;
        }
        console.log('Document Found');
        documents.content=data.delta;
        documents=await documents.save();
    };
})

server.listen(PORT, "0.0.0.0", () => {
    console.log("connected at PORT 3001");
})